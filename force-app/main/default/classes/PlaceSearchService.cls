public with sharing class PlaceSearchService {
    @TestVisible
    private static final String GOOGLE_PLACES_API_KEY = MyPlaces_Settings__c.getOrgDefaults().Google_Places_API_Key__c != null ? MyPlaces_Settings__c.getOrgDefaults().Google_Places_API_Key__c : MyPlaces_Settings__c.getInstance().Google_Places_API_Key__c;

    public static final String GOOGLE_PLACES_TEXT_SEARCH_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
    public static final String GOOGLE_PLACES_DETAILS_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/details/json';
    public static final String GOOGLE_PLACES_PHOTOS_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/photo';
    private static final List<User> ADMIN_USERS = [SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'MyPlaces_Admins') AND IsActive = true];

    @AuraEnabled
    public static PlaceSearchData searchPlaces(String query, Map<String, Object> userLocation) {
        PlaceSearchData result;

        try {
            result = new PlaceSearchData(query, userLocation);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    private static SearchResult performSearch(String query, Map<String, Object> userLocation) {
        SearchResult result = getTextSearchResult(query, userLocation);

        if(result != null) {
            Map<String, Place__c> existingPlaces = getExistingPlaces(result.results);

            for(Place p : result.results) {
                if(existingPlaces.containsKey(p.place_id)) {
                    p.recordId = existingPlaces.get(p.place_id).Id;
                }

                getMissingPlaceDetails(p);
                
                if(p.photos != null && !p.photos.isEmpty()) {
                    getPlacePhoto(p);
                }
            }
        }
        
        return result;
    }

    private static SearchResult getTextSearchResult(String query, Map<String, Object> userLocation) {
        SearchResult result;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String args = String.join(new String[] {
            'key=' + EncodingUtil.urlEncode(GOOGLE_PLACES_API_KEY, 'UTF-8'),
            'language=en',
            'query=' + EncodingUtil.urlEncode(query, 'UTF-8')
        }, '&');

        if(userLocation != null) {
            args += '&location=' + EncodingUtil.urlEncode(userLocation.get('latitude') + ',' + userLocation.get('longitude'), 'UTF-8');
        }

        req.setEndpoint(GOOGLE_PLACES_TEXT_SEARCH_ENDPOINT + '?' + args);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() == 200) {
            result = (SearchResult)JSON.deserialize(res.getBody(), SearchResult.class);
        }

        return result;
    }

    private static Map<String, Place__c> getExistingPlaces(List<Place> places) {
        Map<String, Place__c> existingPlaces = new Map<String, Place__c>();

        if(places != null && !places.isEmpty()) {
            Set<String> googlePlaceIds = new Set<String>();

            for(Place p : places) {
                googlePlaceIds.add(p.place_id);
            }

            for(Place__c p : [SELECT Id, Google_Place_Id__c FROM Place__c WHERE Google_Place_Id__c IN :googlePlaceIds]) {
                existingPlaces.put(p.Google_Place_Id__c, p);
            }
        }

        return existingPlaces;
    }

    private static void getMissingPlaceDetails(Place place) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String args = String.join(new String[] {
            'key=' + EncodingUtil.urlEncode(GOOGLE_PLACES_API_KEY, 'UTF-8'),
            'language=en',
            'place_id=' + EncodingUtil.urlEncode(place.place_id, 'UTF-8'),
            'fields=address_component,opening_hours,international_phone_number,website'
        }, '&');
        req.setEndpoint(GOOGLE_PLACES_DETAILS_ENDPOINT + '?' + args);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200) {
            DetailResult result = (DetailResult)JSON.deserialize(res.getBody(), DetailResult.class);
            place.address_components = result.result.address_components;
            place.opening_hours = result.result.opening_hours;
            place.international_phone_number = result.result.international_phone_number;
            place.website = result.result.website;
        }
    }

	private static void getPlacePhoto(Place place) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String args = String.join(new String[] {
            'key=' + EncodingUtil.urlEncode(GOOGLE_PLACES_API_KEY, 'UTF-8'),
            'photo_reference=' + EncodingUtil.urlEncode(place.photos[0].photo_reference, 'UTF-8'),
            'maxwidth=400'
        }, '&');
        req.setEndpoint(GOOGLE_PLACES_PHOTOS_ENDPOINT + '?' + args);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 302) {
            place.photo_url = res.getBody().substring(res.getBody().indexOf('<A HREF="') + '<A HREF="'.length(), res.getBody().indexOf('">here</A>'));
        }
	}

    public class PlaceSearchData {
        @AuraEnabled
        public SearchResult searchResult;

        @AuraEnabled
        public Id dataOwnerId;

        public PlaceSearchData(String query, Map<String, Object> userLocation) {
            this.searchResult = performSearch(query, userLocation);
            this.dataOwnerId = !ADMIN_USERS.isEmpty() ? ADMIN_USERS[0].Id : UserInfo.getUserId();
        }
    }

    public class SearchResult {
        @AuraEnabled
        public List<Place> results;
    }

    public class DetailResult {
        public Place result;
    }

    private class Place {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String place_id;

        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public String formatted_address;

        @AuraEnabled
        public String international_phone_number;

        @AuraEnabled
        public String website;
        
        @AuraEnabled
        public Decimal rating;
        
        @AuraEnabled
        public Integer user_ratings_total;
        
        @AuraEnabled
        public List<AddressComponent> address_components;
        
        @AuraEnabled
        public Geometry geometry;
        
        @AuraEnabled
        public OpeningHours opening_hours;
        
        @AuraEnabled
        public String photo_url;
        
        public List<Photo> photos;
    }

    private class AddressComponent {
        
        @AuraEnabled
        public String long_name;
        
        @AuraEnabled
        public String short_name;
        
        @AuraEnabled
        public List<String> types;
    }

    private class Geometry {
        
        @AuraEnabled
        public GeometryLocation location;
    }

    private class GeometryLocation {
        
        @AuraEnabled
        public Double lat;
        
        @AuraEnabled
        public Double lng;
    }

    private class OpeningHours {
        
        @AuraEnabled
        public Boolean open_now;
        
        @AuraEnabled
        public List<String> weekday_text;
    }

    private class Photo {
        
        @AuraEnabled
        public String photo_reference;
    }

    public class PlaceSearchException extends Exception {}
}

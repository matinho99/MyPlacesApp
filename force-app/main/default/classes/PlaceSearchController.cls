public with sharing class PlaceSearchController {
    private static final String GOOGLE_PLACES_TEXT_SEARCH_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
    private static final String GOOGLE_PLACES_DETAILS_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/details/json';
    private static final String GOOGLE_PLACES_PHOTOS_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/photo';
    private static final String GOOGLE_PLACES_API_KEY = MyPlaces_Settings__c.getOrgDefaults().Google_Places_API_Key__c;

    @AuraEnabled
    public static SearchResult searchPlaces(String query) {
        SearchResult result;

        try {
            result = performSearch(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    private static SearchResult performSearch(String query) {
        SearchResult result = getTextSearchResult(query);

        if(result != null) {
            for(Place p : result.results) {
                getMissingPlaceDetails(p);
                
                if(!p.photos.isEmpty()) {
                    getPlacePhoto(p);
                }
            }
        }
        
        System.debug(JSON.serializePretty(result));
        return result;
    }

    private static SearchResult getTextSearchResult(String query) {
        SearchResult result;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String args = String.join(new String[] {
            'key=' + EncodingUtil.urlEncode(GOOGLE_PLACES_API_KEY, 'UTF-8'),
            'language=en',
            'query=' + EncodingUtil.urlEncode(query, 'UTF-8')
        }, '&');
        req.setEndpoint(GOOGLE_PLACES_TEXT_SEARCH_ENDPOINT + '?' + args);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() == 200) {
            result = (SearchResult)JSON.deserialize(res.getBody(), SearchResult.class);
        }

        return result;
    }

    private static void getMissingPlaceDetails(Place place) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String args = String.join(new String[] {
            'key=' + EncodingUtil.urlEncode(GOOGLE_PLACES_API_KEY, 'UTF-8'),
            'language=en',
            'place_id=' + EncodingUtil.urlEncode(place.place_id, 'UTF-8'),
            'fields=address_component,opening_hours'
        }, '&');
        req.setEndpoint(GOOGLE_PLACES_DETAILS_ENDPOINT + '?' + args);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200) {
            DetailResult result = (DetailResult)JSON.deserialize(res.getBody(), DetailResult.class);
            place.address_components = result.result.address_components;
            place.opening_hours = result.result.opening_hours;
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
        req.setEndpoint('https://maps.googleapis.com/maps/api/place/photo' + '?' + args);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 302) {
            place.photo_url = res.getBody().substring(res.getBody().indexOf('<A HREF="') + '<A HREF="'.length(), res.getBody().indexOf('">here</A>'));
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
        public String place_id;

        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public String formatted_address;
        
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

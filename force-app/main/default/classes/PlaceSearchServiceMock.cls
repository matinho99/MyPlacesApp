@IsTest
public class PlaceSearchServiceMock implements HttpCalloutMock {
    public static final String TEXT_SEARCH_QUERY = 'burgers central park new york';

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        System.assert(req.getEndpoint().contains('key=' + EncodingUtil.urlEncode(PlaceSearchService.GOOGLE_PLACES_API_KEY, 'UTF-8')));

        if(req.getEndpoint().startsWith(PlaceSearchService.GOOGLE_PLACES_TEXT_SEARCH_ENDPOINT)) {
            System.assert(req.getEndpoint().contains('query=' + EncodingUtil.urlEncode(TEXT_SEARCH_QUERY, 'UTF-8')));
            System.assert(req.getEndpoint().contains('language=en'));
            res.setHeader('Content-Type', 'application/json; charset=UTF-8');
            res.setStatusCode(200);
            res.setBody(getTextSearchReponseBody());
        } else if(req.getEndpoint().startsWith(PlaceSearchService.GOOGLE_PLACES_DETAILS_ENDPOINT)) {
            System.assert(req.getEndpoint().contains('language=en'));
            System.assert(req.getEndpoint().contains('fields=address_component,opening_hours,international_phone_number,website'));
            System.assert(req.getEndpoint().contains('place_id='));
            res.setHeader('Content-Type', 'application/json; charset=UTF-8');
            res.setStatusCode(200);

            if(req.getEndpoint().contains('place_id=' + EncodingUtil.urlEncode('ChIJq3tH0I5YwokRfL6Y8j8E6DM', 'UTF-8'))) {
                res.setBody(getPlaceDetailsReponseBody('ChIJq3tH0I5YwokRfL6Y8j8E6DM'));
            } else if(req.getEndpoint().contains('place_id=' + EncodingUtil.urlEncode('ChIJ8U_VmoZYwokR4g5HIK6dYso', 'UTF-8'))) {
                res.setBody(getPlaceDetailsReponseBody('ChIJ8U_VmoZYwokR4g5HIK6dYso'));
            } else if(req.getEndpoint().contains('place_id=' + EncodingUtil.urlEncode('ChIJm17AB5pYwokRWLJ6lEtXKOA', 'UTF-8'))) {
                res.setBody(getPlaceDetailsReponseBody('ChIJm17AB5pYwokRWLJ6lEtXKOA'));
            }
        } else if(req.getEndpoint().startsWith(PlaceSearchService.GOOGLE_PLACES_PHOTOS_ENDPOINT)) {
            System.assert(req.getEndpoint().contains('photo_reference='));
            System.assert(req.getEndpoint().contains('maxwidth=400'));
            res.setHeader('Content-Type', 'text/html; charset=UTF-8');
            res.setStatusCode(302);

            if(req.getEndpoint().contains('photo_reference=' + EncodingUtil.urlEncode('Aap_uECdSGhSPbDAchqRhtPzJ5gqRdf8EX_LWpgG-dX-_z5NdVegDaCiSprb8iC5WnEmrr7k-z5wsc4ixfsnEHwGwMVh4PuRFhnXsemukdZpLj6tPOGxeDRw956HrkRmvfnQZ00XqagoiIiEIuTUU-ylPDXKrhDGLwJbikWy8NLpHXiUZYSL', 'UTF-8'))) {
                res.setBody(getPlacePhotoResponseBody('ChIJq3tH0I5YwokRfL6Y8j8E6DM'));
            } else if(req.getEndpoint().contains('photo_reference=' + EncodingUtil.urlEncode('Aap_uEDk845RntlDM-Vc7qya93tST4k4393p7lDCgKxBYukyPBIVp_nEnA1nkr0MEBcqNWFUkrKOIiLiU0NwqyxgtFqWSIP2-1Fip8GjtWIJrbs5KEFsO01UkEgL8fGTwfyD1cc3QKMJa6a2_6fyYuedrN9ApNTUcW8BGkH8M5DBqRkiTLPU', 'UTF-8'))) {
                res.setBody(getPlacePhotoResponseBody('ChIJ8U_VmoZYwokR4g5HIK6dYso'));
            } else if(req.getEndpoint().contains('photo_reference=' + EncodingUtil.urlEncode('Aap_uEDtuS5hlYKEqLKjys6pX1ElEuawobf-G86FWvfSHMahcW6W-2CNbXF-ayP4h5ImVRKOi5JzrpmwcIbNzqX61l8am6Ozj4GxlnplZ2uXfBU0F2q3hAbKG8r90rtcF2rrqd-4HB_VGbvlZQlldiJtaq4t445MlRHetN7sCcXrH19ImYEG', 'UTF-8'))) {
                res.setBody(getPlacePhotoResponseBody('ChIJm17AB5pYwokRWLJ6lEtXKOA'));
            }
        }

        return res;
    }

    private static String getTextSearchReponseBody() {
        return '{"html_attributions":[],"results":[{"business_status":"OPERATIONAL","formatted_address":"366 Columbus Ave, New York, NY 10024, United States","geometry":' + 
            '{"location":{"lat":40.780873,"lng":-73.97655499999999},"viewport":{"northeast":{"lat":40.78214852989272,"lng":-73.97511717010727},"southwest":{"lat":40.77944887010728, ' + 
            '"lng":-73.97781682989272}}},"icon":"https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png","icon_background_color":"#FF9E67","icon_mask_base_uri": ' + 
            '"https://maps.gstatic.com/mapfiles/place_api/icons/v2/restaurant_pinlet","name":"Shake Shack","opening_hours":{"open_now":false},"photos":[{"height":3024,"html_attributions":' + 
            '["<a href=\'https://maps.google.com/maps/contrib/113749749050719181714\'>Michael Kuo</a>"],"photo_reference":"Aap_uECdSGhSPbDAchqRhtPzJ5gqRdf8EX_LWpgG-dX-_z5NdVegDaCiSprb8iC5' + 
            'WnEmrr7k-z5wsc4ixfsnEHwGwMVh4PuRFhnXsemukdZpLj6tPOGxeDRw956HrkRmvfnQZ00XqagoiIiEIuTUU-ylPDXKrhDGLwJbikWy8NLpHXiUZYSL","width":4032}],"place_id":"ChIJq3tH0I5YwokRfL6Y8j8E6DM",' + 
            '"plus_code":{"compound_code":"Q2JF+89 New York, United States","global_code":"87G8Q2JF+89"},"price_level":2,"rating":4.3,"reference":"ChIJq3tH0I5YwokRfL6Y8j8E6DM","types":[' + 
            '"meal_delivery","meal_takeaway","restaurant","food","point_of_interest","establishment"],"user_ratings_total":6283},{"business_status":"OPERATIONAL","formatted_address":"2315 ' + 
            'Broadway, New York, NY 10024, United States","geometry":{"location":{"lat":40.787122,"lng":-73.9780435},"viewport":{"northeast":{"lat":40.78841267989272,"lng":-73.97654052010728},' + 
            '"southwest":{"lat":40.78571302010727,"lng":-73.97924017989273}}},"icon":"https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png","icon_background_color":' + 
            '"#FF9E67","icon_mask_base_uri":"https://maps.gstatic.com/mapfiles/place_api/icons/v2/restaurant_pinlet","name":"5 Napkin Burger","opening_hours":{"open_now":false},"photos":' + 
            '[{"height":2667,"html_attributions":["<a href=\'https://maps.google.com/maps/contrib/103321608919346825996\'>A Google User</a>"],"photo_reference":"Aap_uEDk845RntlDM-Vc7qya93t' + 
            'ST4k4393p7lDCgKxBYukyPBIVp_nEnA1nkr0MEBcqNWFUkrKOIiLiU0NwqyxgtFqWSIP2-1Fip8GjtWIJrbs5KEFsO01UkEgL8fGTwfyD1cc3QKMJa6a2_6fyYuedrN9ApNTUcW8BGkH8M5DBqRkiTLPU","width":4000}],' + 
            '"place_id":"ChIJ8U_VmoZYwokR4g5HIK6dYso","plus_code":{"compound_code":"Q2PC+RQ New York, United States","global_code":"87G8Q2PC+RQ"},"price_level":2,"rating":4.2,"reference":' + 
            '"ChIJ8U_VmoZYwokR4g5HIK6dYso","types":["bar","restaurant","food","point_of_interest","establishment"],"user_ratings_total":1332},{"business_status":"OPERATIONAL",' + 
            '"formatted_address":"Park Drive North, E 72nd St, New York, NY 10021, United States","geometry":{"location":{"lat":40.7753313,"lng":-73.9687344},"viewport":{"northeast":{' + 
            '"lat":40.7763431,"lng":-73.96767117010728},"southwest":{"lat":40.7722959,"lng":-73.97037082989273}}},"icon":"https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png",' + 
            '"icon_background_color":"#FF9E67","icon_mask_base_uri":"https://maps.gstatic.com/mapfiles/place_api/icons/v2/restaurant_pinlet","name":"The Loeb","opening_hours":{' + 
            '"open_now":false},"photos":[{"height":2012,"html_attributions":["<a href=\'https://maps.google.com/maps/contrib/117650181461289882696\'>Maria Luisa Reis Brito</a>"],' + 
            '"photo_reference":"Aap_uEDtuS5hlYKEqLKjys6pX1ElEuawobf-G86FWvfSHMahcW6W-2CNbXF-ayP4h5ImVRKOi5JzrpmwcIbNzqX61l8am6Ozj4GxlnplZ2uXfBU0F2q3hAbKG8r90rtcF2rrqd-4HB_VGbvlZQlldiJtaq' + 
            '4t445MlRHetN7sCcXrH19ImYEG","width":3123}],"place_id":"ChIJm17AB5pYwokRWLJ6lEtXKOA","plus_code":{"compound_code":"Q2GJ+4G New York, United States","global_code":"87G8Q2GJ+4G"},' + 
            '"price_level":3,"rating":4.4,"reference":"ChIJm17AB5pYwokRWLJ6lEtXKOA","types":["tourist_attraction","bar","restaurant","food","point_of_interest","establishment"],' + 
            '"user_ratings_total":3152}],"status":"OK"}';
    }

    private static String getPlaceDetailsReponseBody(String place_id) {
        String body;

        if(place_id == 'ChIJq3tH0I5YwokRfL6Y8j8E6DM') {
            body = '{"html_attributions":[],"result":{"address_components":[{"long_name":"366","short_name":"366","types":["street_number"]},{"long_name":"Columbus Avenue","short_name":' + 
                '"Columbus Ave","types":["route"]},{"long_name":"Manhattan","short_name":"Manhattan","types":["sublocality_level_1","sublocality","political"]},{"long_name":"New York",' + 
                '"short_name":"New York","types":["locality","political"]},{"long_name":"New York County","short_name":"New York County","types":["administrative_area_level_2","political"]},' + 
                '{"long_name":"New York","short_name":"NY","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},' + 
                '{"long_name":"10024","short_name":"10024","types":["postal_code"]}],"international_phone_number":"+1 646-747-8770","opening_hours":{"open_now":false,"periods":[{"close":' + 
                '{"day":0,"time":"2300"},"open":{"day":0,"time":"1030"}},{"close":{"day":1,"time":"2300"},"open":{"day":1,"time":"1030"}},{"close":{"day":2,"time":"2300"},"open":{"day":2,"time":' + 
                '"1030"}},{"close":{"day":3,"time":"2300"},"open":{"day":3,"time":"1030"}},{"close":{"day":4,"time":"2300"},"open":{"day":4,"time":"1030"}},{"close":{"day":5,"time":"2300"},' + 
                '"open":{"day":5,"time":"1030"}},{"close":{"day":6,"time":"2300"},"open":{"day":6,"time":"1030"}}],"weekday_text":["Monday: 10:30 AM – 11:00 PM","Tuesday: 10:30 AM – 11:00 PM",' + 
                '"Wednesday: 10:30 AM – 11:00 PM","Thursday: 10:30 AM – 11:00 PM","Friday: 10:30 AM – 11:00 PM","Saturday: 10:30 AM – 11:00 PM","Sunday: 10:30 AM – 11:00 PM"]},"website":' + 
                '"https://www.shakeshack.com/location/upper-west-side/?utm_source=G&utm_medium=local&utm_campaign=google-local"},"status":"OK"}';
        } else if(place_id == 'ChIJ8U_VmoZYwokR4g5HIK6dYso') {
            body = '{"html_attributions":[],"result":{"address_components":[{"long_name":"2315","short_name":"2315","types":["street_number"]},{"long_name":"Broadway","short_name":"Broadway",' + 
                '"types":["route"]},{"long_name":"Manhattan","short_name":"Manhattan","types":["sublocality_level_1","sublocality","political"]},{"long_name":"New York","short_name":' + 
                '"New York","types":["locality","political"]},{"long_name":"New York County","short_name":"New York County","types":["administrative_area_level_2","political"]},{"long_name":' + 
                '"New York","short_name":"NY","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{' + 
                '"long_name":"10024","short_name":"10024","types":["postal_code"]}],"international_phone_number":"+1 212-333-4488","opening_hours":{"open_now":false,"periods":[{"close":{' + 
                '"day":0,"time":"2100"},"open":{"day":0,"time":"1130"}},{"close":{"day":1,"time":"2100"},"open":{"day":1,"time":"1130"}},{"close":{"day":2,"time":"2100"},"open":{"day":2,' + 
                '"time":"1130"}},{"close":{"day":3,"time":"2100"},"open":{"day":3,"time":"1130"}},{"close":{"day":4,"time":"2200"},"open":{"day":4,"time":"1130"}},{"close":{"day":5,"time":' + 
                '"2200"},"open":{"day":5,"time":"1130"}},{"close":{"day":6,"time":"2200"},"open":{"day":6,"time":"1130"}}],"weekday_text":["Monday: 11:30 AM – 9:00 PM","Tuesday: 11:30 AM – ' + 
                '9:00 PM","Wednesday: 11:30 AM – 9:00 PM","Thursday: 11:30 AM – 10:00 PM","Friday: 11:30 AM – 10:00 PM","Saturday: 11:30 AM – 10:00 PM","Sunday: 11:30 AM – 9:00 PM"]},' + 
                '"website":"http://www.5napkinburger.com/"},"status":"OK"}';
        } else if(place_id == 'ChIJm17AB5pYwokRWLJ6lEtXKOA') {
            body = '{"html_attributions":[],"result":{"address_components":[{"long_name":"East 72nd Street","short_name":"E 72nd St","types":["route"]},{"long_name":"Manhattan","short_name":' + 
                '"Manhattan","types":["sublocality_level_1","sublocality","political"]},{"long_name":"New York","short_name":"New York","types":["locality","political"]},{"long_name":' + 
                '"New York County","short_name":"New York County","types":["administrative_area_level_2","political"]},{"long_name":"New York","short_name":"NY","types":["administrative_' + 
                'area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"10021","short_name":"10021","types":["postal_co' + 
                'de"]}],"international_phone_number":"+1 212-517-2233","opening_hours":{"open_now":false,"periods":[{"close":{"day":0,"time":"1545"},"open":{"day":0,"time":"0930"}},{"clo' + 
                'se":{"day":0,"time":"2100"},"open":{"day":0,"time":"1800"}},{"close":{"day":1,"time":"1545"},"open":{"day":1,"time":"1200"}},{"close":{"day":1,"time":"2045"},"open":{"da' + 
                'y":1,"time":"1730"}},{"close":{"day":2,"time":"1545"},"open":{"day":2,"time":"1200"}},{"close":{"day":2,"time":"2045"},"open":{"day":2,"time":"1730"}},{"close":{"day":3,' + 
                '"time":"1545"},"open":{"day":3,"time":"1200"}},{"close":{"day":3,"time":"2045"},"open":{"day":3,"time":"1730"}},{"close":{"day":4,"time":"1545"},"open":{"day":4,"time":"' + 
                '1200"}},{"close":{"day":4,"time":"2045"},"open":{"day":4,"time":"1730"}},{"close":{"day":5,"time":"1545"},"open":{"day":5,"time":"1200"}},{"close":{"day":5,"time":"2045"' + 
                '},"open":{"day":5,"time":"1730"}},{"close":{"day":6,"time":"1545"},"open":{"day":6,"time":"0930"}},{"close":{"day":6,"time":"2100"},"open":{"day":6,"time":"1800"}}],"wee' + 
                'kday_text":["Monday: 12:00 – 3:45 PM, 5:30 – 8:45 PM","Tuesday: 12:00 – 3:45 PM, 5:30 – 8:45 PM","Wednesday: 12:00 – 3:45 PM, 5:30 – 8:45 PM","Thursday: 12:00 – 3:45 PM,' + 
                ' 5:30 – 8:45 PM","Friday: 12:00 – 3:45 PM, 5:30 – 8:45 PM","Saturday: 9:30 AM – 3:45 PM, 6:00 – 9:00 PM","Sunday: 9:30 AM – 3:45 PM, 6:00 – 9:00 PM"]},"website":"http://' + 
                'www.thecentralparkboathouse.com/"},"status":"OK"}';
        }

        return body;
    }

    private static String getPlacePhotoResponseBody(String place_id) {
        String body;

        if(place_id == 'ChIJq3tH0I5YwokRfL6Y8j8E6DM') {
            body = '<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8"><TITLE>302 Moved</TITLE></HEAD><BODY><H1>302 Moved</H1>The document has moved<A HREF=' + 
                '"https://lh3.googleusercontent.com/places/AAcXr8oFPY6Q7VYqYiRuRsKwo8I5xKYi34yPda41naWdgXCv8OOBsaiRBnjzaC2UNGWLv9Dln6AoSGMLQI3xBTDUpsbHs4OMw7OqtyY=s1600-w400">here</A>.' + 
                '</BODY></HTML>';
        } else if(place_id == 'ChIJ8U_VmoZYwokR4g5HIK6dYso') {
            body = '<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8"><TITLE>302 Moved</TITLE></HEAD><BODY><H1>302 Moved</H1>The document has moved<A HREF=' + 
                '"https://lh3.googleusercontent.com/places/AAcXr8oE_xBz-MRd2kii5fENdBDZ-ON-8Mw4_4MYqaU9xHBeDpxa1H085BgCjC1pPXuIDAb4Cvm4CKsUWQtkFQdD7W0NPTw1tTz3l6M=s1600-w400">here</A>.' + 
                '</BODY></HTML>';
        } else if(place_id == 'ChIJm17AB5pYwokRWLJ6lEtXKOA') {
            body = '<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8"><TITLE>302 Moved</TITLE></HEAD><BODY><H1>302 Moved</H1>The document has moved<A HREF=' + 
                '"https://lh3.googleusercontent.com/places/AAcXr8rkYz3dibl0h7hpKhSP5y0tVN2brK0COC88B3gYggxSNp5iOweEu1tOVCzMwO7TsiABHDFBe96-ct59MZxn-CSdkOL1YzYWcCY=s1600-w400">here</A>.' + 
                '</BODY></HTML>';
        }

        return body;
    }
}

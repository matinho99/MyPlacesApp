@IsTest
public with sharing class PlaceSearchServiceTest {
    @TestSetup
    private static void makeData(){
        System.debug([SELECT Id, Name FROM User]);
        TestUtil.insertAppUsers();
        TestUtil.setupCustomSetting();
    }

    @IsTest
    private static void testSearchPlaces() {
        User appAdmin = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_ADMIN_PROFILE.Id LIMIT 1];
        User appUser = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_USER_PROFILE.Id LIMIT 1];

        Place__c existingPlace = TestUtil.createPlace(new Place__c(Name = 'Shake Shack', Google_Place_Id__c = 'ChIJq3tH0I5YwokRfL6Y8j8E6DM'), true);
        Test.setMock(HttpCalloutMock.class, new PlaceSearchServiceMock());

        System.runAs(appUser) {
            Test.startTest();
            PlaceSearchService.PlaceSearchData data = PlaceSearchService.searchPlaces(PlaceSearchServiceMock.TEXT_SEARCH_QUERY, null);
            Test.stopTest();

            System.assertEquals(3, data.searchResult.results.size());

            System.assertEquals('Shake Shack', data.searchResult.results[0].name);
            System.assertEquals('ChIJq3tH0I5YwokRfL6Y8j8E6DM', data.searchResult.results[0].place_id);
            System.assertEquals(existingPlace.Id, data.searchResult.results[0].recordId);
            System.assertEquals('https://www.shakeshack.com/location/upper-west-side/?utm_source=G&utm_medium=local&utm_campaign=google-local', data.searchResult.results[0].website);
            System.assertEquals('https://lh3.googleusercontent.com/places/AAcXr8oFPY6Q7VYqYiRuRsKwo8I5xKYi34yPda41naWdgXCv8OOBsaiRBnjzaC2UNGWLv9Dln6AoSGMLQI3xBTDUpsbHs4OMw7OqtyY=s1600-w400', data.searchResult.results[0].photo_url);

            System.assertEquals('5 Napkin Burger', data.searchResult.results[1].name);
            System.assertEquals('ChIJ8U_VmoZYwokR4g5HIK6dYso', data.searchResult.results[1].place_id);
            System.assertEquals(null, data.searchResult.results[1].recordId);
            System.assertEquals('http://www.5napkinburger.com/', data.searchResult.results[1].website);
            System.assertEquals('https://lh3.googleusercontent.com/places/AAcXr8oE_xBz-MRd2kii5fENdBDZ-ON-8Mw4_4MYqaU9xHBeDpxa1H085BgCjC1pPXuIDAb4Cvm4CKsUWQtkFQdD7W0NPTw1tTz3l6M=s1600-w400', data.searchResult.results[1].photo_url);

            System.assertEquals('The Loeb', data.searchResult.results[2].name);
            System.assertEquals('ChIJm17AB5pYwokRWLJ6lEtXKOA', data.searchResult.results[2].place_id);
            System.assertEquals(null, data.searchResult.results[2].recordId);
            System.assertEquals('http://www.thecentralparkboathouse.com/', data.searchResult.results[2].website);
            System.assertEquals('https://lh3.googleusercontent.com/places/AAcXr8rkYz3dibl0h7hpKhSP5y0tVN2brK0COC88B3gYggxSNp5iOweEu1tOVCzMwO7TsiABHDFBe96-ct59MZxn-CSdkOL1YzYWcCY=s1600-w400', data.searchResult.results[2].photo_url);
        }
    }
}

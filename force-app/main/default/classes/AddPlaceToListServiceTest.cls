@IsTest
public with sharing class AddPlaceToListServiceTest {
    @TestSetup
    private static void makeData(){
        TestUtil.insertAppUsers();
    }

    @IsTest
    private static void testGetUserLists() {
        User appUser = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_USER_PROFILE.Id LIMIT 1];
        insert new List<List__c>{
            TestUtil.createList(new List__c(Name = 'Favourites', Description__c = 'My favourite places', OwnerId = appUser.Id), false),
            TestUtil.createList(new List__c(Name = 'New York Pizza', Description__c = 'Best pizza places in New York', OwnerId = appUser.Id), false),
            TestUtil.createList(new List__c(Name = 'Florence', Description__c = 'Things to see in Florence', OwnerId = appUser.Id), false)
        };

        System.runAs(appUser) {
            Test.startTest();
            List<List__c> myLists = AddPlaceToListService.getUserLists();
            Test.stopTest();

            System.assertEquals(3, myLists.size());
            System.assertEquals('Favourites', myLists[0].Name);
            System.assertEquals('New York Pizza', myLists[1].Name);
            System.assertEquals('Florence', myLists[2].Name);
        }
    }

    @IsTest
    private static void testGetListPlaces() {
        User appAdmin = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_ADMIN_PROFILE.Id LIMIT 1];
        User appUser = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_USER_PROFILE.Id LIMIT 1];

        List<Place__c> places = new List<Place__c>{
            TestUtil.createPlace(new Place__c( Name = 'Shake Shack', OwnerId = appAdmin.Id ), false),
            TestUtil.createPlace(new Place__c( Name = 'Central Park Pizza', OwnerId = appAdmin.Id ), false),
            TestUtil.createPlace(new Place__c( Name = 'Cattedrale di Santa Maria del Fiore', OwnerId = appAdmin.Id ), false),
            TestUtil.createPlace(new Place__c( Name = 'Ponte Vecchio', OwnerId = appAdmin.Id ), false),
            TestUtil.createPlace(new Place__c( Name = 'Statue of Liberty', OwnerId = appAdmin.Id ), false)
        };

        List<List__c> lists = new List<List__c>{
            TestUtil.createList(new List__c(Name = 'Favourites', Description__c = 'My favourite places', OwnerId = appUser.Id), false),
            TestUtil.createList(new List__c(Name = 'New York Pizza', Description__c = 'Best pizza places in New York', OwnerId = appUser.Id), false),
            TestUtil.createList(new List__c(Name = 'Florence', Description__c = 'Things to see in Florence', OwnerId = appUser.Id), false)
        };

        List<SObject> recs = new List<SObject>();
        recs.addAll(places);
        recs.addAll(lists);
        insert recs;
        insert new List<List_Place__c>{
            TestUtil.createListPlace(new List_Place__c(Place__c = places[0].Id, List__c = lists[0].Id, OwnerId = appUser.Id), false),
            TestUtil.createListPlace(new List_Place__c(Place__c = places[1].Id, List__c = lists[0].Id, OwnerId = appUser.Id), false),
            TestUtil.createListPlace(new List_Place__c(Place__c = places[1].Id, List__c = lists[1].Id, OwnerId = appUser.Id), false),
            TestUtil.createListPlace(new List_Place__c(Place__c = places[2].Id, List__c = lists[0].Id, OwnerId = appUser.Id), false),
            TestUtil.createListPlace(new List_Place__c(Place__c = places[2].Id, List__c = lists[2].Id, OwnerId = appUser.Id), false),
            TestUtil.createListPlace(new List_Place__c(Place__c = places[3].Id, List__c = lists[2].Id, OwnerId = appUser.Id), false)
        };

        System.runAs(appUser) {
            Test.startTest();
            List<List_Place__c> listPlaces0 = AddPlaceToListService.getListPlaces(places[0].Id);
            List<List_Place__c> listPlaces1 = AddPlaceToListService.getListPlaces(places[1].Id);
            List<List_Place__c> listPlaces2 = AddPlaceToListService.getListPlaces(places[2].Id);
            List<List_Place__c> listPlaces3 = AddPlaceToListService.getListPlaces(places[3].Id);
            Test.stopTest();

            System.assertEquals(1, listPlaces0.size());
            System.assertEquals(2, listPlaces1.size());
            System.assertEquals(2, listPlaces2.size());
            System.assertEquals(1, listPlaces3.size());

            System.assertEquals(lists[0].Id, listPlaces1[0].List__c);
            System.assertEquals(lists[1].Id, listPlaces1[1].List__c);
        }
    }
}

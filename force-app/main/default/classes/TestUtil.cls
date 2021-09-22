@IsTest
public with sharing class TestUtil {
    @Future
    public static void insertAppUsers() {
        List<User> users = new List<User>();
        users.add(new User(
            ProfileId = AppConstants.APP_ADMIN_PROFILE.Id,
            Email = 'jdoe@test.com.invalid',
            Username = 'jdoe@myplaces.com',
            FirstName = 'John',
            LastName = 'Doe',
            Alias = 'jdoe',
            TimeZoneSidKey = 'Europe/Prague',
            LocaleSidKey = 'en_IE_EURO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        ));
        users.add(new User(
            ProfileId = AppConstants.APP_USER_PROFILE.Id,
            Email = 'jrow@test.com.invalid',
            Username = 'jrow@myplaces.com',
            FirstName = 'Jane',
            LastName = 'Row',
            Alias = 'jrow',
            TimeZoneSidKey = 'Europe/Prague',
            LocaleSidKey = 'en_IE_EURO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        ));
        insert users;
    }

    public static Place__c createPlace(Place__c template, Boolean isInsert) {
        Place__c place = template != null ? template.clone() : new Place__c();
        place.OwnerId = String.isNotBlank(place.OwnerId) ? place.OwnerId : UserInfo.getUserId();
        place.Name = String.isNotBlank(place.Name) ? place.Name : 'Test Place';

        if(isInsert) {
            insert place;
        }
        
        return place;
    }

    public static List__c createList(List__c template, Boolean isInsert) {
        List__c lst = template != null ? template.clone() : new List__c();
        lst.Name = String.isNotBlank(lst.Name) ? lst.Name : 'Test List';
        lst.Description__c = String.isNotBlank(lst.Description__c) ? lst.Description__c : 'List of the most awesome places';
        
        if(isInsert) {
            insert lst;
        }

        return lst;
    }

    public static List_Place__c createListPlace(List_Place__c template, Boolean isInsert) {
        List_Place__c lp = template != null ? template.clone() : new List_Place__c();
        String placeId = lp.Place__c;
        String listId = lp.List__c;

        if(String.isBlank(placeId) && String.isBlank(listId)) {
            Place__c p = createPlace(null, false);
            List__c l = createList(null, false);
            insert new List<SObject>{ p, l };
            lp.Place__c = p.Id;
            lp.List__c = l.Id;
        } else if(String.isBlank(placeId)) {
            Place__c p = createPlace(null, true);
            lp.Place__c = p.Id;
        } else if(String.isBlank(listId)) {
            List__c l = createList(null, true);
            lp.List__c = l.Id;
        }

        if(isInsert) {
            insert lp;
        }

        return lp;
    }

    public static void setupCustomSetting() {
        insert new MyPlaces_Settings__c(Google_Places_API_Key__c = 'a1b2c3');
    }
}

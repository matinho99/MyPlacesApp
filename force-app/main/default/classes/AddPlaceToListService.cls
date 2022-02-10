public with sharing class AddPlaceToListService {
    @AuraEnabled
    public static List<List__c> getUserLists() {
        return [SELECT Id, Name FROM List__c WHERE OwnerId = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static List<List_Place__c> getListPlaces(String recordId) {
        return [SELECT Id, Place__c, List__c FROM List_Place__c WHERE Place__c = :recordId AND OwnerId = :UserInfo.getUserId()];
    }
}

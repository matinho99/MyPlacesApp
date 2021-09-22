public with sharing class AppConstants {
    public static final Profile APP_ADMIN_PROFILE = [SELECT Id FROM Profile WHERE Name = 'MyPlaces Admin'];
    public static final Profile APP_USER_PROFILE = [SELECT Id FROM Profile WHERE Name = 'MyPlaces User'];
    public static final PermissionSet APP_ADMIN_PERMISSION_SET = [SELECT Id FROM PermissionSet WHERE Name = 'MyPlaces_Admin'];
    public static final PermissionSet APP_USER_PERMISSION_SET = [SELECT Id FROM PermissionSet WHERE Name = 'MyPlaces_User'];
    public static final Group APP_ADMIN_GROUP = [SELECT Id FROM Group WHERE DeveloperName = 'MyPlaces_Admins'];
    public static final Group APP_USER_GROUP = [SELECT Id FROM Group WHERE DeveloperName = 'MyPlaces_Users'];
}

@IsTest
public with sharing class UserTriggerTest {
    @TestSetup
    static void makeData() {
        TestUtil.insertAppUsers();
    }

    @IsTest
    private static void testUsersAssignedToPermissionSetsAfterInsert() {
        User appAdmin = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_ADMIN_PROFILE.Id LIMIT 1];
        User appUser = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_USER_PROFILE.Id LIMIT 1];
        List<User> users = new List<User>{ appAdmin, appUser };

        System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :AppConstants.APP_ADMIN_PERMISSION_SET.Id AND AssigneeId = :users[0].Id]);
        System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :AppConstants.APP_USER_PERMISSION_SET.Id AND AssigneeId = :users[1].Id]);
    }

    @IsTest
    private static void testUsersAssignedToGroupsAfterInsert() {
        User appAdmin = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_ADMIN_PROFILE.Id LIMIT 1];
        User appUser = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_USER_PROFILE.Id LIMIT 1];
        List<User> users = new List<User>{ appAdmin, appUser };

        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :AppConstants.APP_ADMIN_GROUP.Id AND UserOrGroupId = :users[0].Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :AppConstants.APP_USER_GROUP.Id AND UserOrGroupId = :users[1].Id]);
    }

    @IsTest
    private static void testUsersAssignedToPermissionSetsAfterUpdate() {
        User appAdmin = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_ADMIN_PROFILE.Id LIMIT 1];
        User appUser = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_USER_PROFILE.Id LIMIT 1];
        List<User> users = new List<User>{ appAdmin, appUser };
        delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN :users AND (PermissionSetId = :AppConstants.APP_ADMIN_PERMISSION_SET.Id 
                                                                                    OR PermissionSetId = :AppConstants.APP_USER_PERMISSION_SET.Id)];
        System.assertEquals(0, [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId IN :users AND (PermissionSetId = :AppConstants.APP_ADMIN_PERMISSION_SET.Id 
                                                                                                         OR PermissionSetId = :AppConstants.APP_USER_PERMISSION_SET.Id)]);

        update users;

        System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :AppConstants.APP_ADMIN_PERMISSION_SET.Id AND AssigneeId = :users[0].Id]);
        System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :AppConstants.APP_USER_PERMISSION_SET.Id AND AssigneeId = :users[1].Id]);
    }

    @IsTest
    private static void testUsersAssignedToGroupsAfterUpdate() {
        User appAdmin = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_ADMIN_PROFILE.Id LIMIT 1];
        User appUser = [SELECT Id FROM User WHERE ProfileId = :AppConstants.APP_USER_PROFILE.Id LIMIT 1];
        List<User> users = new List<User>{ appAdmin, appUser };
        delete [SELECT Id FROM GroupMember WHERE UserOrGroupId IN :users];
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE UserOrGroupId IN :users]);

        update users;

        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :AppConstants.APP_ADMIN_GROUP.Id AND UserOrGroupId = :users[0].Id]);
        System.assertEquals(1, [SELECT COUNT() FROM GroupMember WHERE GroupId = :AppConstants.APP_USER_GROUP.Id AND UserOrGroupId = :users[1].Id]);
    }
}

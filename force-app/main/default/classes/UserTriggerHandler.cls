public with sharing class UserTriggerHandler {
    private static final Profile appAdminProfile = [SELECT Id FROM Profile WHERE Name = 'MyPlaces Admin'];
    private static final Profile appUserProfile = [SELECT Id FROM Profile WHERE Name = 'MyPlaces User'];
    private static final PermissionSet appAdminPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'MyPlaces_Admin'];
    private static final PermissionSet appUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'MyPlaces_User'];
    private static final Group appAdminGroup = [SELECT Id FROM Group WHERE DeveloperName = 'MyPlaces_Admins'];
    private static final Group appUserGroup = [SELECT Id FROM Group WHERE DeveloperName = 'MyPlaces_Users'];

    public static void afterInsert(Map<Id, User> newMap) {
        assignUsersToPermissionSets(newMap);
        assignUsersToGroups(newMap);
    }

    public static void afterUpdate(Map<Id, User> newMap, Map<Id, User> oldMap) {
        assignUsersToPermissionSets(newMap);
        assignUsersToGroups(newMap);
    }

    private static void assignUsersToPermissionSets(Map<Id, User> userMap) {
        List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();
        Set<Id> adminPermissionSetAssigneeIds = new Set<Id>();
        Set<Id> userPermissionSetAssigneeIds = new Set<Id>();

        for(PermissionSetAssignment psa : [SELECT AssigneeId, Assignee.ProfileId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :userMap.keySet() AND (PermissionSetId = :appAdminPermissionSet.Id OR PermissionSetId = :appUserPermissionSet.Id) AND IsActive = true]) {
            if(psa.Assignee.ProfileId == appAdminProfile.Id && psa.PermissionSetId == appAdminPermissionSet.Id) {
                adminPermissionSetAssigneeIds.add(psa.AssigneeId);
            } else if(psa.Assignee.ProfileId == appUserProfile.Id && psa.PermissionSetId == appUserPermissionSet.Id) {
                userPermissionSetAssigneeIds.add(psa.AssigneeId);
            }
        }

        for(User u : userMap.values()) {
            if(u.IsActive) {
                if(u.ProfileId == appAdminProfile.Id && !adminPermissionSetAssigneeIds.contains(u.Id)) {
                    toInsert.add(new PermissionSetAssignment(
                        AssigneeId = u.Id,
                        PermissionSetId = appAdminPermissionSet.Id
                    ));
                } else if(u.ProfileId == appUserProfile.Id && !userPermissionSetAssigneeIds.contains(u.Id)) {
                    toInsert.add(new PermissionSetAssignment(
                        AssigneeId = u.Id,
                        PermissionSetId = appUserPermissionSet.Id
                    ));
                }
            }
        }

        if(!toInsert.isEmpty()) {
            Database.insert(toInsert);
        }
    }

    private static void assignUsersToGroups(Map<Id, User> userMap) {
        List<GroupMember> toInsert = new List<GroupMember>();
        Set<Id> adminGroupMemberIds = new Set<Id>();
        Set<Id> userGroupMemberIds = new Set<Id>();

        for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN :userMap.keySet() AND (GroupId = :appAdminGroup.Id OR GroupId = :appUserGroup.Id)]) {
            if(userMap.get(gm.UserOrGroupId).ProfileId == appAdminProfile.Id && gm.GroupId == appAdminGroup.Id) {
                adminGroupMemberIds.add(gm.UserOrGroupId);
            } else if(userMap.get(gm.UserOrGroupId).ProfileId == appUserProfile.Id && gm.GroupId == appUserGroup.Id) {
                userGroupMemberIds.add(gm.UserOrGroupId);
            }
        }

        for(User u : userMap.values()) {
            if(u.IsActive) {
                if(u.ProfileId == appAdminProfile.Id && !adminGroupMemberIds.contains(u.Id)) {
                    toInsert.add(new GroupMember(
                        GroupId = appAdminGroup.Id,
                        UserOrGroupId = u.Id
                    ));
                } else if(u.ProfileId == appUserProfile.Id && !userGroupMemberIds.contains(u.Id)) {
                    toInsert.add(new GroupMember(
                        GroupId = appUserGroup.Id,
                        UserOrGroupId = u.Id
                    ));
                }
            }
        }

        if(!toInsert.isEmpty()) {
            Database.insert(toInsert);
        }
    }
}

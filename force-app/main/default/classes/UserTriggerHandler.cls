public with sharing class UserTriggerHandler {
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

        for(PermissionSetAssignment psa : [SELECT AssigneeId, Assignee.ProfileId, PermissionSetId 
                                           FROM PermissionSetAssignment 
                                           WHERE AssigneeId IN :userMap.keySet() AND (PermissionSetId = :AppConstants.APP_ADMIN_PERMISSION_SET.Id 
                                                                                   OR PermissionSetId = :AppConstants.APP_USER_PERMISSION_SET.Id) AND IsActive = true]) {
            if(psa.Assignee.ProfileId == AppConstants.APP_ADMIN_PROFILE.Id && psa.PermissionSetId == AppConstants.APP_ADMIN_PERMISSION_SET.Id) {
                adminPermissionSetAssigneeIds.add(psa.AssigneeId);
            } else if(psa.Assignee.ProfileId == AppConstants.APP_USER_PROFILE.Id && psa.PermissionSetId == AppConstants.APP_USER_PERMISSION_SET.Id) {
                userPermissionSetAssigneeIds.add(psa.AssigneeId);
            }
        }

        for(User u : userMap.values()) {
            if(u.IsActive) {
                if(u.ProfileId == AppConstants.APP_ADMIN_PROFILE.Id && !adminPermissionSetAssigneeIds.contains(u.Id)) {
                    toInsert.add(new PermissionSetAssignment(
                        AssigneeId = u.Id,
                        PermissionSetId = AppConstants.APP_ADMIN_PERMISSION_SET.Id
                    ));
                } else if(u.ProfileId == AppConstants.APP_USER_PROFILE.Id && !userPermissionSetAssigneeIds.contains(u.Id)) {
                    toInsert.add(new PermissionSetAssignment(
                        AssigneeId = u.Id,
                        PermissionSetId = AppConstants.APP_USER_PERMISSION_SET.Id
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

        for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN :userMap.keySet() AND (GroupId = :AppConstants.APP_ADMIN_GROUP.Id OR GroupId = :AppConstants.APP_USER_GROUP.Id)]) {
            if(userMap.get(gm.UserOrGroupId).ProfileId == AppConstants.APP_ADMIN_PROFILE.Id && gm.GroupId == AppConstants.APP_ADMIN_GROUP.Id) {
                adminGroupMemberIds.add(gm.UserOrGroupId);
            } else if(userMap.get(gm.UserOrGroupId).ProfileId == AppConstants.APP_USER_PROFILE.Id && gm.GroupId == AppConstants.APP_USER_GROUP.Id) {
                userGroupMemberIds.add(gm.UserOrGroupId);
            }
        }

        for(User u : userMap.values()) {
            if(u.IsActive) {
                if(u.ProfileId == AppConstants.APP_ADMIN_PROFILE.Id && !adminGroupMemberIds.contains(u.Id)) {
                    toInsert.add(new GroupMember(
                        GroupId = AppConstants.APP_ADMIN_GROUP.Id,
                        UserOrGroupId = u.Id
                    ));
                } else if(u.ProfileId == AppConstants.APP_USER_PROFILE.Id && !userGroupMemberIds.contains(u.Id)) {
                    toInsert.add(new GroupMember(
                        GroupId = AppConstants.APP_USER_GROUP.Id,
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

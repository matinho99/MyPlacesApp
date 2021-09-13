trigger UserTrigger on User (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            UserTriggerHandler.afterInsert(Trigger.newMap);
        } else if(Trigger.isUpdate) {
            UserTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}
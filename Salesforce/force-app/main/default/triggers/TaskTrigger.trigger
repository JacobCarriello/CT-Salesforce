trigger TaskTrigger on Task (before insert, after insert, after update, after delete) {
    if(Trigger.isBefore){
        TaskTriggerHandler.beforeInsert(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
        TaskTriggerHandler.afterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        TaskTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isDelete) {
        TaskTriggerHandler.afterDelete(Trigger.old);
    }
}
trigger SendOutTriggers on TR1__Send_Out__c (after insert, after update) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        SendOutTriggerHandler.afterInsertUpdate(Trigger.new, Trigger.oldMap);
    }
}
trigger ProcurementTriggers on Procurement__c (after insert, after update, before insert, before update) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        ProcurementTriggerHandler.afterInsertUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        ProcurementTriggerHandler.beforeInsertUpdate(Trigger.new, Trigger.oldMap);
    }
}
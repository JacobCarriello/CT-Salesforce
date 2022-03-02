trigger ShiftWork_TR on TR1__ShiftWork__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(TR1__ShiftWork__c.sObjectType);
}
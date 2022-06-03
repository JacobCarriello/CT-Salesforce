trigger TimesheetTrigger on NG_Timesheet__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(NG_Timesheet__c.sObjectType);
}
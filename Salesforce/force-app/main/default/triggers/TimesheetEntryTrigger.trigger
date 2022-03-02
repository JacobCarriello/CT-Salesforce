trigger TimesheetEntryTrigger on NG_Timesheet_Entry__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(NG_Timesheet_Entry__c.sObjectType);
}
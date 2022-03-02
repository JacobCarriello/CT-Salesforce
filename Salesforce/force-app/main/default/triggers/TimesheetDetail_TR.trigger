trigger TimesheetDetail_TR on TR1__Timesheet_Detail__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(TR1__Timesheet_Detail__c.sObjectType);
}
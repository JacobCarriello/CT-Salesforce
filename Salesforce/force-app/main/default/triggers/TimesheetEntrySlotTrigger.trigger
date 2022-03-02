trigger TimesheetEntrySlotTrigger on NG_Timesheet_Entry_Slot__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(NG_Timesheet_Entry_Slot__c.sObjectType);
}
trigger TimesheetTrigger_TR on TR1__Timesheet__c (after delete, after insert, after update, before delete, before insert, before update) {
    system.debug('bw: TimesheetTrigger_TR -> fired');
    TriggerFactory.createHandler(TR1__Timesheet__c.sObjectType);
}
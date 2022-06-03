@isTest
public class TR_ShiftWork_Gateway_Test {
    @isTest
    public static void testFetch() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         

        System.debug('bw: TR_ShiftWork_Gateway_Test -> TR Timesheet t = ' + t);
        System.debug('bw: TR_ShiftWork_Gateway_Test -> NG Timesheets = ' + timesheets);
        System.debug('bw: TR_ShiftWork_Gateway_Test -> NG Timesheet Entries = ' + entries);

        NG_Timesheet_Entry_Slot__c s = TimesheetService.fetchTimesheetEntrySlot(entries[0].Default_Slot__c);
        s.In_Time__c = '07:00';
        s.Out_Time__c = '18:00';
        s.Out_Date__c = '2019-10-28';
        update s;
        s = TimesheetService.fetchTimesheetEntrySlot(entries[0].Default_Slot__c);

        TR1__ShiftWork__c sh = TR_ShiftWork_Gateway.fetch(s.Source_Object_ID__c);
        System.assert(sh != null);
    }

    @isTest
    public static void testFetchShiftWorkForTimesheetDetailId() {
         TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         

        NG_Timesheet_Entry_Slot__c s = TimesheetService.fetchTimesheetEntrySlot(entries[0].Default_Slot__c);
        s.In_Time__c = '07:00';
        s.Out_Time__c = '18:00';
        s.Out_Date__c = '2019-10-28';
        update s;
        s = TimesheetService.fetchTimesheetEntrySlot(entries[0].Default_Slot__c);

        TR1__ShiftWork__c sh = TR_ShiftWork_Gateway.fetchShiftWorkForTimesheetDetailId(s.Timesheet_Entry_Source_Object_ID__c);
        System.assert(sh != null);

        TR_ShiftWork_Gateway.save(sh);
    }
}
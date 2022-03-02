@isTest
public class TimesheetEntrySlotHelper_Test {
    @isTest
    public static void testTimesheetEntrySlotHelper() {

        TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         

        NG_Timesheet_Entry_Slot__c s = new NG_Timesheet_Entry_Slot__c();
        s.Timesheet_Entry__c = entries[0].Id;
        s.In_Time__c = '07:00';
        s.Out_Time__c = '18:00';
        insert s;

        s.In_Date__c = '2019-08-28';
        s.In_Time__c = '08:00';
        s.Out_Date__c = '2019-08-28';
        s.Out_Time__c = '18:00';
        s.Custom_Callback_In_Date__c = '2019-08-28';
        s.Custom_Callback_In_Time__c = '18:00';
        s.Custom_Callback_Out_Date__c = '2019-08-28';
        s.Custom_Callback_Out_Time__c = '20:00';
        s.Day__c = 'Wednesday';
        s.Date__c = date.newInstance(2019, 8, 28);
        update s;

        delete s;

    }

}
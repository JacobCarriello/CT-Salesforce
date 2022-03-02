@isTest
public class TimesheetEntryTrigger_Test {
    @isTest
    public static void testTimesheetEntryTrigger() {
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        insert timesheet;

        NG_Timesheet_Entry__c entry = new NG_Timesheet_Entry__c();
        entry.Timesheet__c = timesheet.Id;
        insert entry;

        update entry;

        delete entry;
    }
}
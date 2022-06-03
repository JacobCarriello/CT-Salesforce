@isTest
public class TimesheetEntryHelper_Test {
    @isTest
    public static void testTimesheetEntryHelper() {

        TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        NG_Timesheet_Entry__c e = new NG_Timesheet_Entry__c();
        e.Timesheet__c = timesheets[0].Id;
        e.Date__c = date.today();
        insert e;

        e.Date__c = date.today().addDays(-1);
        update e;

        delete e;

    }

}
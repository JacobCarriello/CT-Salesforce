@isTest
public class TimesheetHelper_Test {
    @isTest
    public static void testTimesheetHelper() {

        TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c trt = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        NG_Timesheet__c t = timesheets[0];
        t.Name = 'Testing update';
        update t;

        delete t;

    }
}
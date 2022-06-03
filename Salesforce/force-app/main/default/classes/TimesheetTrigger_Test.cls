@isTest
public class TimesheetTrigger_Test {
    @isTest
    public static void testTimesheetTrigger() {
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        insert timesheet;

        update timesheet;

        delete timesheet;
    }
}
@isTest
public class TimesheetApprovalController_Test {
    @isTest
    public static void testController() {
        TestHelper.setupTriggerHelpers();

        NGCSH__c settings = NGCSH__c.getOrgDefaults();
        settings.TS_Sender_Email__c = 'test@test.com';
        settings.TS_BCC_Addresses__c = 'test2@test.com,test3@test.com';
        upsert settings settings__c.Id;

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        TimesheetApprovalController.timesheetId = timesheets[0].Source_Object_ID__c;

        TimesheetApprovalController ctl = new TimesheetApprovalController();
        ctl.save();
    }
}
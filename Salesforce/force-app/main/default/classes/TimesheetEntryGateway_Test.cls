@isTest
public class TimesheetEntryGateway_Test {
	@isTest
    public static void testDeleteBySourceObjectId() {
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

        TimesheetEntryGateway.deleteBySourceObjectId(e.Source_Object_ID__c);
        
    }
    
    @isTest
    public static void testSynchronize() {
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

        TimesheetEntryGateway.synchronize(timesheets[0], t);        
    }
}
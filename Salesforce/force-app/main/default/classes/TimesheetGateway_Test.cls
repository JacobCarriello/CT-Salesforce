@isTest
public class TimesheetGateway_Test {

    @isTest
    public static void testDeleteBySourceObjectId() {
		TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        TimesheetGateway.deleteBySourceObjectId(t.Id);
        
    }
    
    @isTest
    public static void testCreateDirect() {
		TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);  
        
        TimesheetGateway.createDirect(t);
    }
    
    @isTest
    public static void testFetchTimesheetsForContact() {
		TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'All');
        
    }
    
    @isTest
    public static void testSynchronize() {
		TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'All');
        
        List<NG_Timesheet_Entry__c> entries = TimesheetEntryGateway.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        delete entries;
        
        TimesheetGateway.synchronize(t,false);
    }
}
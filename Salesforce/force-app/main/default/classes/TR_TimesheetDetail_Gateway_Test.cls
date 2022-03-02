@isTest
public class TR_TimesheetDetail_Gateway_Test {
    @isTest
    public static void testFetch() {
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        TR1__Timesheet_Detail__c d = TR_TimesheetDetail_Gateway.fetch(MockFactory.TimesheetDetail.Id);

        System.assertEquals(date.today().addDays(-1), d.TR1__Date__c);

        TR_TimesheetDetail_Gateway.save(d);
    }
    
    @isTest
    public static void testFetchTimesheetDetailsForTimesheetId() {
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<TR1__Timesheet_Detail__c> d = TR_TimesheetDetail_Gateway.fetchTimesheetDetailsForTimesheetId(t.Id);        
    }
}
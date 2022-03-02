@isTest
public class NG_ScheduleTimesheetApprovalEmail_Tests {
	@isTest
    public static void testExecute() {
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        t.NG_Portal_Status__c = 'Submitted';
        t.NG_Portal_Submitted__c = true;
        update t;
        
        NG_ScheduleTimesheetApprovalEmail schd = new NG_ScheduleTimesheetApprovalEmail();
        schd.execute(null);
        
    }
}
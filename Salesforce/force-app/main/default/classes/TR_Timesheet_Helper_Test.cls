@isTest
public class TR_Timesheet_Helper_Test {
    @isTest
    public static void testTR_Timesheet_Helper() {
        TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);

        t.NG_Portal_Status__c = 'Approved';
        update t;

        delete t;
    }
}
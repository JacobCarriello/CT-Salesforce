@isTest
public class TR_ShiftWork_Helper_Test {
    @isTest
    public static void testTR_Timesheet_Helper() {
        TestHelper.setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        TR1__Rate__c r = MockFactory.createTRRate();

        TR1__ShiftWork__c s = new TR1__ShiftWork__c();
        s.TR1__Timesheet__c = t.Id;
        s.TR1__TimesheetDetail__c = MockFactory.TimesheetDetail.Id;
        s.TR1__Rate__c = r.Id;
        insert s;

        s.TR1__Hours__c = 8;
        update s;

        delete s;
    }
}
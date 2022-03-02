@isTest
public class TR_Timesheet_Gateway_Test {
    @isTest
    public static void testFetchWorkLocationId() {
        Contact c = MockFactory.createContact();
        Account a = MockFactory.createAccount();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        t.Work_Shift_Location__c = a.Id;
        update t;

        Id wkId = TR_Timesheet_Gateway.fetchWorkLocationId(t.Id);
        System.assertEquals(a.Id, wkId);
    }

    @isTest
    public static void testFetch() {
        Contact c = MockFactory.createContact();
        Account a = MockFactory.createAccount();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id); 

        TR1__Timesheet__c t2 = TR_Timesheet_Gateway.fetch(t.Id);
        System.assert(t2 != null);
              
    }
}
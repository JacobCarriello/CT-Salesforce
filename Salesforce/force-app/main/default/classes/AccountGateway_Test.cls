@isTest
public class AccountGateway_Test {
    @isTest
    public static void testGetName() {
        Account a = MockFactory.createAccount();

        string acctName = AccountGateway.getName(a.Id);
        System.assertEquals(a.Name, acctName);

        acctName = AccountGateway.getName('001S0000012PpWj');
        System.assert(acctName == null);
    }
}
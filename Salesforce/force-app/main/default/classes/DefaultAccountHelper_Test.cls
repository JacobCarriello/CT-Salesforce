@isTest
public class DefaultAccountHelper_Test {
    @isTest
    public static void testDefaultAccountHelper() {

        TestHelper.setupTriggerHelpers();

        //exercise triggers
        Account a = new Account();
        a.Name = 'Testing';
        insert a;

        a.Name = 'Testing update';
        update a;

        delete a;

    }
}
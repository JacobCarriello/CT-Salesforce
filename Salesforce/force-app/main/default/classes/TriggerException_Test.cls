@isTest
public class TriggerException_Test {
    @isTest
    public static void testTriggerException() {
        try {
            TriggerFactory.createHandler(Contact.sObjectType);
            System.assert(false);
        }
        catch(TriggerException e) {
            System.assert(true);
        }
    }
}
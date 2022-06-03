@isTest
public class Utilities_Test {
    @isTest
    public static void testGetBaseUrl() {
        string url = Utilities.GetBaseUrl();
        System.assert(url != null);
    }

    @isTest
    public static void testGetContactIdFromUser() {
        string contactId = Utilities.GetContactIdFromUser();
    }
}
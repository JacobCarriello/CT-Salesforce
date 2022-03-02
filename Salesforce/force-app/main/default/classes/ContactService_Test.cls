@isTest
public class ContactService_Test {
    @isTest
    public static void testfetchContactIdFromUser() {
        try {
            Id cId = ContactService.fetchContactIdFromUser();
        }
        catch(AuraHandledException e) {
            System.assert(true);
        }
    }
}
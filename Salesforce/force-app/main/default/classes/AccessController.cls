public without sharing class AccessController {

    public static List<sObject> queryWithoutSharing(String query) {
        return Database.query(query);
    }

    public static Database.QueryLocator getQueryLocatorWithoutSharing(String query) {
        return Database.getQueryLocator(query);
    }

    public static List<Contact> selectContactsByFirstNameAndEmailWithoutSharing(String email, String firstName) {
        return [select id, AccountId from Contact where firstname =: firstName and (email =: email or TR1__Secondary_Email__c =: email)];
    }

    public static TR1.Candidate callCreateUpdateContactWithoutSharing(Attachment resume, String sessionId) {
        return TR1.ResumeProcessor.createUpdateContact(resume, sessionId);
    }

    public static TR1.Candidate callPerformDMLWithoutSharing(TR1.Candidate candt) {
        return TR1.ResumeProcessor.performDML(candt);
    }

    public static void insertWithoutSharing(sObject sObj2Insert) {
        Database.insert(sObj2Insert);
    }

    public static void upsertWithoutSharing(sObject sObj2Upsert) {
        Database.upsert(sObj2Upsert);
    }

    public static void updateWithoutSharing(sObject sObj2Update) {
        Database.update(sObj2Update);
    }
    
     public static Boolean isContactOwnerGuest(Id contactId) {
        return [SELECT Id FROM Contact WHERE Id =: contactId AND Owner.Profile.UserLicense.Name like '%guest%'].size() > 0;
    }
    
}
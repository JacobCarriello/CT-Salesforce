@isTest
private class ReassignGuestOwnershipBatchTest {

    @testSetup
    private static void createRecordsToConvert(){
        List<Profile> guestProfileList = [
            SELECT Id, Name, UserLicense.Name
            FROM Profile
            WHERE UserLicense.Name LIKE 'Guest%'
            LIMIT 1
        ];

        List<User> usersToCreateList = new List<User>();
        User guestUser = new User(
                Username ='connexys.site.user@test.com',
                Lastname ='ConvertSiteUser',
                Email='convert.site.user@test.com',
                Alias='GuestU',
                TimeZoneSidKey='America/Los_Angeles',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                ProfileId= guestProfileList.get(0).Id,
                LanguageLocaleKey='en_US',
                IsActive = true
        );
        insert guestUser;

        Contact guestContact = new Contact();
        guestContact.LastName = 'Test';
        guestContact.OwnerId = guestUser.Id;
        insert guestContact;
    }

    @isTest
    private static void runQueueableJob(){
        Map<Id, Profile> profileMap = new Map<Id, Profile>([
            SELECT Id
            FROM Profile
            WHERE UserLicense.Name LIKE 'Guest%'
        ]);
        Set<Id> guestProfileIdSet = profileMap.keySet();

        Map<Id, User> guestUserMap = new Map<Id, User>([
            SELECT Id
            FROM User
            WHERE IsActive = true
            AND ProfileId IN :guestProfileIdSet
        ]);

        Test.startTest();
        ReassignGuestOwnershipBatch qBatch = new ReassignGuestOwnershipBatch(new List<String>{'Contact'}, 0, guestUserMap.keySet(), UserInfo.getUserId(), 1000);
        Database.executeBatch(qBatch, 1000);
        Test.stopTest();

        List<Contact> afterUpdate = [SELECT Id FROM Contact WHERE OwnerId = :UserInfo.getUserId()];
        system.assertEquals(1, afterUpdate.size(), 'All records should be reassigned');
    }

//    @isTest
//    private static void RunQueueableJobWithErrors(){
//        Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id FROM Profile WHERE UserLicense.Name = 'Guest']);
//        Set<Id> guestProfileIdSet = profileMap.keySet();
//        Map<Id, User> guestUserMap = new Map<Id, User>([SELECT Id FROM User WHERE IsActive = true AND ProfileId IN :guestProfileIdSet]);
//
//        List<Profile> restrictedProfileList = [SELECT Id FROM Profile WHERE Name = 'Recruiter (beperkt)'];
//        User restrictedUser = new User(
//                Username ='connexys.restricted.user@bullhorn.com',
//                Lastname ='RestrictedUser',
//                Email='restricted.user@test.com',
//                Alias='RestrU',
//                TimeZoneSidKey='America/Los_Angeles',
//                LocaleSidKey='en_US',
//                EmailEncodingKey='UTF-8',
//                ProfileId= restrictedProfileList.get(0).Id,
//                LanguageLocaleKey='en_US',
//                IsActive = true
//        );
//        insert restrictedUser;
//
//        Test.startTest();
//        cxsSetupConvertSiteUserQueueable qBatch = new cxsSetupConvertSiteUserQueueable(new List<String>{cxsCoreUtil.getPackagePrefix() + 'cxsEmail__c'}, 0, guestUserMap.keySet(), restrictedUser.Id, 1000);
//        Database.executeBatch(qBatch, 1000);
//        Test.stopTest();
//
//        String source = 'cxsSetupConvertUser#' + cxsCoreUtil.getPackagePrefix() + 'cxsEmail__c';
//        List<cxsDebug_Log__c> debugLogList = [SELECT Id FROM cxsDebug_Log__c WHERE Source__c = :source];
//        system.assertEquals(1, debugLogList.size(), 'There should be one debug log record for the cxsEmail object');
//    }

}
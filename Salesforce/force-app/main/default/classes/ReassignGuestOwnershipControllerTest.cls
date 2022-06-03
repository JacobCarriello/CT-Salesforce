@isTest
public with sharing class ReassignGuestOwnershipControllerTest {

    @testSetup
    private static void createRecordsToConvert(){
        List<Profile> guestProfileList = [
            SELECT Id, Name
            FROM Profile
            WHERE UserLicense.Name LIKE 'Guest%'
            LIMIT 1
        ];

        List<User> userList = new List<User>();
        User guestUser = new User(
                Username ='connexys.convert.user@bullhorn.com',
                Lastname ='ConvertSiteUser',
                Email='convert.site.user@test.com',
                Alias='GuestU',
                TimeZoneSidKey='America/Los_Angeles',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                ProfileId= guestProfileList.get(0).Id ,
                LanguageLocaleKey='en_US',
                IsActive = true
        );
        userList.add(guestUser);

        User secondUser = new User(
                Username ='connexys.convert.second.user@bullhorn.com',
                Lastname ='SecondUser',
                Email='second.user@test.com',
                Alias='SecondU',
                TimeZoneSidKey='America/Los_Angeles',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                ProfileId= UserInfo.getProfileId(),
                LanguageLocaleKey='en_US',
                IsActive = true
        );
        userList.add(secondUser);
        insert userList;

        Contact guestContact = new Contact();
        guestContact.LastName = 'Test';
        guestContact.OwnerId = guestUser.Id;
        insert guestContact;
    }

    @isTest
    private static void testAvailableConvertedRecords(){

        Test.startTest();
        Test.setCurrentPage(Page.ReassignGuestOwnership);
        ReassignGuestOwnershipController contr = new ReassignGuestOwnershipController();
        contr.userId = [SELECT Id FROM User WHERE LastName = 'SecondUser' LIMIT 1].Id;
        contr.selectedBatchSize = '50';
        contr.jobIsRunning = false;
        contr.selectedObjectApiName = 'Contact';
        contr.ConvertSiteUserOwnership();
        contr.RecalculateConvertObjects();
        Set<Id> guestIds = new Set<Id>();
        guestIds.add([SELECT Id FROM User WHERE LastName = 'ConvertSiteUser' LIMIT 1].Id);
        contr.GetObjectRecordCount('Contact', guestIds);
        contr.RevealRecordCount();
        Test.stopTest();

    }

    @isTest
    private static void testLookup() {

        Test.startTest();
        Test.setCurrentPage(Page.ReassignGuestOwnership);
        ReassignGuestOwnershipController contr = new ReassignGuestOwnershipController();
        contr.userId = [SELECT Id FROM User WHERE LastName = 'SecondUser' LIMIT 1].Id;
        contr.userName = 'SecondUser';
        contr.callLookup();
        contr.goBack();
        Test.stopTest();
    }

}
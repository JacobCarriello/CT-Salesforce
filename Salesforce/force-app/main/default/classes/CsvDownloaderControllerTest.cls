@isTest
private class CsvDownloaderControllerTest {
	@testSetup
    private static void createRecordsForCSVDownloader(){
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
        
        Attachment guestAttachment = new Attachment();
        guestAttachment.Body = blob.valueOf('This is Test Resume');
        guestAttachment.Name = 'attachmentName';
        guestAttachment.ParentID = guestContact.id;
        guestAttachment.OwnerId = guestUser.Id;
        insert guestAttachment;
    }
    
    @isTest
    private static void getContactsCSV(){
        Test.setCurrentPage(Page.CsvDownloader);
        ApexPages.currentPage().getParameters().put('objType','Contacts');
        CsvDownloaderController csvCtrl = new CsvDownloaderController();
        System.assert(csvCtrl.csvBody != NULL, 'CSV is blunk');
    }
    
    @isTest
    private static void getAttachmentsCSV(){
        Test.setCurrentPage(Page.CsvDownloader);
        ApexPages.currentPage().getParameters().put('objType','Attachments');
        CsvDownloaderController csvCtrl = new CsvDownloaderController();
        System.assert(csvCtrl.csvBody != NULL, 'CSV is blunk');
    }
}
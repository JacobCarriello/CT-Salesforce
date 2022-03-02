public with sharing class RC_Test_Utility {
    
    public static Account objAccount {get;set;}
    public static Contact objContact {get;set;}
    public static User objUser {get;set;}
    
    
    //Constructor
    public RC_Test_Utility() {
        //Do Nothing
    }

    //Creating user for Test Class coverage
    public static void createUser(){
		// for Custom setting object, have necessary value for candidate registration
        Candidate_Community__c objCustomSettingForCandidate = Candidate_Community__c.getValues('RegistrationDetail');
        objAccount = new Account(Name = 'John Family',
                                         BillingStreet = '11804 Barletta Place',
                                         BillingState = 'CALIFORNIA',
                                         BillingPostalCode ='93021' ,
                                         BillingCountry = 'USA',
                                         BillingCity = 'Moorpark');
        
        insert objAccount;
        
        objContact =new Contact(AccountId = objAccount.Id,
                                        LastName = 'Test',
                                        MobilePhone = '1283746',
                                        Email = 'test@test.com');
        insert objContact;
        
        Profile aProfile = [select Id from Profile where Name ='Recruitment Community User'];
        
        objUser = new User(Username = 'test@salesforce.com',
                                 LastName = 'test'  + System.now().millisecond() ,
                                 ProfileId = aProfile.Id,
                                 Email = 'test.dev'  + System.now().millisecond() + '@test.com',
                                 Alias = 'tdev',
                                 ContactId = objContact.Id, 
                                 CommunityNickname = 'header',
                                 IsActive = true,
                                 TimeZoneSidKey = 'Asia/Tokyo',
                                 LocaleSidKey = 'ja_JP',
                                 ReceivesInfoEmails = false,
                                 ReceivesAdminInfoEmails = false,
                                 EmailEncodingKey = 'Shift_JIS',
                                 LanguageLocaleKey = 'ja');        

    }

}
@isTest
private class RC_CandidateRegistrationTest {

    static testMethod void CandidateRegistrationTest() 
    {
        Account objAcc = new Account (Name = 'newAcc1');    
        insert objAcc;
        
        Contact objContact1 = new Contact (AccountId = objAcc.id, FirstName = 'Test1', LastName = 'Conatct1', Email = 'test@testuser.com');
        insert objContact1;
        Contact objContact2 = new Contact (AccountId = objAcc.id, FirstName = 'Test2', LastName = 'Conatct2');
        insert objContact2; 
        
        
        TR1__RC_Article__c objArticle = new TR1__RC_Article__c(TR1__Category__c = 'Staffing', TR1__Content__c='Test Content', TR1__Title__c = 'Test title'); 
        insert objArticle ;
        Candidate_Community__c objCommunity = new Candidate_Community__c(Name = 'RegistrationDetail', Profile__c = 'Recruitment Community User',
                                                                        Username_suffix__c = '@tr-community.com', LogoDocumentId__c = objArticle.id,
                                                                        Include_Stages__c = 'Application,Submittal', Auto_Create_Community_Login__c = true
                                                                        );
        insert objCommunity; 
        
        TR1__TalentRoverProperties__c objCSTR = TR1__TalentRoverProperties__c.getInstance();  
        objCSTR.TR1__Default_Account__c = objAcc.id;
        insert objCSTR;
        
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment objAttachment = new Attachment(Name='Unit Test Attachment', body=bodyBlob, ParentId = objContact1.id); 
        insert objAttachment;
        
        Test.startTest();
        
                RC_CandidateRegistration objRegistration = new RC_CandidateRegistration();
                objRegistration.conEmail = 'Test';
                objRegistration.contactLastName = 'Test';
                objRegistration.contactFirstName ='Test'; 
                objRegistration.contactEmail = 'Test';
                objRegistration.contactOnly = false;
                
                objRegistration.password = 'Test';
                objRegistration.contactId = objContact1.Id;
                objRegistration.objContact = objContact1;
                system.assertEquals(objContact1.Id, objRegistration.contactId);
                system.assertEquals(true, [Select Auto_Create_Community_Login__c from Candidate_Community__c where Id =: objCommunity.Id].Auto_Create_Community_Login__c);
                
              
                //PageReference pg = objRegistration.createCommunityUser();
                //System.assertEquals(null,pg);
                ApexPages.currentPage().getParameters().put('cid',objContact1.id);
                objRegistration.getContact(); 
                PageReference  pg = objRegistration.registerCandidateUser(); 
                System.assertEquals(null,pg);
                
                update objContact2;
                objRegistration.objContact = objContact1;
                objRegistration.registerCandidateUser();
                update objContact2;
                objRegistration.objContact = objContact1;
                objRegistration.registerCandidateUser();
            
        Test.stopTest();
    }
    
}
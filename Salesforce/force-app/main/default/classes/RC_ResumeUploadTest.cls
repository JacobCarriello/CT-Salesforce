@isTest
private class RC_ResumeUploadTest 
{
    private static testMethod void uploadAsGuestUser() 
    {
        User guestUser = RC_UtilityClass.returnGuestUser();
        
        TR1__TalentRoverProperties__c settings = new TR1__TalentRoverProperties__c();
        settings.Apex_Email_Service__c = 'test@gmail.com';
        insert settings;
        
        System.runAs(guestUser)
        {
            ApexPages.currentPage().getParameters().put('success', 'false');
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            RC_ResumeUpload objResumeUpload = new RC_ResumeUpload();
            objResumeUpload.objAttachment.Name = 'TestAttachment';
            objResumeUpload.objAttachment.body = bodyBlob;
            System.assertEquals(objResumeUpload.success,'false');
            PageReference pg = objResumeUpload.insertContent();  
            System.assertEquals('/ResumeUpload?Success=false&UserExist=false',pg.getURL());  
        }
        
    }
    
    private static testMethod void uploadAsCommunityUser() 
    {
        User communityUser = RC_UtilityClass.returnCommunityUser();
        
        TR1__TalentRoverProperties__c settings = new TR1__TalentRoverProperties__c();
        settings.Apex_Email_Service__c = 'test@gmail.com';
        insert settings;
        
        System.runAs(communityUser)
        {
            Contact currentUserContact = [Select Id, TR1__External_Candidate_Id__c From Contact Where Id =: communityUser.ContactId];
            currentUserContact.TR1__External_Candidate_Id__c = '000';
            RC_AccessController.updateRecord(currentUserContact);
            
            TR1__ContactDocument__c currentUserContactDoc = new TR1__ContactDocument__c(Name = 'Test', TR1__Contact__c = currentUserContact.Id);
            insert currentUserContactDoc;
            
            ApexPages.currentPage().getParameters().put('success', 'false');
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            RC_ResumeUpload objResumeUpload = new RC_ResumeUpload();
            objResumeUpload.objAttachment.Name = 'TestAttachment';
            objResumeUpload.objAttachment.body = bodyBlob;
            System.assertEquals(objResumeUpload.success,'false');
            System.assertEquals(1, (RC_AccessController.query('Select Id From TR1__ContactDocument__c')).size());
            PageReference pg = objResumeUpload.insertContent();
            System.assertEquals(0, (RC_AccessController.query('Select Id From TR1__ContactDocument__c')).size());
            System.assertNotEquals('/ResumeUpload?Success=uploaded&UserExist=true',pg.getURL());
            System.debug('Final URL ' + pg.getURL());
        }  
    }
}
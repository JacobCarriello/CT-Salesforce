@isTest
private class DocusignRecipientStatusBatchUpdateTest {
    
     static testmethod void testMedestarTemplateController(){
     	Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        List<Contact> listContacts = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId =acc.id;
        con.Birthdate =system.today();
        con.Salutation = 'Mr';
        con.FirstName = 'test';
        con.TR1__Client_Status__c = 'Active';
        con.Phone = '9456135780';
        con.Email = 'testEmail@email.com';
        listContacts.add(con);
        
        Contact con2 = new Contact();
        con2.LastName = 'test2';
        con2.AccountId =acc.id;
        con2.Birthdate =system.today();
        con2.Salutation = 'Mrs';
        con2.FirstName = 'testing';
        con2.TR1__Client_Status__c = 'Active';
        con2.Phone = '9456135781';
        con2.Email = 'testEmail2345678@email.com';
        listContacts.add(con2);
        
        insert listContacts;
        
        dsfs__DocuSign_Status__c docStatus = new dsfs__DocuSign_Status__c();
        docStatus.dsfs__DocuSign_Envelope_ID__c = '3434-34343dasfdpere-32rkkfljdsf';
        docStatus.dsfs__Subject__c = 'Test Subject';
        
        insert docStatus;
        
        
        List<dsfs__DocuSign_Recipient_Status__c> docusignRecepientStatuses = new List<dsfs__DocuSign_Recipient_Status__c>();
        dsfs__DocuSign_Recipient_Status__c status = new dsfs__DocuSign_Recipient_Status__c();
        status.dsfs__DocuSign_Recipient_Id__c = 'dfjsadkjdlf87f8ksjdflksd8u9077977';
        status.dsfs__DocuSign_Recipient_Email__c = 'testEmail@email.com';
        status.dsfs__Envelope_Id__c = '3434-34343dasfdpere-32rkkfljdsf';
        status.dsfs__Parent_Status_Record__c = docStatus.id;
        docusignRecepientStatuses.add(status);
        
        dsfs__DocuSign_Recipient_Status__c status2 = new dsfs__DocuSign_Recipient_Status__c();
        status2.dsfs__DocuSign_Recipient_Id__c = 'dfjsadkjdlf8dfklljsdkj34';
        status2.dsfs__DocuSign_Recipient_Email__c = 'testEmailxyz@email.com';
        status2.dsfs__Envelope_Id__c = '3434-34343dasfdpere-32rkkfljdsf';
        status2.dsfs__Parent_Status_Record__c = docStatus.id;
        docusignRecepientStatuses.add(status2);
        
        insert docusignRecepientStatuses;
        
        Test.StartTest();
        DocusignRecipientStatusBatchUpdate batchObj = new DocusignRecipientStatusBatchUpdate();
        Database.executeBatch(batchObj, 500);      
        Test.stopTest();
     }
}
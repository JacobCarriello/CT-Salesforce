@isTest
public class RC_ContactDocumentEmailHandler_Test{

    static testMethod void myTestMethod() {

       // Create a new email, envelope object and Attachment
       Messaging.InboundEmail email = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
       email.subject = 'test';
       env.fromAddress = 'user@acme.com';
       
       system.assertEquals(email.subject,'test');
      
       // call the class and test it with the data in the testMethod
       RC_ContactDocumentEmailHandler emailServiceObj = new RC_ContactDocumentEmailHandler();
       emailServiceObj.handleInboundEmail(email,env);          
      
       
       system.assertEquals(email.subject,'test');
       system.assertEquals(env.fromAddress,'user@acme.com');
       
     /*  TR1__ContactDocument__c conDocument = new TR1__ContactDocument__c();
       conDocument.Name= 'Test Contact Document';
       conDocument.TR1__isDefault__c = true;
       conDocument.TR1__Contact__c = email.subject;
       update conDocument;*/
       
                   
}    



}
@isTest
global class Test_ResumeEmailHandler_V1 {
    
    @isTest static void testEmailHandler(){
        Account acc = new Account(Name='CVP11');
        insert acc;
       	Contact con = new Contact(LastName = 'CVP Contact11', Email = 'test@test.com', FirstName = 'test');
        insert con;
      
        Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        TR1__Job__c job1 = new TR1__Job__c(RecordTypeId=consultingid,TR1__Account__c=acc.Id,Name='Job 2',TR1__Contact__c=con.Id);    
        insert job1;
        
        string subject = 'TestCndiate/test/'+job1.TR1__Job_Number__c+'/Indeed/test/green';
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestCndiate/test/'+job1.TR1__Job_Number__c+'/Indeed/test/green';
        email.fromname = 'FirstName LastName';
        email.htmlbody='[{"phonehome": “1112221”,”phonemobile": “223332”,”firstname": “Tony123“,”lastname": “Stark123”,”function": "Chemical","experiencelevel": "APAC","primarybackground": "Electrical","certifications": "ASCP","additionalbackground": "ClientServicesManagement-ClientServices","languages": "English","email": “testtony123@gmail.com”,”secondarybackground": "CustomerSuccess-ClientServices","systemsexperience": "AERS","Source":"Indeed"}]';
        email.plainTextBody = 'Resume Attached';
        env.fromAddress = 'someaddress@email.com';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('NAme my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        ResumeEmailHandlerV1 emailProc=new ResumeEmailHandlerV1();
        emailProc.handleInboundEmail(email, env);
        emailProc.parseEmailSubject(subject,con.id);
    }
}
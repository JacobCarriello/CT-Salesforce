@isTest
private class CloneAssociatedQualificationsTest {
     
     static testmethod void testCloneAQ(){
     	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser1569@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, FirstName='Test',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1549@testorg.com');
        insert u;

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
		
		TR1__Qualification__c objQualification = new TR1__Qualification__c(Name='Test-Qualification',TR1__Docusign_Template_ID__c='testDSID',TR1__Collection_Methods__c='Docusign',TR1__Field_Set_ID__c='Resume');        
        insert objQualification;
		
		TR1__Associated_Qualification__c objAssociatedQualification = new TR1__Associated_Qualification__c(TR1__Qualification__c = objQualification.Id,Account__c = acc.id);
        insert objAssociatedQualification;

        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId =acc.id;
        con.Birthdate =system.today();
        con.Salutation = 'Mr';
        con.FirstName = 'test';
        con.TR1__Client_Status__c = 'Active';
        con.Phone = '9456135746';
        insert con;

        Id rtj = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
        TR1__Job__c job = new TR1__Job__c();
        job.Name = 'test';
        job.RecordTypeId = rtj;
        job.TR1__Hiring_Manager__c = con.id;
        job.TR1__Status__c = 'Archived';
        job.TR1__Estimated_Start_Date__c = system.today();
        job.TR1__Open_Date__c = system.today();
        job.TR1__Account__c = acc.Id;
        insert job;

        Id rtcl = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
       
        TR1__Closing_Report__c cr = new TR1__Closing_Report__c();
        cr.RecordTypeId = rtcl;
        cr.TR1__Job__c = job.id;
        cr.TR1__Person_Placed__c = con.id;
        cr.TR1__Start_Date__c = system.today().addDays(10);
        cr.TR1__Salary__c = 10;
        cr.TR1__Fee_Percentage__c = 10;
        cr.TR1__Job_Percentage__c = 100;
        cr.TR1__Job_Credit__c = u.Id;
        cr.TR1__Timesheet_Approver__c = con.Id;
        cr.TR1__Account__c = acc.Id;
        insert cr;

        test.startTest();
            PageReference pg = Page.CloneAssociatedQualifications;
            Test.setCurrentPageReference(pg);

            ApexPages.currentPage().getParameters().put('Id', job.id);
            ApexPages.currentPage().getParameters().put('ParentId', job.TR1__Account__c);
            CloneAssociatedQualificationsController controllerObj = new CloneAssociatedQualificationsController();
            List<CloneAssociatedQualificationsController.AssociatedQualificationWrapper> listAssociatedQualifications = controllerObj.getAllAssociatedQualificationsOnParent();

            for(CloneAssociatedQualificationsController.AssociatedQualificationWrapper objAQ : listAssociatedQualifications) {
                objAQ.isSelected = true;
            }

            controllerObj.cloneAssociatedQualificationRecords();

            
            ApexPages.currentPage().getParameters().put('Id', cr.Id);
            ApexPages.currentPage().getParameters().put('ParentId', cr.TR1__Job__c);
            CloneAssociatedQualificationsController controllerObj2 = new CloneAssociatedQualificationsController();
            List<CloneAssociatedQualificationsController.AssociatedQualificationWrapper> listAssociatedQualifications2 = controllerObj2.getAllAssociatedQualificationsOnParent();

            for(CloneAssociatedQualificationsController.AssociatedQualificationWrapper objAQ : listAssociatedQualifications2) {
                objAQ.isSelected = true;
            }

            controllerObj2.cloneAssociatedQualificationRecords();

            ApexPages.currentPage().getParameters().put('Id', con.Id);
            ApexPages.currentPage().getParameters().put('ParentId', acc.id);
            CloneAssociatedQualificationsController controllerObj3 = new CloneAssociatedQualificationsController();
            List<CloneAssociatedQualificationsController.AssociatedQualificationWrapper> listAssociatedQualifications3 = controllerObj3.getAllAssociatedQualificationsOnParent();

            for(CloneAssociatedQualificationsController.AssociatedQualificationWrapper objAQ : listAssociatedQualifications3) {
                objAQ.isSelected = true;
            }

            controllerObj3.cloneAssociatedQualificationRecords();
		Test.stopTest();
     }
}
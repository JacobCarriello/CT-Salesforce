@isTest
private class MedestarTemplateControllerTest {
    static testmethod void testMedestarTemplateController(){
        
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
        
        TRSCHED__Vacancy_D2D__c vs = new TRSCHED__Vacancy_D2D__c();
        vs.TRSCHED__Vacancy__c = job.id;
        vs.TRSCHED__Work_Shift_Location_lkId__c = job.TR1__Account__c;
        vs.TRSCHED__Vacancy_Date__c = Date.Today(); 
        vs.TRSCHED__Start_Date_Time__c = DateTime.now().addDays(2);
        vs.TRSCHED__End_Date_Time__c = DateTime.now().addDays(2);
        insert vs;
        
        TRSCHED__Closing_Report_Schedule__c crs = new TRSCHED__Closing_Report_Schedule__c();
        crs.TRSCHED__Closing_Report__c = cr.id;
        crs.TRSCHED__Work_Shift_Location_lkId__c = job.TR1__Account__c;
        crs.TRSCHED__Vacancy_Schedule__c = vs.id;
        crs.TRSCHED__Job_s_account__c = job.TR1__Account__c;
        crs.TRSCHED__Schedule_Date__c = Date.Today().addDays(2);
        insert crs;
        
        Test.startTest();
        MedestarTemplateController controller = new MedestarTemplateController();
        controller.closingReportId = cr.id;
        
        MedestarWebService.sendConfirmation(cr.id, 'Medestar_Client_Confirmation_Last_Sent__c');
        MedestarWebService.sendConfirmation(cr.id, 'Medestar_Candidate_Confirmation_LastSent__c');
        
        for(Integer i = 2; i <= 12 ; i++){
            MedestarTemplateController.getMonthName(i);
        }
        Test.stopTest();
    }
}
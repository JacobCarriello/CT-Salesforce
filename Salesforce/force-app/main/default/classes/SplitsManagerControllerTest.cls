@isTest 
private class SplitsManagerControllerTest {
    
    //test method to test the controller
    private static testMethod void testSplitsManagerControllerForClosingReport(){
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Con');
        insert con;
        
        TR1__Job__c Job = new TR1__Job__c();
        Job.TR1__Account__c = acc.id;
        Job.TR1__Sourcing_Recruiter__c = UserInfo.getUserId();
        insert Job;
        
        TR1__Send_Out__c sendout = new TR1__Send_Out__c();
        sendout.TR1__Job__c = Job.id;
        insert sendout;
        
        TR1__Send_Out_Schedule__c sch = new TR1__Send_Out_Schedule__c();
        sch.TR1__Interviewee__c = con.id;
        sch.TR1__Send_Out__c = sendout.id;
        sch.Split_Recruiter__c = UserInfo.getUserId();
        sch.TR1__Date__c = Date.today();
        sch.TR1__Account__c = Job.TR1__Account__c;
        sch.TR1__Account_Contact__c = con.Id;
        sch.TR1__Location__c = 'Location';
        sch.TR1__Time__c = '10:30';
        sch.TR1__Job__c = Job.id;
        insert sch;
        
        TR1__Closing_Report__c cr = new TR1__Closing_Report__c();
        cr.TR1__Account__c = acc.Id;
        cr.TR1__Start_DAte__c = System.Today();
         cr.TR1__END_DAte__c = System.Today() + 14;
         cr.TR1__Job_Percentage__c =25;
         cr.TR1__Candidate_Percentage__c  =25;
         cr.TR1__Marketing_Percentage__c  = 10;
         cr.TR1__Other_Percentage__c  =20;
         cr.TR1__Other2_Percentage__c =20;
         cr.TR1__Generate_Timesheet__c = true;
         cr.TR1__Job__c = Job.Id;
         cr.TR1__Rate_Change_Effective_Date__c = System.Today();
         cr.TR1__Conversion_Date__c = System.Today() +14 ;
         cr.TR1__Salary__c = 100;
         cr.TR1__Person_Placed__c = con.id;
         insert cr;
         
        Test.setCurrentPage(Page.SplitsManager);
        Apexpages.currentpage().getParameters().put('recordId', cr.id);
        Apexpages.currentpage().getParameters().put('from', 'TR1__Closing_Report__c');
        
        SplitsManagerController controller = new SplitsManagerController();
        controller.addSplitRow();
        controller.cancelAction();
        controller.saveSplitsInformation();
        controller.selectedIndex = '0';
        controller.removeSplitRow();
        
        //assertion
        System.assertEquals(0, controller.listExistingSplits.size());
    }
    
    private static testMethod void testSplitsManagerControllerForJobLead(){
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        TR1__Job__c Job = new TR1__Job__c();
        Job.TR1__Account__c = acc.id;
        Job.TR1__Sourcing_Recruiter__c = UserInfo.getUserId();
        insert Job;
        
        TR1__Job_Leads__c jobLead = new TR1__Job_Leads__c();
        jobLead.TR1__Account__c = acc.id;
        jobLead.TR1__Job__c = Job.id;
        jobLead.Contract_In_Timestamp__c = System.Now();
        jobLead.of_Months__c = 2;
        jobLead.Non_Physician_of_Months__c = 2;
        insert jobLead;
        
        
        Test.setCurrentPage(Page.SplitsManager);
        Apexpages.currentpage().getParameters().put('recordId', jobLead.id);
        Apexpages.currentpage().getParameters().put('from', 'TR1__Job_Leads__c');
        
        SplitsManagerController controller = new SplitsManagerController();
        controller.addSplitRow();
        controller.cancelAction();
        
        for(Split__c split : controller.listExistingSplits){
            split.User__c = UserInfo.getUserId();
            split.Split_Percentage__c = 100;
        }        
        controller.saveSplitsInformation();
        controller.selectedIndex = '0';
        controller.removeSplitRow();
        
        //assertion
        System.assertEquals(0, controller.listExistingSplits.size());
    }
}
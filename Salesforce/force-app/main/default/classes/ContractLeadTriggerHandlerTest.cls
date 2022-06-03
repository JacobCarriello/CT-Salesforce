@isTest	
private class ContractLeadTriggerHandlerTest {
	
	private static testMethod void checkSplitCreditsCreation(){
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
        jobLead.of_Months__c = 5;
        //jobLead.Non_Physician_of_Months__c = 5;
        jobLead.Contract_In_Timestamp__c = System.Now();
        insert jobLead;
        
        Split__c split = new Split__c();
        split.User__c = UserInfo.getUserId();
        split.Split_Percentage__c = 100;
        split.Job_Lead__c = jobLead.id;
        insert split;
        
        Test.startTest();
        jobLead.Non_Physician_of_Months__c = 5;
        update jobLead;
        Test.stopTest();
        
        //assertion
        System.assertEquals(10, [Select Id from Splits_Credit__c where split__c =: split.id].size());
    }
    
}
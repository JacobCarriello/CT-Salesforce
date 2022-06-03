@isTest
private class ProcurementTriggerHandlerTest {
    static testMethod void testSplitInsertionOnProcurement() {
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        Procurement__c procurement = new Procurement__c();
        procurement.Status__c = 'Won';
        procurement.Package_Type__c = 'Total Reach';
        procurement.Search_Type__c = 'New';
        procurement.Clinic_Caller__c = UserInfo.getUserId();
        procurement.Recruiter__c = UserInfo.getUserId();
        procurement.Marketer__c = UserInfo.getUserId();
        
        insert procurement;
        
        //assert
        //System.assertEquals(3, [Select Id from Split__c where Procurement__c =: procurement.id].size());
        
    }
}
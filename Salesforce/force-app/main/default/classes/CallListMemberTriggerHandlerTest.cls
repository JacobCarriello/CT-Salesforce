@isTest
private class CallListMemberTriggerHandlerTest
{
	static testMethod void testLastActivityDatePopulate() {
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Con');
        insert con;
        
        Task tsk = new Task();
        tsk.TR1__Call_Type__c = 'Screen';
        tsk.whoId = con.id;
        insert tsk;

        TR1__Call_List__c callList = new TR1__Call_List__c(name = 'test', recordTypeId = Schema.getGlobalDescribe().get('TR1__Call_List__c').getDescribe().getRecordTypeInfosByName().get('Passes List').getRecordTypeId());
        insert callList;

        TR1__Call_List_Member__c callListMember = new TR1__Call_List_Member__c(TR1__Contact__c = con.Id, TR1__Call_List__c = callList.Id);

        Test.startTest();
        	insert callListMember;
        Test.stopTest();
    }
}
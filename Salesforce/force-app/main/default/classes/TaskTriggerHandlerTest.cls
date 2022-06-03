@isTest
private class TaskTriggerHandlerTest {
    static testMethod void testSendScreenTemplate() {
        
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Con');
        insert con;
        
        //insert task
        Task tsk = new Task();
        //tsk.recordTypeId = TaskTriggerHandler.getRecordTypeIdByName('Task', 'Screen');
        tsk.TR1__Call_Type__c = 'Screen';
        tsk.whoId = con.id;
        tsk.activitydate = date.today() + 5;
        Test.startTest();
        insert tsk;
        TR1__Call_List__c callList = new TR1__Call_List__c(name = 'test', recordTypeId = Schema.getGlobalDescribe().get('TR1__Call_List__c').getDescribe().getRecordTypeInfosByName().get('Passes List').getRecordTypeId());
        insert callList;

        TR1__Call_List_Member__c callListMember = new TR1__Call_List_Member__c(TR1__Contact__c = con.Id, TR1__Call_List__c = callList.Id);
        insert callListMember;
        //assert
        System.assertEquals('Completed', [Select status from Task where id = : tsk.id].status);
        Test.stopTest();
    }
    
    static testMethod void testMedastarActivity(){
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Con', Medestar_Recruiter_user__c = UserInfo.getUserId());
        insert con;
        
        //insert task
        Task tsk = new Task();
        //tsk.recordTypeId = TaskTriggerHandler.getRecordTypeIdByName('Task', 'Screen');
        tsk.TR1__Call_Type__c = 'Screen';
        tsk.whoId = con.id;
        tsk.activitydate = date.today() + 5;
        Test.startTest();
        insert tsk;
        TR1__Call_List__c callList = new TR1__Call_List__c(name = 'test', recordTypeId = Schema.getGlobalDescribe().get('TR1__Call_List__c').getDescribe().getRecordTypeInfosByName().get('Passes List').getRecordTypeId());
        insert callList;

        TR1__Call_List_Member__c callListMember = new TR1__Call_List_Member__c(TR1__Contact__c = con.Id, TR1__Call_List__c = callList.Id);
        insert callListMember;
        //assert
        System.assertNotEquals(null, [Select Last_Medestar_Touch__c from Contact where id = : con.id]. Last_Medestar_Touch__c);
        tsk.ActivityDate = date.today();
        update tsk;
        delete tsk;
        Test.stopTest();
    }
}
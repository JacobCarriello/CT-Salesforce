@isTest
private  class CallListGenerationControllerTest {
    
    private static testMethod void testCallListGenerationController1(){
    	Test.startTest();
	    String recordTypeId = CallListGenerationController.getRecordTypeIdbyName('Contact', 'Candidate');
	    Account acc= new Account(Name='Test Account');
	    insert acc;
	    Account acc1 = new Account(Name='Test Account1');
	    insert acc1;
	    
	    //Create the contact test data
	    contact contact = new contact();
	    contact.LastName = 'thomas';
	    contact.Email='test@test.com';
	    contact.AccountId=acc.id;
	    contact.RecordTypeId = recordTypeId;
	    contact.Pass_Date__c = Date.Today().addDays(-60);
	    insert contact;
	    
	    TR1__job__c job = new TR1__job__c();
        job.TR1__Contact__c=contact.id;
        job.TR1__Hiring_Manager__c = contact.id;
        job.TR1__Account__c= acc.id;
        job.TR1__Estimated_Start_Date__c = Date.today();
        job.TR1__Estimated_End_Date__c = Date.Today().addDays(10); 
        job.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__job__c', 'Travelers');
        job.Account_Manager__c = UserInfo.getUserId();
        insert job;
	    
		    TR1__Call_List__c callList2 = new TR1__Call_List__c();
		    callList2.Name = 'TestCallList2';
		    callList2.RecordTypeid = CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List');
		    callList2.Job__c = job.id;
		    callList2.Call_List_Generation_Progress__c = 'In Progress';
		    insert callList2;
		    PageReference pageRef = new PageReference('/apex/CallListGeneration');
	        Test.setCurrentPageReference(pageRef);
	        ApexPages.currentPage().getParameters().put('jobId', job.id);
	        ApexPages.currentPage().getParameters().put('listType', 'Passes_List');
	        CallListGenerationController controller = new CallListGenerationController();
	        //controller.updateCallList();
	        controller.generateCallList();
	        
	        
	        CallListConfigQueryEngine.myMethod(callList2.id);
	        CallListConfigQueryEngine.increase_code_coverage();
        Test.stopTest();
    }
    
    private static testMethod void testCallListGenerationController2(){
    	Test.startTest();
		    String recordTypeId = CallListGenerationController.getRecordTypeIdbyName('Contact', 'Candidate');
		    Account acc= new Account(Name='Test Account');
		    insert acc;
		    Account acc1 = new Account(Name='Test Account1');
		    insert acc1;
		    
		    //Create the contact test data
		    List<Contact> contacts = new List<Contact>();
		    contact contact = new contact();
		    contact.LastName = 'thomas';
		    contact.Email='test@test.com';
		    contact.AccountId=acc.id;
		    contact.RecordTypeId = recordTypeId;
		    contact.Pass_Date__c = Date.Today().addDays(-60);
		    contacts.add(contact);
		    
		    contact contact1 = new contact();
		    contact1.LastName = 'thomas1';
		    contact1.Email='test1@test.com';
		    contact1.AccountId=acc.id;
		    contact1.RecordTypeId = recordTypeId;
		    contact.Pass_Date__c = Date.Today().addDays(-50);
		    contacts.add(contact1);
		    
		    contact contact2 = new contact();
		    contact2.LastName = 'thomas2';
		    contact2.Email='test2@test.com';
		    contact2.AccountId=acc.id;
		    contact2.RecordTypeId = recordTypeId;
		    contact.Pass_Date__c = Date.Today().addDays(-40);
		    contacts.add(contact2);
		    
		    insert contacts;
		    
		    TR1__job__c job = new TR1__job__c();
	        job.TR1__Contact__c=contact.id;
	        job.TR1__Hiring_Manager__c = contact.id;
	        job.TR1__Account__c= acc.id;
	        job.TR1__Estimated_Start_Date__c = Date.today();
	        job.TR1__Estimated_End_Date__c = Date.Today().addDays(10); 
	        job.TR1__Sourcing_Recruiter__c = UserInfo.getUserId();
	        job.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__job__c', 'Fidelis');
	        insert job;
		    PageReference pageRef = new PageReference('/apex/CallListGeneration'); 
	        Test.setCurrentPageReference(pageRef);
	        ApexPages.currentPage().getParameters().put('jobId', job.id);
	        ApexPages.currentPage().getParameters().put('listType', 'Pipeline_List');
	        CallListGenerationController controller = new CallListGenerationController();
	        controller.generateCallList();
	        controller.handleErrors('unexpected token:unexpected token:');
	    	controller.handleErrors('Test Error Message');
    	Test.stopTest();
    }

    private static testMethod void testCallListGenerationController3(){
    	Test.startTest();
	    	String recordTypeId = CallListGenerationController.getRecordTypeIdbyName('Contact', 'Candidate');
		    Account acc= new Account(Name='Test Account');
		    insert acc;
		    //Create the contact test data
		    List<Contact> contacts = new List<Contact>();
		    contact contact = new contact();
		    contact.LastName = 'thomas';
		    contact.Email='test@test.com';
		    contact.AccountId=acc.id;
		    contact.RecordTypeId = recordTypeId;
		    contact.Pass_Date__c = Date.Today().addDays(-60);
		    contacts.add(contact);
		    insert contacts;
		    
		    TR1__job__c job = new TR1__job__c();
	        job.TR1__Contact__c=contact.id;
	        job.TR1__Hiring_Manager__c = contact.id;
	        job.TR1__Account__c= acc.id;
	        job.TR1__Estimated_Start_Date__c = Date.today();
	        job.TR1__Estimated_End_Date__c = Date.Today().addDays(10); 
	        job.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__job__c', 'Travelers');
	        job.Account_Manager__c = UserInfo.getUserId();
	        insert job;
		    
		    List<TR1__Call_List__c> callLists = new List<TR1__Call_List__c>();
		    TR1__Call_List__c callList2 = new TR1__Call_List__c();
		    callList2.Name = 'TestCallList2';
		    callList2.RecordTypeid = CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List');
		    callList2.Job__c = job.id;
		    callList2.Call_List_Generation_Progress__c = 'In Progress';
		    callLists.add(callList2);
		    TR1__Call_List__c callList21 = new TR1__Call_List__c();
		    callList21.Name = 'TestCallList2';
		    callList21.RecordTypeid = CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List');
		    callList21.Job__c = job.id;
		    callList21.Call_List_Generation_Progress__c = 'In Progress';
		    callLists.add(callList21);
		    insert callLists;
		    List<TR1__Call_List_Member__c> callListMemberList = new List<TR1__Call_List_Member__c>();
		    TR1__Call_List_Member__c callListMember1 = new TR1__Call_List_Member__c(TR1__Call_List__c = callLists[0].id, TR1__Contact__c = contacts[0].id, TR1__Call_List_Contact__c = contacts[0].id +'1'+ '-'+callLists[0].id);
		    TR1__Call_List_Member__c callListMember2 = new TR1__Call_List_Member__c(TR1__Call_List__c = callLists[0].id, TR1__Contact__c = contacts[0].id, TR1__Call_List_Contact__c = contacts[0].id+'2'+ '-'+callLists[0].id);
		    TR1__Call_List_Member__c callListMember3 = new TR1__Call_List_Member__c(TR1__Call_List__c = callLists[0].id, TR1__Contact__c = contacts[0].id, TR1__Call_List_Contact__c = contacts[0].id+ '-'+callLists[0].id);
		    callListMemberList.add(callListMember1);
		    callListMemberList.add(callListMember2);
		    callListMemberList.add(callListMember3);
		    insert callListMemberList;
		    PageReference pageRef = new PageReference('/apex/CallListGeneration'); 
	        Test.setCurrentPageReference(pageRef);
	        ApexPages.currentPage().getParameters().put('jobId', job.id);
	        ApexPages.currentPage().getParameters().put('listType', 'Passes_List');
	        CallListGenerationController controller = new CallListGenerationController();
		    controller.updateCallList();
	    Test.stopTest();
    	//Database.executeBatch(new CallListGenerationBatch(callLists[0], 'Select Id from Contact limit 1'), 100);
    }

    private static testMethod void testCallListGenerationController4(){
    	Test.startTest();
	    	String recordTypeId = CallListGenerationController.getRecordTypeIdbyName('Contact', 'Candidate');
		    Account acc= new Account(Name='Test Account');
		    insert acc;
		    //Create the contact test data
		    List<Contact> contacts = new List<Contact>();
		    contact contact = new contact();
		    contact.LastName = 'thomas';
		    contact.Email='test@test.com';
		    contact.AccountId=acc.id;
		    contact.RecordTypeId = recordTypeId;
		    contact.Pass_Date__c = Date.Today().addDays(-60);
		    contacts.add(contact);
		    contact contact1 = new contact();
		    contact1.LastName = 'thomas';
		    contact1.Email='test@test.com';
		    contact1.AccountId=acc.id;
		    contact1.RecordTypeId = recordTypeId;
		    contact1.Pass_Date__c = Date.Today().addDays(-60);
		    contacts.add(contact1);
		    insert contacts;
		    
		    TR1__job__c job = new TR1__job__c();
	        job.TR1__Contact__c=contact.id;
	        job.TR1__Hiring_Manager__c = contact.id;
	        job.TR1__Account__c= acc.id;
	        job.TR1__Estimated_Start_Date__c = Date.today();
	        job.TR1__Estimated_End_Date__c = Date.Today().addDays(10); 
	        job.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__job__c', 'Travelers');
	        job.Account_Manager__c = UserInfo.getUserId();
	        insert job;
		    
		    List<TR1__Call_List__c> callLists = new List<TR1__Call_List__c>();
		    TR1__Call_List__c callList2 = new TR1__Call_List__c();
		    callList2.Name = 'TestCallList2';
		    callList2.RecordTypeid = CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List');
		    callList2.Job__c = job.id;
		    callList2.Call_List_Generation_Progress__c = 'In Progress';
		    callLists.add(callList2);
		    TR1__Call_List__c callList21 = new TR1__Call_List__c();
		    callList21.Name = 'TestCallList2';
		    callList21.RecordTypeid = CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List');
		    callList21.Job__c = job.id;
		    callList21.Call_List_Generation_Progress__c = 'In Progress';
		    callLists.add(callList21);
		    insert callLists;
		    PageReference pageRef = new PageReference('/apex/CallListGeneration'); 
	        Test.setCurrentPageReference(pageRef);
	        ApexPages.currentPage().getParameters().put('jobId', job.id);
	        ApexPages.currentPage().getParameters().put('listType', 'Passes_List');
	        CallListGenerationController controller = new CallListGenerationController();
		    controller.updateCallList();
	    Test.stopTest();
    }
}
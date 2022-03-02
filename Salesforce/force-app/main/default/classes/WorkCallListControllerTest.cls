@isTest	
private class WorkCallListControllerTest {
	
	private static testMethod void testWorkCallList(){
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
        
        insert job;
	    
	    
	    List<TR1__Call_List__c> callLists = new List<TR1__Call_List__c>();
	    
	    TR1__Call_List__c callList1 = new TR1__Call_List__c();
	    callList1.Name = 'TestCallList1';
	    callList1.RecordTypeid = CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List');
	    callList1.Job__c = job.id;
	    callLists.add(callList1);
	    
	    TR1__Call_List__c callList2 = new TR1__Call_List__c();
	    callList2.Name = 'TestCallList2';
	    callList2.RecordTypeid = CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Pipeline List');
	    callList2.Job__c = job.id;
	    callLists.add(callList2);
	    
	    insert callLists;
	    
	    TR1__Call_List_Member__c member = new TR1__Call_List_Member__c();
	    member.TR1__Call_List__c = callList1.id;
	    member.TR1__Contact__c = contact2.id;
	    member.Do_Not_Contact__c = false;
	    insert member;
	    
	    Task tsk = new Task();
	    tsk.Subject = 'tss';
	    tsk.whoId = contact2.id;
	    tsk.whatId = callList1.id;
	    insert tsk;
	    
	    ApexPages.StandardController controller = new ApexPages.StandardController(callList1);
	    WorkCallListController wkController = new WorkCallListController(controller);
	    wkController.save();
	    wkController.getContactWrapper();
	    wkController.refreshPageSize();
	    wkController.retrieveRecordsBasedOnPageNumber();
	    wkController.getTotalPages();
	    wkController.hasNext = true;
	    wkController.hasPrevious = true;
	    Boolean next = wkController.hasNext;
	    Boolean previous = wkController.hasPrevious;
	}
    
}
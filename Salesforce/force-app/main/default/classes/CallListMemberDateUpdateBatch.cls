global class CallListMemberDateUpdateBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global CallListMemberDateUpdateBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<TR1__Call_List__c> callList = [SELECT Id FROM TR1__Call_List__c 
												WHERE (recordtypeId = :TaskTriggerHandler.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List') 
												OR recordtypeId = :TaskTriggerHandler.getRecordTypeIdbyName('TR1__Call_List__c', 'Pipeline List')) 
												AND TR1__Total_Members__c  > 0];
		query = 'SELECT Id, TR1__Contact__c, TR1__Call_List__r.CreatedDate, TR1__Call_List__r.OwnerId  FROM TR1__Call_List_Member__c WHERE TR1__Call_List__c IN :callList AND TR1__Contact__c != null ';										
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		onBeforeInsert((TR1__Call_List_Member__c)scope[0]);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	global static void onBeforeInsert(TR1__Call_List_Member__c newRecords){
        Map<String, Date> contactTaskCreatedDateMap = new Map<String, Date>();
        contactTaskCreatedDateMap.put(newRecords.TR1__Contact__c, null);
		
		//now fetching all the available contacts
        for(Contact con : [SELECT Id, Name, (SELECT Id, ActivityDate 
        					FROM Tasks WHERE OwnerId = :newRecords.TR1__Call_List__r.OwnerId 
        					ORDER BY ActivityDate DESC NULLS LAST limit 1) 
        					FROM Contact 
        					WHERE Id IN :contactTaskCreatedDateMap.keyset()]) {
            if(!con.tasks.isEmpty()) {
                contactTaskCreatedDateMap.put(con.Id, con.tasks[0].ActivityDate);
            }
        }

        system.debug('contactTaskCreatedDateMap ' + contactTaskCreatedDateMap);

        Date taskActivityDate = contactTaskCreatedDateMap.get(newRecords.TR1__Contact__c) != null ? contactTaskCreatedDateMap.get(newRecords.TR1__Contact__c) : null;
        system.debug('taskActivityDate callListmember ' + taskActivityDate);
        Boolean IsCount = taskActivityDate >= newRecords.TR1__Call_List__r.CreatedDate.date();
        system.debug('callListDate callListmember ' + newRecords.TR1__Call_List__r.CreatedDate.date());
        Datetime LatestActivityDate = taskActivityDate != null ? DateTime.newInstance(taskActivityDate.year(), taskActivityDate.month(), taskActivityDate.day()) : null;
        newRecords.Latest_Activity_by_CL_Owner__c = LatestActivityDate;
        newRecords.IsCount_Call_List__c = IsCount;
        system.debug('newRecords ' + newRecords);
        update newRecords;
    }
}
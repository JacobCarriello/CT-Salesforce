global class CallListGenerationBatch implements Database.Batchable<sObject> {
	
	String query;
	TR1__Call_List__c callList;
	
	global CallListGenerationBatch(TR1__Call_List__c callList, String query) {
        this.query = query;
        this.callList = callList;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<TR1__Call_List_Member__c> callListMembersToInsert = new List<TR1__Call_List_Member__c>();
		for(sObject ct : scope){
            callListMembersToInsert.add(new TR1__Call_List_Member__c(TR1__Call_List__c = callList.id, 
                                                                    TR1__Contact__c = ct.id,
                                                                    TR1__Call_List_Contact__c = ct.id + '-' + callList.id));
        }
        upsert callListMembersToInsert TR1__Call_List_Contact__c;
	}
	
	global void finish(Database.BatchableContext BC) {
		callList.Call_List_Generation_Progress__c = 'Completed';
		update callList;
		List<TR1__Call_List__c> callListToUpdate = [SELECT Id, Job__c, Name, RecordTypeId, RecordType.DeveloperName 
														FROM TR1__Call_List__c 
														WHERE (RecordTypeId =  :CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List') 
														OR RecordTypeId =  :CallListGenerationController.getRecordTypeIdbyName('TR1__Call_List__c', 'Pipeline List')) 
														AND Call_List_Generation_Progress__c = 'In Progress' AND Job__c != null Limit 1];
		if(!callListToUpdate.isEmpty()) {
			CallListConfigQueryEngine.populateStringOperatorMap();
	        Map<String, CallListConfigQueryEngine.FieldInfoWrapper> mapContactObjectInfo = CallListConfigQueryEngine.prepareCustomFieldsMapWithAttributes('Contact');
	        Map<String, CallListConfigQueryEngine.FieldInfoWrapper> mapJobObjectInfo = CallListConfigQueryEngine.prepareCustomFieldsMapWithAttributes('TR1__JOB__c');
	        String jobId = callListToUpdate[0].Job__c;
	        String jobQuery = 'Select ' + CallListConfigQueryEngine.prepareCustomFieldsString('TR1__JOB__c') + ', RecordType.Name from TR1__JOB__c where Id =:jobId limit 1';
	        TR1__JOB__c job = Database.query(jobQuery);
	        String finalQuery = CallListConfigQueryEngine.prepareQueryForCallList(callListToUpdate[0].RecordType.DeveloperName, mapContactObjectInfo, mapJobObjectInfo, job);
			Database.executeBatch(new CallListGenerationBatch(callListToUpdate[0], finalQuery), 100);
		}
	}
}
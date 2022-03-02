public with sharing class CallListMemberTriggerHandler {

    //fetching all the call list members and populate the Latest_Activity_by_CL_Owner__c date field with respect to related tasks
    public static void onBeforeInsert(List<TR1__Call_List_Member__c> newRecords){
    	
        Map<String, Date> contactTaskCreatedDateMap = new Map<String, Date>();
        Map<String, TR1__Call_List__c> mapCallLists = new Map<String, TR1__Call_List__c>();
        Set<String> callListMemberIdsToProcess = new Set<String>();
        
        //fetch the call list members
        Set<String> calllistIds = new Set<String>();
        for(TR1__Call_List_Member__c newRecord : newRecords) {
        	calllistIds.add(newRecord.TR1__Call_List__c);
        }
        
        //fetch the call list Data
        for(TR1__Call_List__c callList : [Select CreatedDate, recordTypeId from TR1__Call_List__c 
        									where id in : calllistIds AND  
        									(recordTypeId =: getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List') OR 
        									 recordTypeId =: getRecordTypeIdbyName('TR1__Call_List__c', 'Pipeline List'))]){
        	mapCallLists.put(callList.id, callList);									
		}
		
        for(TR1__Call_List_Member__c newRecord : newRecords) {
            if(newRecord.TR1__Contact__c != null && mapCallLists.containsKey(newRecord.TR1__Call_List__c)){
                contactTaskCreatedDateMap.put(newRecord.TR1__Contact__c, null);
                callListMemberIdsToProcess.add(newRecord.id);
            }
        }
		
		//now fetching all the available contacts
        for(Contact con : [SELECT Id, Name, (SELECT Id, ActivityDate 
        					FROM Tasks WHERE OwnerId = :UserInfo.getUserId() 
        					ORDER BY ActivityDate DESC NULLS LAST limit 1) 
        					FROM Contact 
        					WHERE Id IN :contactTaskCreatedDateMap.keyset()]) {
            if(!con.tasks.isEmpty()) {
                contactTaskCreatedDateMap.put(con.Id, con.tasks[0].ActivityDate);
            }
        }

        system.debug('contactTaskCreatedDateMap ' + contactTaskCreatedDateMap);
        system.debug('mapCallLists ' + mapCallLists);

        for(TR1__Call_List_Member__c newRecord : newRecords) {
        	if(callListMemberIdsToProcess.contains(newRecord.id) && mapCallLists.containsKey(newRecord.TR1__Call_List__c)) {
                Date taskActivityDate = contactTaskCreatedDateMap.get(newRecord.TR1__Contact__c) != null ? contactTaskCreatedDateMap.get(newRecord.TR1__Contact__c) : null;
                system.debug('taskActivityDate callListmember ' + taskActivityDate);
                Boolean IsCount = taskActivityDate >= mapCallLists.get(newRecord.TR1__Call_List__c).CreatedDate.date();
                system.debug('callListDate callListmember ' + mapCallLists.get(newRecord.TR1__Call_List__c).CreatedDate.date());
                Datetime LatestActivityDate = contactTaskCreatedDateMap.get(newRecord.TR1__Contact__c) != null ? DateTime.newInstance(contactTaskCreatedDateMap.get(newRecord.TR1__Contact__c).year(), contactTaskCreatedDateMap.get(newRecord.TR1__Contact__c).month(), contactTaskCreatedDateMap.get(newRecord.TR1__Contact__c).day()) : null;
                //populate the Latest_Activity_by_CL_Owner__c and IsCount_Call_List__c fields
                newRecord.Latest_Activity_by_CL_Owner__c = LatestActivityDate;
                newRecord.IsCount_Call_List__c = IsCount;
        	}
            system.debug('newRecord ' + newRecord);
        }
    }
    
    //method to fetch the record type Id
    public static String getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSobjectResult objTypeDesc = objType.getDescribe();
        Map<String, Schema.RecordTypeInfo> recTypeMap = objTypeDesc.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  recTypeMap.get(strRecordTypeName);
        if(rtByName != null){
            return  rtByName.getRecordTypeId();
        }else{ return null;}
    }

}
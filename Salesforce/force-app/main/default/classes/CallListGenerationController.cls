public  class CallListGenerationController {
    public String jobId {get; set;}
    public String listType {get; set;}
    public TR1__Call_List__c existingCallList {get; set;}
    public boolean isError {get; set;}
    public String callListName {get; set;}
    public TR1__Job__c job {get; set;}
    public String existingCallListMessage {get; set;}
    
    public CallListGenerationController(){
        if(apexpages.currentpage().getparameters().get('jobId') != null){
            jobId = Apexpages.currentpage().getparameters().get('jobId');
            listType = Apexpages.currentpage().getparameters().get('listType');
            fetchAlreadyCreatedCallListForUser();
        }
    }
    
    private void fetchAlreadyCreatedCallListForUser(){
        String loggedInUserId = UserInfo.getUserId();
        for(TR1__Call_List__c callList : [Select Id, Name, Call_List_Generation_Progress__c from TR1__Call_List__c 
                                            where Job__c =: jobId 
                                            AND createdById =: loggedInUserId 
                                            AND RecordType.DeveloperName =: listType 
                                            order by createddate desc 
                                            limit 1]){
            existingCallList = callList;
            if(Label.Call_List_Already_Exists.contains('<<CALL_LIST_TYPE>>')){
                existingCallListMessage = Label.Call_List_Already_Exists.replaceAll('<<CALL_LIST_TYPE>>', listType);
            }else{
                existingCallListMessage = Label.Call_List_Already_Exists;
            }
            if(existingCallList.Call_List_Generation_Progress__c == 'In Progress') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, label.Call_List_Generation_Progress_Batch_Status);
                ApexPages.addMessage(myMsg);
                isError = true;
            }
        }
        //For testing
        //existingCallList = [Select Id, Name from TR1__Call_List__c limit 1];
        //existingCallListMessage = 'You have already created the Call List of '+ listType +' type. Please click Update to update the Call List with new Members.';
    }
    
    public PageReference generateCallList(){
        if(existingCallList == null){
            isError = false;
            String finalQuery = returnFinalQuery();
            Savepoint sp = Database.setSavepoint();
            try{
                if(Test.isRunningTest()){
                    finalQuery = 'Select Id from Contact';
                }
                    
                if(finalQuery != null) {
                    Integer queryLimit = Test.isRunningTest() ? 3 : 101;
	                //check if a single Contact exist for the query
                    String tempfinalQuery = finalQuery + ' limit ' + queryLimit;
	                List<Contact> contactList = finalQuery != null ? Database.query(tempfinalQuery) : new List<Contact>();
	                
	                if(contactList.size() > 0){
	                    
	                    List<TR1__Call_List_Member__c> callListMembersToInsert = new List<TR1__Call_List_Member__c>();
	                    //create the Call List 
	                    TR1__Call_List__c callList =  new TR1__Call_List__c();
	                    callList.Job__c = jobId;
	                    callList.Name =  callListName;
	                    callList.RecordTypeId = listType == 'Passes_List' ? getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List') : getRecordTypeIdbyName('TR1__Call_List__c', 'Pipeline List');
	                    callList.Call_List_Generation_Progress__c = contactList.size() < queryLimit ? 'Completed' : 'In Progress';
						callList.OwnerId = UserInfo.getUserId();
	                    /*
	                    if(job.RecordType.Name.contains('Fidelis') || job.RecordType.Name.contains('Allied Staffing')){
	                        if(job.TR1__Sourcing_Recruiter__c != null){
	                            callList.OwnerId = job.TR1__Sourcing_Recruiter__c;
	                        }
	                    }else if(job.RecordType.Name.contains('Medestar Locums') || job.RecordType.Name.contains('Travelers')){
	                        if(job.Account_Manager__c != null){
	                            callList.OwnerId = job.Account_Manager__c;
	                        }
	                    }*/
	                    
	                    insert callList;
	                    if(!contactList.isEmpty() && contactList.size() < queryLimit) {
	                        for(Contact ct : contactList){
	                            callListMembersToInsert.add(new TR1__Call_List_Member__c(TR1__Call_List__c = callList.id, TR1__Contact__c = ct.id,
	                                                                                TR1__Call_List_Contact__c = ct.id+ '-'+callList.id));
	                        }
	                        //inserting call list members
	                        insert callListMembersToInsert;
	                    } else if(!contactList.isEmpty()) {
	                        List<AsyncApexJob> apexJobList = [SELECT Id, Status, ApexClass.name FROM AsyncApexJob where ApexClass.Name = 'CallListGenerationBatch' AND (Status = 'Processing' OR Status = 'Queued')];
	                        if(!apexJobList.isEmpty()) {
	                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, label.Call_List_Generation_Progress_Batch_Status);
	                            ApexPages.addMessage(myMsg);
	                            isError = true;
	                        } else {
	                        	Database.executeBatch(new CallListGenerationBatch(callList, finalQuery), 100);
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, label.Call_List_Generation_Progress_Batch_Status);
                                ApexPages.addMessage(myMsg);
                                isError = true;
	                        }
	                    }
	                    existingCallList = callList;
	                } else {
	                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Matching_Contact_Found);
	                    ApexPages.addMessage(myMsg);
	                    isError = true;
	                }
                }else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Query_is_not_available);
                    ApexPages.addMessage(myMsg);
                    isError = true;
                }
            }catch(Exception ex){
                Database.rollback( sp );
                handleErrors(ex.getMessage());
            }
        }
        return null;
    }
    
    public Pagereference updateCallList(){
        try{
            isError = false;
            String finalQuery = returnFinalQuery();
            List<TR1__Call_List_Member__c> callListMembersToInsert = new List<TR1__Call_List_Member__c>();
            
            //fetching existing call list members
            List<TR1__Call_List_Member__c> existingCallListMembersList = new List<TR1__Call_List_Member__c>();
            for(TR1__Call_List_Member__c member : [SELECT Id FROM TR1__Call_List_Member__c 
            										WHERE TR1__Call_List__c =: existingCallList.Id Limit 10000]){
            	existingCallListMembersList.add(member);
            }
            if(Test.isRunningTest()){
                finalQuery = 'Select Id from Contact limit 3';
            }
            //getting the current query again
            List<Contact> contactList = finalQuery != null ? Database.query(finalQuery) : new List<Contact>();
            Integer queryLimit = Test.isRunningTest() ? 2 : 101;
            if(finalQuery != null){
                if(!contactList.isEmpty() && existingCallListMembersList.size() - contactList.size() < queryLimit) {
                    for(Contact ct : contactList) {
                        callListMembersToInsert.add(new TR1__Call_List_Member__c(TR1__Call_List__c = existingCallList.id, 
                                                                                TR1__Contact__c = ct.id,
                                                                                TR1__Call_List_Contact__c = ct.id+ '-'+existingCallList.id));
                    }
                    upsert callListMembersToInsert TR1__Call_List_Contact__c;
                    existingCallListMessage = Label.Call_List_has_been_successfully_updated;
                } else if(!contactList.isEmpty()) {
                    existingCallList.Call_List_Generation_Progress__c = 'In Progress';
                    update existingCallList;
                    
                    List<AsyncApexJob> apexJobList = [SELECT Id, Status, ApexClass.name FROM AsyncApexJob where ApexClass.Name = 'CallListGenerationBatch' AND (Status = 'Processing' OR Status = 'Queued')];
                    if(!apexJobList.isEmpty()) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, label.Call_List_Generation_Progress_Batch_Status);
                        ApexPages.addMessage(myMsg);
                        isError = true;
                    } else {
                    	Database.executeBatch(new CallListGenerationBatch(existingCallList, finalQuery), 100);
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, label.Call_List_Generation_Progress_Batch_Status);
                        ApexPages.addMessage(myMsg);
                        isError = true;
                    }
                }
            }else{
                existingCallListMessage = Label.Query_is_not_available;
            }   
            
        }catch(Exception ex){
                handleErrors(ex.getMessage());
            }
        return null;
    }
    
    
    public void handleErrors(String exceptionMessage){
        if(exceptionMessage.contains('unexpected token:')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exceptionMessage.split('token:')[1] +' condition in the query is improper for '+listType+'.' );
            ApexPages.addMessage(myMsg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exceptionMessage);
            ApexPages.addMessage(myMsg);
        }
        isError = true;
    }
    
    
    private String returnFinalQuery(){
        CallListConfigQueryEngine.populateStringOperatorMap();
        Map<String, CallListConfigQueryEngine.FieldInfoWrapper> mapContactObjectInfo = 
                                        CallListConfigQueryEngine.prepareCustomFieldsMapWithAttributes('Contact');
        Map<String, CallListConfigQueryEngine.FieldInfoWrapper> mapJobObjectInfo = 
                                CallListConfigQueryEngine.prepareCustomFieldsMapWithAttributes('TR1__JOB__C');
        String jobQuery = 'Select ' + CallListConfigQueryEngine.prepareCustomFieldsString('TR1__JOB__C') + ', RecordType.Name from TR1__JOB__C where Id =: jobId limit 1';
        job = Database.query(jobQuery);
        String finalQuery = CallListConfigQueryEngine.prepareQueryForCallList(listType, mapContactObjectInfo, mapJobObjectInfo, job);
        system.debug('======finalQuery=====' + finalQuery);
        return finalQuery;
    }
    
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
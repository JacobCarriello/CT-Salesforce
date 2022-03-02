public class TaskTriggerHandler{
    public static void beforeInsert(List<Task> newList){
        sendScreenTemplate(newList);
    }
    
    public static void afterInsert(List<Task> newList){
        updateContacts(newList);
    }

    //fetching all the contact ids and populate the Latest_Activity_by_CL_Owner__c date field with respect to related tasks
    public static void afterUpdate(List<Task> newList, Map<Id, Task> oldMap){
        Set<Id> contactIds = new Set<Id>();
        for(Task tsk : newList) {
            if(tsk.whoId != null && String.valueOf(tsk.whoId).startsWith('003') && tsk.ActivityDate != null && tsk.ActivityDate != oldMap.get(tsk.id).ActivityDate){
                contactIds.add(tsk.whoId);
            }
        }
        if(!contactIds.isEmpty()) {
            populateLastActivityDateOnCLM(contactIds);
        }
    }

    //fetching all the contact ids and populate the Latest_Activity_by_CL_Owner__c date field with respect to related tasks
    public static void afterDelete(List<Task> oldList){
       Set<Id> contactIds = new Set<Id>();
        for(Task tsk : oldList) {
            if(tsk.whoId != null && String.valueOf(tsk.whoId).startsWith('003')){
               contactIds.add(tsk.whoId);
            }
        }
        if(!contactIds.isEmpty()) {
            populateLastActivityDateOnCLM(contactIds);
        }
    }
    
    //User with 'Medestar Recruiter' profile creates an Activity on Contact
    //If the same user is identified as the 'Medestar Recruiter' (Medestar_Recruiter_User__c) on Contact, 
    //date stamp Last Medestar Activity (Last_Medestar_Activity), otherwise don't do anything
    
    private static void updateContacts(List<Task> newList){
        Set<Id> contactIds = new Set<Id>();
        for(Task tsk : newList){
            if(tsk.whoId != null && String.valueOf(tsk.whoId).startsWith('003')){
                contactIds.add(tsk.whoId);
            }
        }
        
        //fetching the Medestar Recruiter on Contact
        List<Contact> lstContactsToUpdate = new List<Contact>();
        for(Contact contact : [Select Medestar_Recruiter_user__c from Contact 
                                where id in : contactIds AND Medestar_Recruiter_user__c != null]){
            if(contact.Medestar_Recruiter_user__c == UserInfo.getUserId()){
                lstContactsToUpdate.add(new Contact (Id = contact.id, Last_Medestar_Touch__c = Date.Today()));
            }
        }
        
        if(lstContactsToUpdate.size() > 0){
            update lstContactsToUpdate;
        }
        // sending the contact ids for populating the Latest_Activity_by_CL_Owner__c date field with respect to related tasks
        if(!contactIds.isEmpty()) {
            populateLastActivityDateOnCLM(contactIds);
        }
    }
    
    //"A user creates a new task of Call Type 'Screen.' 
    //Upon save, the task needs to be updated to ""Complete,"" AND IF Medestar_Recruiter__c on Contact is blank, 
    //send the following template: https://na35.salesforce.com/00X41000000ov6l?setupid=CommunicationTemplatesEmail

    public static void sendScreenTemplate(List<Task> newList){
        boolean isDevisionMedastar = false;
        for(User usr : [Select Id, Division from User where id =: UserInfo.getUserId() limit 1]){
            if(usr.Division == Label.Medestar || Test.isRunningTest()){
                isDevisionMedastar = true;
            }
        }
        
        Set<String> contactIds =  new Set<String>();
        for(Task tsk : newList){
            if(tsk.TR1__Call_Type__c == 'Screen' && isDevisionMedastar){
                tsk.status = 'Completed';
                if(tsk.whoId != null && String.valueOf(tsk.whoId).startsWith('003')){
                    contactIds.add(tsk.whoId);
                }
            }
        }
        
        //fetching the Medestar Recruiter on Contact
        List<Contact> lstContactsToUpdate = new List<Contact>();
        for(Contact contact : [Select Medestar_Recruiter_user__c from Contact 
                                where id in : contactIds AND Medestar_Recruiter_user__c = null]){
            lstContactsToUpdate.add(new Contact (Id = contact.id, Send_Screen_Email__c = true));
        }
        
        if(lstContactsToUpdate.size() > 0){
            update lstContactsToUpdate;
        }
    }
    
    //This method is used for populating the Latest_Activity_by_CL_Owner__c date field with respect to related tasks
    public static void populateLastActivityDateOnCLM(Set<Id> contactIds){
        Map<String,Map<String,Date>> contactTaskOwnerMap = new Map<String,Map<String,Date>>();
        Set<Id> ownerIdSet = new Set<Id>();
        List<TR1__Call_List_Member__c> updateCallListMemberList = new List<TR1__Call_List_Member__c>();
        //fetching the call list members 
        List<TR1__Call_List_Member__c> callListMemberList = [SELECT Id, Name, TR1__Contact__c, TR1__Call_List__r.OwnerId, TR1__Call_List__r.CreatedDate FROM TR1__Call_List_Member__c WHERE TR1__Contact__c IN :contactIds
                                                                    AND (TR1__Call_List__r.recordTypeId = :getRecordTypeIdbyName('TR1__Call_List__c', 'Passes List')
                                                                    OR TR1__Call_List__r.recordTypeId = :getRecordTypeIdbyName('TR1__Call_List__c', 'Pipeline List')) LIMIT 50000];
        for(TR1__Call_List_Member__c newRecord : callListMemberList) {
            ownerIdSet.add(newRecord.TR1__Call_List__r.OwnerId);
        }
        for(Task tsk : [SELECT Id, ActivityDate, whoId, OwnerId FROM Task WHERE whoId IN :contactIds AND OwnerId IN :ownerIdSet AND ActivityDate != NULL ORDER BY ActivityDate DESC LIMIT 50000]) {
            Map<String, Date> contactTaskCreatedDateMap = new Map<String, Date>();
            if(contactTaskOwnerMap.containsKey(tsk.whoId)) {
                contactTaskCreatedDateMap = contactTaskOwnerMap.get(tsk.whoId);
                if(contactTaskCreatedDateMap.containsKey(tsk.OwnerId)) {
                   if(contactTaskCreatedDateMap.get(tsk.OwnerId) < tsk.ActivityDate) {
                        contactTaskCreatedDateMap.put(tsk.OwnerId, tsk.ActivityDate);
                   }
                } else {
                    contactTaskCreatedDateMap.put(tsk.OwnerId, tsk.ActivityDate);
                }
                contactTaskOwnerMap.put(tsk.whoId, contactTaskCreatedDateMap);
            } else {
                contactTaskCreatedDateMap.put(tsk.OwnerId, tsk.ActivityDate);
                contactTaskOwnerMap.put(tsk.whoId, contactTaskCreatedDateMap);
            }
        }
        system.debug('Anydatatype_msg ' + contactTaskOwnerMap);

        for(TR1__Call_List_Member__c newRecord : callListMemberList){
            if(newRecord.TR1__Contact__c != null && contactTaskOwnerMap.containsKey(newRecord.TR1__Contact__c)) {
                if(contactTaskOwnerMap.get(newRecord.TR1__Contact__c).containsKey(newRecord.TR1__Call_List__r.OwnerId)) {
                     Date taskActivityDate = contactTaskOwnerMap.get(newRecord.TR1__Contact__c).containsKey(newRecord.TR1__Call_List__r.OwnerId) ? contactTaskOwnerMap.get(newRecord.TR1__Contact__c).get(newRecord.TR1__Call_List__r.OwnerId) : null;
                    system.debug('taskActivityDate ' + taskActivityDate);
                    Boolean IsCount =  taskActivityDate >= newRecord.TR1__Call_List__r.CreatedDate.date();
                    system.debug('calllistCreatedDate ' + newRecord.TR1__Call_List__r.CreatedDate.date());
                    system.debug('IsCount ' + IsCount);
                    Datetime LatestActivityDate = taskActivityDate != null ? DateTime.newInstance(taskActivityDate.year(), taskActivityDate.month(), taskActivityDate.day()) : null;
                    updateCallListMemberList.add(new TR1__Call_List_Member__c(Id = newRecord.Id, Latest_Activity_by_CL_Owner__c = LatestActivityDate, IsCount_Call_List__c = IsCount));
                }
            }
        }

        if(!updateCallListMemberList.isEmpty()) {
            List<Database.SaveResult> results = Database.update(updateCallListMemberList, false);
            for (Database.SaveResult result : results) {
              if (!result.isSuccess()){
                for (Database.Error err : result.getErrors()){
                  System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage() + '   Error On == ' + result.getId());
                }
              }
            }
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
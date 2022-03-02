public without sharing class RC_AccessController {
    
    public static List<Contact> getContactsByEmail(String email) {
        return [Select Id from Contact where Email =: email];
    }
    
    public static void upsertContact(Contact contact2Upsert, Schema.SObjectField keyField) {
        Database.upsert(contact2Upsert, keyField, false);
    }
    
    public static List<sObject> query(String queryStr) {
        return Database.query(queryStr);
    }
    
    public static void updateRecord(sObject record2Update) {
        System.debug('record2Update - ' + record2Update);
        Database.update(record2Update);
    }
    
    public static void updateRecords(List<sObject> records2Update) {
        Database.update(records2Update);
    }
    
    public static void deleteRecord(sObject record2Delete) {
        Database.delete(record2Delete);
    }
    
    public static List<TR1__ContactDocument__c> getLastCreatedDefaultContactDocument(String contactId) {
        return [Select Id from TR1__ContactDocument__c where TR1__Contact__c =: contactId AND TR1__isDefault__c = true  ORDER BY CreatedDate DESC limit 1];
    }
    
    // delete, if RC_ResumeUpload class doesn't use this method (usually, count of the strings on this class about 88)
    public static List<TR1__EducationHistory__c> getEducationHistoryRecordsByContactId(Id contactId) {
        return [Select Id,TR1__EducationHistoryExtID__c from TR1__EducationHistory__c Where TR1__Contact__c =: contactId];
    }
    
    // delete, if RC_ResumeUpload class doesn't use this method (usually, count of the strings on this class about 88)
    public static List<TR1__EmploymentHistory__c> getEmploymentHistoryRecordsByContactId(Id contactId) {
        return [Select Id,TR1__EmployeeHistoryExtID__c from TR1__EmploymentHistory__c Where TR1__Contact__c =: contactId];
    }
    
    // delete, if RC_ResumeUpload class doesn't use this method (usually, count of the strings on this class about 88)
    public static Contact getContactsByExternalCandidateId(String deleteCandidateId) {
        return [Select Id from Contact where TR1__External_Candidate_Id__c =: deleteCandidateId];
    }
    
    // delete, if RC_ResumeUpload class doesn't use this method (usually, count of the strings on this class about 88)
    public static List<User> getUsersByContactId(String contactId) {
        return [Select Id from User where ContactId =: contactId];
    }
    
    // delete, if RC_ResumeUpload class doesn't use this method (usually, count of the strings on this class about 88)
    public static TR1__ContactDocument__c getLastCreatedContactDocument(String contactId) {
        return [Select Name from TR1__ContactDocument__c where TR1__Contact__c =:contactId  Order BY CreatedDate Desc limit 1];
    }
    
    public static void insertRecord(sObject record2Insert) {
        Database.insert(record2Insert);
    }
    
    // delete, if RC_ResumeUpload class doesn't use this method (usually, count of the strings on this class about 88)
    public static void upsertRecords(List<sObject> sObjects2Upsert) {
        Database.upsert(sObjects2Upsert);
    }
    
    public static void upsertRecord(sObject sObject2Upsert) {
        Database.upsert(sObject2Upsert);
    }
    
    public static List<AggregateResult> getArticleCategories() {
        return [select count(id) numOfRecords, TR1__Category__c from TR1__RC_Article__c group by TR1__Category__c];
    }
    
    public static List<List<sObject>> searchQuery(String query) {
        return Search.query(query);
    }
    
    public static List<TR1__RC_Article__c> getRCArticleById(Id articleId) {
        return [select TR1__Content__c from TR1__RC_Article__c where Id = :articleId];
    }
    
    public static List<TR1__Application__c> getContactApplicationsForJob(String strJobId, String idContact) {
        return [Select Id from TR1__Application__c where TR1__Job__c =: strJobId and TR1__Applicant__c =: idContact];
    }
    
    public static TR1__Job__c getJobById(String jobId) {
        return [Select  Job_Title__c from TR1__Job__c where Id =: jobId];
    }
    
    public static List<TR1__ContactDocument__c> getContactsDefaultResumes(Set<Id> contactIds) {
        return [SELECT TR1__Contact__c,TR1__Internal_View_URL__c FROM TR1__ContactDocument__c WHERE TR1__Contact__c IN: contactIds AND TR1__isDefault__c = true AND TR1__Type__c = 'Resume'];
    }
    
    public static List<TR1__Job_Reporting__c> getJobReportingsForContact(String jobId, String candidateId, String jobContactId) {
        //getting the allowed value for picklist from Custom-setting    
        List<String> lstStageToBeIncluded = Candidate_Community__c.getValues('RegistrationDetail').Include_Stages__c.split(':');
        return [Select TR1__Contact__c , TR1__Contact__r.Name, TR1__Stage__c, TR1__Contact__r.Rating__c ,TR1__Job__c From TR1__Job_Reporting__c where TR1__Job__c =:jobId AND TR1__Application__c != '' AND TR1__Contact__c =: candidateId AND TR1__Stage__c IN: lstStageToBeIncluded AND (TR1__Job__r.TR1__Hiring_Manager__c =: jobContactId OR TR1__Job__r.TR1__Contact__c =: jobContactId)];
    }
    
    public static void upsertContactAccrual(List<TR1__Contact_Accrual__c> contactAccruals2Upsert, Schema.SObjectField keyField) {
        Database.upsert(contactAccruals2Upsert, keyField, false);
    }
    
    public static TR1__Timesheet_Detail__c getTimesheetDetailById(Id tsId) {
        return [select id, TR1__Timesheet__c, TR1__Timesheet__r.TR1__Closing_Report__c,TR1__Date__c  from TR1__Timesheet_Detail__c where id=: tsId];
	}
    
    public static List<TR1__Rate__c> getTimesheetRatesByTimesheetId(Id rTsId) {
        //return [select id,name,TR1__TimeType__c,TR1__Timesheet__c,TR1__TimeType__r.TR1__Show_in_Community__c, TR1__TimeType__r.TR1__EntryType__c, TR1__Active__c from TR1__Rate__c where  TR1__TimeType__r.RecordType.developername = 'Timesheet_Time_Type' and TR1__Active__c = true AND TR1__Timesheet__c =:rTsId AND TR1__TimeType__r.TR1__Show_in_Community__c=true];
     	return [select id,name,TR1__TimeType__c,TR1__Timesheet__c,TR1__TimeType__r.TR1__Show_in_Community__c, TR1__TimeType__r.TR1__EntryType__c, TR1__Active__c,TR1__TimeType__r.Name from TR1__Rate__c where  TR1__TimeType__r.RecordType.developername = 'Timesheet_Time_Type' and TR1__Active__c = true AND TR1__Timesheet__c =:rTsId AND TR1__TimeType__r.TR1__Show_in_Community__c=true];
    }
    
    public static TR1__Rate__c getTimesheetRateById(Id ss) {
        //return [select id, TR1__TimeType__r.TR1__EntryType__c from TR1__Rate__c where id=: ss limit 1];
        return [select id,TR1__TimeType__r.TR1__EntryType__c,TR1__TimeType__r.Name from TR1__Rate__c where id=:ss limit 1 ];
    }
    
    public static List<TR1__Closing_Report__c> getClosingReportForContact(Id contactId) {
        return [Select Id, TR1__Start_Date__c, TR1__Job__r.Name,(Select Id, Name, TR1__Rate_Type_Name__c From TR1__Rates__r Where TR1__Active__c = true) From TR1__Closing_Report__c Where TR1__Person_Placed__c =: contactId limit 1];
    }
    
    public static List<TR1__Closing_Report__c> getAllClosingReportsForContact(Id contactId) {
        return [Select Id, TR1__Start_Date__c, TR1__Job__r.Name,(Select Id, Name, TR1__Rate_Type_Name__c From TR1__Rates__r Where TR1__Active__c = true) From TR1__Closing_Report__c Where TR1__Person_Placed__c =: contactId];
    }
    
    public static List<TR1__Expense_Report__c> getExpenseReportById(Id expenseReportId) {
        return [Select Id, (Select Id, Name, TR1__Rate_Type_Name__c,TR1__TimeType__r.TR1__Mileage__c 
                                                            From TR1__Rates__r 
                                                            Where TR1__Active__c = true  
                                                            And TR1__TimeType__r.RecordType.DeveloperName = 'Expense_Time_Type'
                                                            order by Name asc )
                                         From TR1__Expense_Report__c 
                                         where Id =: expenseReportId];
    }
    
    public static List<Attachment> getAttachmentsByParentId(Id parentId) {
        return [SELECT ContentType, Name, ParentId, Description FROM Attachment where parentId =: parentId];
    }
    
    public static List<TR1__Closing_Report__c> getClosingReportById(Id closingReportId) {
        return [Select TR1__Account__c, TR1__Timesheet_Approver__c from TR1__Closing_Report__c where Id =: closingReportId];
    }
    
    public static void upsertExpenseLineItems(List<TR1__Expense_Report_Detail__c> items2Upsert, Schema.SObjectField keyField, Boolean allOrNothing) {
         Database.upsert(items2Upsert, keyField, allOrNothing);
    }
    
    public static List<TR1__Expense_Report__c> getExpenseReportRates(String searchKey, String expid, String contId){
        String queryStr = 'Select Id, (Select Id, Name, TR1__Rate_Type_Name__c From TR1__Rates__r Where TR1__Active__c = true And TR1__TimeType__r.TR1__Show_in_Community__c = true and Name like \'' +searchKey +'%\' And TR1__TimeType__r.RecordType.DeveloperName = \'Expense_Time_Type\' order by Name asc ) From TR1__Expense_Report__c  where Id =\'' +  expid + '\' AND TR1__Consultant__c =\'' + contId + '\'';
        return Database.query(queryStr);
    }
    
    public static List<TR1__Associated_Qualification__c> getAssociatedQualificationsById(Id qualificationId) {
        return [Select Power_Form_URL__c, TR1__Qualification__c, TR1__Qualification__r.TR1__Field_Set_ID__c, TR1__Qualification__r.TR1__Collection_Methods__c, TR1__Qualification__r.Name, TR1__Qualification__r.TR1__Instructions_External__c, TR1__Completed_Collection_Methods__c, TR1__Status__c From TR1__Associated_Qualification__c Where Id =: qualificationId];
    }
    
    public static List<TR1__Associated_Qualification__c> getAssociatedQualificationsById(Id qualificationId, Id contactId) {
        return [Select Power_Form_URL__c, TR1__Qualification__c, TR1__Qualification__r.TR1__Field_Set_ID__c, TR1__Qualification__r.TR1__Collection_Methods__c, TR1__Qualification__r.Name, TR1__Qualification__r.TR1__Instructions_External__c, TR1__Completed_Collection_Methods__c, TR1__Status__c From TR1__Associated_Qualification__c Where Id =: qualificationId AND TR1__Contact__c =: contactId];
    }

    public static List<TR1__Job_Reporting__c> getAllJobReportingsForContactsJobs(String contactId) {
        return [SELECT Id, TR1__Contact__c FROM TR1__Job_Reporting__c WHERE TR1__Job__r.TR1__Contact__c =: contactId OR TR1__Job__r.TR1__Hiring_Manager__c =: contactId];
    }
    
    public static List<TR1__ContactDocument__c> getContactDocumentByIdWithParticularContactAccess(Id docId, Set<Id> availableContactIds) {
        return [SELECT  Id, TR1__Contact__c, TR1__Contact__r.Name, Name, TR1__HTML_URL__c, TR1__Internal_View_URL__c, TR1__Internal_URL__c, TR1__File_Download__c,  TR1__External_View_URL__c, TR1__External_URL__c, TR1__Version__c, TR1__Type__c, TR1__ContentDocumentId__c, TR1__isDefault__c, TR1__ContentVersionId__c, TR1__ScrambledCV__c , TR1__ContentVersionFileExtension__c  FROM TR1__ContactDocument__c  WHERE id =: docId AND TR1__Contact__c IN: availableContactIds];
    }
    
    public static TR1.Candidate performDMLFromCommunity (TR1.Candidate candt) {
        return TR1.ResumeProcessor.PerformDMLFromCommunity(candt);
    }
    
    public static TR1.Candidate callCreateUpdateContact(Attachment resume, String sessionId) {
        return TR1.ResumeProcessor.createUpdateContact(resume, sessionId);
    }
    
}
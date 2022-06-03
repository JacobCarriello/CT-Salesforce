public with sharing class RC_JobCandidates {

    public List<TR1__Job_Reporting__c> lstJobReporting { get;set; }                 // List of candidates reporting to a Job
    public List<TR1__Opportunity_Discussed__c> lstOppDiscussed { get;set; }         // List Opportunity Discuscced
    public List<Schema.FieldSetMember> lstFieldsCandidates { get;set; }             // List of fields retrived from fieldset
    public List<Schema.FieldSetMember> lstFieldsShortlist { get;set; }              // List of fields for shortlisted candidates
    public Map<Id, String> mapContactDocURL {get;set;}                              // Map of ContactId to their resume ids.
    public List<String> lstJobStagesOrdered {get;set;}                              // List of Status in progressive order
    public TR1__Job__c objJob {get;set;}                                            // Job Object, used for job Title
    private String strQueryShortList;
    private String strOrder ;
    private List<Schema.FieldSetMember> lstFieldSet;
    public Contact objContact                                           {get;set;} 
    private String jobId;
     
    public RC_JobCandidates(){
        lstJobReporting = new List<TR1__Job_Reporting__c>();
        lstOppDiscussed = new List<TR1__Opportunity_Discussed__c>();
        mapContactDocURL = new Map<Id, String>();
        objContact = new Contact();
       
        lstFieldSet = new List<Schema.FieldSetMember>();
        jobId = Apexpages.currentPage().getParameters().get('jobId');
        init();
        
    }
    
    // Initilize method
    private void init(){
        
        try{
            // check if, page has the Jobid in url parameter
            if(String.isNotBlank(jobId))
            {
                fetchContactInfo();
                String nameSpace = '';
                String strQuery = 'Select TR1__Contact__c ';
                strQueryShortList = 'Select Id ';
                strOrder = 'Asc';
                
                lstJobStagesOrdered = new List<String>();
                lstFieldsCandidates = new List<Schema.FieldSetMember>();
                lstFieldsShortlist = new List<Schema.FieldSetMember>();
                Candidate_Community__c objCS_Cand_Comm = Candidate_Community__c.getValues('RegistrationDetail');
                
                //Getting the fields from fieldset
                lstFieldsCandidates = SObjectType.TR1__Job_Reporting__c.FieldSets.getMap().get(nameSpace+'RC_ClientJobCandidates').getFields();
                lstFieldsShortlist = SObjectType.TR1__Opportunity_Discussed__c.FieldSets.getMap().get(nameSpace+'RC_Client_CandidatesShortlisted').getFields();
                for(Schema.FieldSetMember objFSM : lstFieldsCandidates)
                    strQuery += ', '+objFSM.getFieldPath();
                
                for(Schema.FieldSetMember objFSM : lstFieldsShortlist)
                    strQueryShortList += ', ' + objFSM.getFieldPath();
                    
                //getting the allowed value for picklist from Custom-setting    
                List<String> lstStageToBeIncluded = objCS_Cand_Comm.Include_Stages__c.split(':');
                
                //described the picklist for getting in defined order 
                Schema.DescribeFieldResult fieldResult = TR1__Job_Reporting__c.TR1__Stage__c.getDescribe();
                
                
                for( Schema.PicklistEntry field : fieldResult.getPicklistValues())
                {
                    //Include only those picklist value which are mentioned in custom-setting
                    String strValue = field.getValue() == 'Applicaton' ? 'Application' : field.getValue();
                    lstJobStagesOrdered.add(strValue);
                } 

                //To get most progressive order of Status, need to reverse the order of list
                List<String> lstStageToBeReversed = new List<String>(lstJobStagesOrdered);
                
                Integer intListLength = lstStageToBeReversed.size() - 1;
                lstJobStagesOrdered = new List<String>();
                // Reversing the items of list
                for(Integer i=intListLength; i>=0;i--)
                    lstJobStagesOrdered.add(lstStageToBeReversed[i]);
                    
                lstStageToBeReversed = new List<String>();

                strQueryShortList += ' from TR1__Opportunity_Discussed__c where TR1__Job__c=\'' + jobId + '\' AND TR1__Interest_Level__c != \'\' AND '
                    + '(TR1__Job__r.TR1__Hiring_Manager__c = \'' + objContact.Id + '\' OR TR1__Job__r.TR1__Contact__c = \'' + objContact.Id + '\') ';   
                	
                // Display All candidates applied for a job.
                strQuery += ' ,TR1__Job__c From TR1__Job_Reporting__c '+
                            'where TR1__Job__c =\'' + jobId + '\' AND TR1__Application__c !=\'\' AND TR1__Contact__c != \'\' AND TR1__Stage__c IN (\'' + String.join(lstStageToBeIncluded, '\',\'') + '\') AND ' 
                    + '(TR1__Job__r.TR1__Hiring_Manager__c = \'' + objContact.Id + '\' OR TR1__Job__r.TR1__Contact__c = \'' + objContact.Id + '\') '
                    + ' Order By TR1__Stage__c';
                
                objJob = RC_AccessController.getJobById(jobId);

                lstJobReporting = RC_AccessController.query(strQuery);
               
                lstOppDiscussed = RC_AccessController.query(strQueryShortList +  'Order By TR1__Interest_Level__c '+ strOrder);
                
                //collecting all contact ids from list of candidates applied to a job
                for(TR1__Job_Reporting__c objJobReport : lstJobReporting){
                    
                    mapContactDocURL.put(objJobReport.TR1__Contact__c,'no_resume'); //To have resume id for each candidate of job applied
                }
                
                for(TR1__ContactDocument__c  objDoc : RC_AccessController.getContactsDefaultResumes(mapContactDocURL.keyset()))
                    mapContactDocURL.put(objDoc.TR1__Contact__c, 'ViewResume?id=' + objDoc.Id);
               
               fetchContactInfo();  
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Url is incorrect'));
                return; 
                //throw new CustomException('JobId not found');
            }
        }
            
        
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
    }
    
    //To fetch the contact detail
    private void fetchContactInfo()
    {
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        User loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
        String idContact = loggedInUser.ContactId;
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
               
        strQuery  += fieldNames + ' from Contact where id =: idContact' ;    
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
    } 
    
    /*
    Name - createTask
    return Type - Void
    Description - Create a task associated to Contact and Job, when a resume is viewed
    */
    
    public void createTask(){
        
        String jobId = Apexpages.currentPage().getParameters().get('jobId');
        String candidateId = Apexpages.currentPage().getParameters().get('candidateId');
        Task objTask = new Task(WhatId = jobId, WhoId = candidateId, OwnerId = UserInfo.getUserId(), ActivityDate = Date.today());
        RC_AccessController.insertRecord(objTask);
    }
    
    public void reOrderOppDiscussed(){
        String jobId = Apexpages.currentPage().getParameters().get('jobId');
        lstOppDiscussed = new List<TR1__Opportunity_Discussed__c>();
        strOrder = strOrder == 'Asc' ? 'Desc' : 'Asc';
        lstOppDiscussed = RC_AccessController.query(strQueryShortList + ' Order By TR1__Interest_Level__c '+strOrder);
    }
    
    public Pagereference redirectUnAuthenticatedUser()
    {
        try
        {
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
            {
                return new Pagereference('/Signin');
            }
                
           return null;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
}
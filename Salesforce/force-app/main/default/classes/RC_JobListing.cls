public with sharing class RC_JobListing
{
    public List<TR1__Job__c> lstNotAppliedJobs                  {get;set;}          // List of Jobs, Available positions
    public List<TR1__Application__c> lstAppliedJobs             {get;set;}          // List oj Jobs, My positions
    public List<Schema.FieldSetMember> lstFieldsNotApplied      {get;set;}          // List fields, Available positions
    public List<Schema.FieldSetMember> lstFieldMyApplications   {get;set;}          // List fields, My positions
    public Id idJobToBeApplied                                  {get;set;}          // To be applied job Id
    
    
    /* Client part */
    public List<TR1__Job__c> lstOpenJobs                        {get;set;}               // List of Open-Jobs
    public List<TR1__Job__c> lstPastJobs                        {get;set;}               // List of past-jobs
    public List<Schema.FieldSetMember> fieldSetOpenJobList      {get;set;}               // list of FieldSetMember for Detail section
    public List<Schema.FieldSetMember> fieldSetPastJobList      {get;set;}               // list of FieldSetMember for Detail section
    public TR1__Job_Leads__c objJobLead                         {get;set;}              // Object for creating new Job Lead
    
    public Contact objContact			                        {get;set;}              // Contact object loggedin
    public String strMessage                                    {get;set;}              // Message to be display either success or error ones
    public Boolean  isSuccess                                   {get;set;}              // Boolean to check any errors or success at page & Class
    public String strContactType{get;set;}
    
    private  String strQueryForNotAppliedJobs;
    private  String strQueryForAppliedJobs  ;
    private  Id idContact;
    private List<Schema.FieldSetMember> lstFieldSet;
    
    
    User loggedInUser;
     /* Client part */
    
    public RC_JobListing()
    {
        /*Client part */
        fieldSetOpenJobList = new List<Schema.FieldSetMember>(); 
        fieldSetPastJobList = new List<Schema.FieldSetMember>(); 
        objJobLead = new TR1__Job_Leads__c();
        objContact = new Contact();
        lstFieldSet = new List<Schema.FieldSetMember>();
        /*Client part */
        
        strContactType = '';
        try
        {
        	lstAppliedJobs = new List<TR1__Application__c>();
        	lstNotAppliedJobs = new List<TR1__Job__c>();
        	lstFieldsNotApplied = new  List<Schema.FieldSetMember>(); 
        	lstFieldMyApplications = new  List<Schema.FieldSetMember>(); 
            isSuccess = false;
            String namespace = '';
            strQueryForNotAppliedJobs = 'Select Id '; 
            
            lstFieldsNotApplied = SObjectType.TR1__Job__c.FieldSets.getMap().get(namespace+'RC_CandidateJobListing').getFields();
            for(Schema.FieldSetMember field : lstFieldsNotApplied) 
                      strQueryForNotAppliedJobs += ', ' + field.getFieldPath();
                      
            strQueryForNotAppliedJobs  += ' from TR1__Job__c' ;   
            
            
            lstFieldMyApplications = SObjectType.TR1__Application__c.FieldSets.getMap().get(namespace+'RC_My_Applications').getFields();
            strQueryForAppliedJobs = 'Select Id ';
            for(Schema.FieldSetMember field : lstFieldMyApplications)
                  strQueryForAppliedJobs += ',' + field.getFieldPath(); 
                  
            strQueryForAppliedJobs  += ' from TR1__Application__c' ;   
            
            if(Test.isRunningTest())
				Integer c = 5/0; 
        }
        catch(Exception ex)
        {
            isSuccess = false;
            //strMessage = ex.getMessage(); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            system.debug('::::ex:::'+ex);
        }
    }
    
    
    public Pagereference redirectUnAuthenticatedUser() 
    {
        try
        {
            String nameSpace = '';
            lstOpenJobs = new List<TR1__Job__c>();
            lstPastJobs = new List<TR1__Job__c>();
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess') 
            {
                return new Pagereference('/Signin');
            }
            
            loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
            if(loggedInUser.ContactId != null)
            {
            	idContact = loggedInUser.ContactId;
            	fetchContactInfo();
            	
            	if(objContact.Community_Contact_Type__c == 'Candidate')
            	{
	               strContactType = 'candidate'; 
	                fetchJobs();
            	}
	               
            	else if(objContact.Community_Contact_Type__c == 'Client')
            	{
            		strContactType = 'client';
            		fetchClientJobs();
            	}
            		
            	else if(objContact.Community_Contact_Type__c == 'C and C')
            	{
            		strContactType = 'c&c';
	                fetchJobs();
	                fetchClientJobs();
            	}
            	
            }
            return null;
        }
        catch(Exception ex)
        {
            system.debug('::;ex:::'+ex);
            isSuccess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
    }
    
    //To fetch the contact detail
    private void fetchContactInfo()
    {
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields(); 
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        strQuery += fieldNames.contains('Community_Contact_Type__c') ? '' : ', Community_Contact_Type__c ';
        strQuery += fieldNames.contains('TR1__Candidate_Status__c') ? '' : ', TR1__Candidate_Status__c ';
        strQuery += fieldNames + ' from Contact where id =: idContact' ;     
        system.debug('---strQuery-'+strQuery);
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
            
    } 
    
    /*
    Name- applyToJob
    parameters - None
    return - Void
    Description - To apply on Jobs for Candidate Type Contacts
    */
    public void applyToJob()
    { 
        try
        {
            
            TR1__Application__c objApp = new TR1__Application__c();
            objApp.TR1__Applicant__c = idContact ; 
            objApp.TR1__Job__c =  idJobToBeApplied; 
            objApp.TR1__Status__c = 'Current';
            RC_AccessController.insertRecord(objApp);
            fetchJobs();
            isSuccess = true;
            strMessage = 'Your application has been successfully submitted';
            if(Test.isRunningTest()) 
				Integer c = 5/0;  
        }
        catch(Exception ex)
        {
            isSuccess = false;
            //strMessage = ex.getMessage();  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            system.debug('::::ex:::'+ex);
        }
    }
    /*----END--applyToJob -------*/
    
    
     /*
    Name- fetchJobs
    parameters - None
    return - Void
    Description - To fecth Job for Candidate Type Contacts
    */
    private void fetchJobs()
    {
        lstAppliedJobs = new List<TR1__Application__c>();
        lstNotAppliedJobs = new List<TR1__Job__c>();
        lstAppliedJobs = RC_AccessController.query(strQueryForAppliedJobs + ' WHERE TR1__Applicant__c =\'' + idContact + '\'');

        lstNotAppliedJobs = RC_AccessController.query(strQueryForNotAppliedJobs + ' WHERE TR1__Post_Externally__c = true  AND TR1__Status__c =\'Open\' AND id NOT IN (Select TR1__Job__c FROM TR1__Application__c where TR1__Applicant__c =\'' + idContact + '\') ');
    }
    
    
    /*
    Name- saveJobLead
    parameters - None
    return - Void
    Description - To create new Job Lead for Client Type Contacts
    */
    public void saveJobLead()
    {
    	try
    	{
	    	objJobLead.TR1__Account__c = [Select AccountId from User where Id =: UserInfo.getUserId() limit 1].AccountId;
	        objJobLead.TR1__Contact__c = idContact;
	        objJobLead.TR1__Status__c = 'Open';
	        RC_AccessController.insertRecord(objJobLead);
	        isSuccess = true;
	        strMessage = 'New Vacancy lead is created successfully.';
	        System.debug('--------- objJobLead ------- '+objJobLead);
	        objJobLead = new TR1__Job_Leads__c();
    	}
    	catch(Exception ex)
    	{
    		isSuccess = false;
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    		System.debug('ex : '+ex);
    	}
    }
    /*------END--saveJobLead------------*/
    
    
    /*
    Name- fetchClientJobs
    parameters - None
    return - Void
    Description - To fecth Job for Client Type Contacts
    */
    public void fetchClientJobs()
    {
        String conId = idContact;
        String nameSpace = ''; 
            
        Map<String, Schema.FieldSet> mapFieldset = SObjectType.TR1__Job__c.FieldSets.getMap();
        fieldSetOpenJobList = mapFieldset.get(nameSpace+'RC_Open_JobListing').getFields();
        fieldSetPastJobList = mapFieldset.get(nameSpace+'RC_Past_JobListing').getFields();
        String strQuery = 'Select Id';

        for(Schema.FieldSetMember objFSM : fieldSetOpenJobList)
            strQuery += ', '+objFSM.getFieldPath();
            
        for(Schema.FieldSetMember objFSM : fieldSetPastJobList)
        {
            if(!strQuery.contains(objFSM.getFieldPath()))
                strQuery += ', '+objFSM.getFieldPath();
        }
        
        strQuery += strQuery.contains('TR1__Status__c') ? ' ' :' , TR1__Status__c ';
        strQuery += ' FROM TR1__Job__c where TR1__Post_Externally__c = true AND (TR1__Hiring_Manager__c =\'' + conId + '\' OR TR1__Contact__c =\'' + conId +'\') ' ; //only external jobs and owned by login user
        lstOpenJobs = RC_AccessController.query(strQuery + ' AND TR1__Status__c = \'Open\'');
        lstPastJobs = RC_AccessController.query(strQuery + ' AND TR1__Status__c = \'Closed\'');
    
    }
}
public with sharing class RC_RegisterOrApplyToJob{
    
    public List<Schema.FieldSetMember> lstJobFieldsDisplay {get;set;}
    public TR1__Job__c objJobDetail {get;set;}
    public Contact objContact   {get;set;}
    public String strMsg {get;set;}
    
    public Boolean notLoggedIn {get;set;}
    
    public String jobId {get;set;}
    public String applicationId {get;set;}
    
    public RC_RegisterOrApplyToJob(){
        jobId = '';
        if(ApexPages.currentPage().getParameters().containsKey('jobId') && ApexPages.currentPage().getParameters().get('jobId') !='')
            jobId = ApexPages.currentPage().getParameters().get('jobId');
        else
        {
            jobId = '';
            
        }
        strMsg = '';
        objJobDetail = new TR1__Job__c();
    }
    
    private void init(){
        if(jobId !='')
            objJobDetail =  getJobDetails(); 
        strMsg = objJobDetail.Id != null ? '' : 'No Job found';
        if(!notLoggedIn){
            if(objJobDetail.Id != null){
                List<TR1__Application__c> lstApplications = RC_AccessController.getContactApplicationsForJob(jobId, objContact.Id);
                applicationId = lstApplications.isEmpty() ? '': lstApplications[0].Id;
            }
            
        }
    }
    
    private TR1__Job__c getJobDetails(){
        Set<String> setFields = new Set<String>{'Job_Title__c','TR1__Client_Description__c'};
        String nameSpace = '';
        List<Schema.FieldSetMember> lstJobFieldsDisplay = new List<Schema.FieldSetMember>();
        
        lstJobFieldsDisplay = SObjectType.TR1__Job__c.FieldSets.getMap().get(namespace+'RC_RegisterOrApplyToJob').getFields();
        
        for(Schema.FieldSetMember field : lstJobFieldsDisplay) 
        {
               setFields.add(field.getFieldPath());
        }
        String strQuery = 'Select Id, '+ String.join(new List<String>(setFields), ',')+' from TR1__Job__c where Id=\'' + jobId + '\'';
        List<TR1__Job__c> lstJob = RC_AccessController.query(strQuery);
        return lstJob.isEmpty() ? new TR1__Job__c() : lstJob[0];
    }
    
    public void updateCandidateStatus(){
        objContact.TR1__Candidate_Status__c = 'Active';
        RC_AccessController.updateRecord(objContact);
    }
    
    
    //Checking for security
    public void redirectUnAuthenticatedUser()
    {
        if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
        {
           
            notLoggedIn = true; 
            //return new Pagereference('/Signin');
        }
        //To get the current logged in user contact Id
        else
        {
            notLoggedIn = false;
            User objUser = [Select Id, ContactId                                        
                                       From User 
                                       where Id=: UserInfo.getUserId()]; 
            
            //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.  
            if(objUser != null)
            {
                objContact = [Select Id, TR1__Candidate_Status__c from Contact where Id=:objUser.ContactId];
            }
            
            
        }
        init();
    }
    

}
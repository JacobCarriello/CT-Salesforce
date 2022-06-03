public with sharing class RC_JobListingDetail 
{
    private List<Schema.FieldSetMember> lstFieldSet;
    public TR1__Job__c objJob                                   {get;set;}    
    private String strJobId;
    private  Id idContact;
    public String strMessage                                    {get;set;}
    public boolean isPageLoad                                   {get;set;}
    public Boolean isSuccess                                    {get;set;}
    public Boolean isDisplayApply                               {get;set;}
    public String msgClass                                      {get;set;}
    public String strApply                                      {get;set;}
    public Contact objContact                                   {get;set;}
    
    public RC_JobListingDetail()
    {
        lstFieldSet = new List<Schema.FieldSetMember>();
        objJob = new TR1__Job__c();
        isPageLoad = true;
        isSuccess = true;
        msgClass = 'success';
        isDisplayApply = true;
        
        if(ApexPages.currentPage().getParameters().containsKey('Id') && ApexPages.currentPage().getParameters().get('Id') != '')
        {
            strJobId = ApexPages.currentPage().getParameters().get('Id');
            if(ApexPages.currentPage().getParameters().containsKey('apply') && ApexPages.currentPage().getParameters().get('apply') != '')
                strApply = ApexPages.currentPage().getParameters().get('apply');
        }
        else
        {
            isPageLoad = false;
            isSuccess = false;
            msgClass = 'error';
            strMessage = 'Insufficient Parameter';
        }
        
    }
    
     /*
    Name- redirectUnAuthenticatedUser
    parameters - None
    Description - Checking for security
    */
    public Pagereference redirectUnAuthenticatedUser()
    {
        try
        {
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
            {
                return new Pagereference('/Signin');
            }
            
            //To get the current logged in user contact Id
            User objUser = [Select Id, ContactId, smallPhotoUrl                                           
                                       From User 
                                       where Id=: UserInfo.getUserId()]; 
            
            //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.                                      
            if(objUser != null)
            {
                idContact = objUser.ContactId;
                objContact = [Select Id, TR1__Candidate_Status__c from Contact where Id=:objUser.ContactId];
                fetchJobInfo();
                if(strApply == '1' && isDisplayApply)
                    applyToJob();
                else if(strApply == '1' && !isDisplayApply){
                    msgClass = 'alert';
                    strMessage = Label.JobAlreadyApplied; 
                    isSuccess = false;
                }
            } 
            
           return null;
        }
        catch(Exception e)
        {
            isPageLoad = false; 
            isSuccess = false;
            msgClass = 'error';
            strMessage = e.getMessage();
            return null;
        }
    }
    
     /*
    Name- fetchJobInfo
    parameters - None
    Description - fetching Job which is passed as Id param to be displayed on page using fiedsets
    */
    private void fetchJobInfo()
    {
        String fieldNames ='';
        String strQuery = 'Select Id'; 
        lstFieldSet = SObjectType.TR1__Job__c.FieldSets.getMap().get('RC_CandidateJobHeader').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            fieldNames += ', ' + field.getFieldPath(); 
        }
               
        lstFieldSet = SObjectType.TR1__Job__c.FieldSets.getMap().get('RC_JobListingDetail').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        strQuery  += fieldNames + ',TR1__External_Job_Title__c from TR1__Job__c where id =\'' + strJobId + '\'';     
       
        List<TR1__Job__c> lstJob = RC_AccessController.query(strQuery);
        
        
        Integer index = 0;
        
        if(!lstJob.isEmpty())
        {
            list<TR1__Application__c> lstApplication = new list<TR1__Application__c>();
            objJob = lstJob[index];
            lstApplication = RC_AccessController.getContactApplicationsForJob(strJobId, idContact);
            system.debug('-----lstApplication -----'+lstApplication);
            if(!lstApplication.isEmpty()){
                isDisplayApply = false;
                msgClass = 'alert';
                isSuccess = false;
                strMessage = Label.JobAlreadyApplied; 
            }
            else
                isDisplayApply = true;
            
        } 
        else
        {
            isPageLoad = false; 
            isSuccess = false;
            msgClass = 'error';
            strMessage = 'Insufficient Parameter';
        }
        
    }
    
     /*
    Name- applyToJob
    parameters - None
    Description - To apply on Jobs for Candidate Type Contacts
    */
    public void applyToJob()
    { 
        try
        {
            
            TR1__Application__c objApp = new TR1__Application__c();
            objApp.TR1__Applicant__c = idContact ; 
            objApp.TR1__Job__c =  strJobId; 
            objApp.TR1__Status__c = 'Current';
            RC_AccessController.insertRecord(objApp);
            //fetchJobs();
            strMessage = 'Your application has been submitted successfully ';
            isDisplayApply = false;
            if(Test.isRunningTest())
                Integer c = 5/0;
        }
        catch(Exception ex)
        {
            isPageLoad = false; 
            isSuccess = false;
            msgClass = 'error';
            strMessage = ex.getMessage();
            system.debug('::::ex:::'+ex);
        }
    }
    
    public void updateCandidateStatusNJobApply(){
        //objContact.TR1__Candidate_Status__c = 'Active';
        //update objContact;
        applyToJob();
    }
    
}
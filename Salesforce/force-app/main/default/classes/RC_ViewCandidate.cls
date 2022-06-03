/* 
    Developer Name: 
    Created Date: 
    Description:    
*/

public with sharing class RC_ViewCandidate 
{   
    public Contact objContact                                           {get;set;}      //To fetch the current user logged in user contact information
    Id idContact;                                                                       //To check the current logged in user have contact id / not
    
    public String strMessage                                            {get;set;}      //To show the error / success message 
    public boolean isSuccess                                            {get;set;}      //To show the error / success message panel
    public Boolean isPageLoad                                           {get;set;}    
    
    public String smallPhotoUrl                                         {get;set;}      //To show the photo on header
    
    private List<Schema.FieldSetMember> lstFieldSet;
    
    public String jobId                                                 {get;set;}
    private Id currentContactId;
    
    //Constructor
    public RC_ViewCandidate()
    {
        objContact = new Contact();
        lstFieldSet = new List<Schema.FieldSetMember>();
        strMessage = '';
        isPageLoad = true;
        currentContactId = [Select Id, ContactId, smallPhotoUrl From User where Id=: UserInfo.getUserId()].ContactId;
    }
    
    //Checking for security
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
                smallPhotoUrl = objUser.smallPhotoUrl;
            } 
            
            fetchContactInfo();
           return null;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    //To fetch the contact detail
    private void fetchContactInfo()
    {
        
        if(ApexPages.currentPage().getParameters().containsKey('id') && ApexPages.currentPage().getParameters().get('id') != '' && ApexPages.currentPage().getParameters().containsKey('JobId') && ApexPages.currentPage().getParameters().get('JobId') != '')
        {
        
            idContact = ApexPages.currentPage().getParameters().get('id');
            jobId = ApexPages.currentPage().getParameters().get('JobId');
            
            List<TR1__Job_Reporting__c> jobReportings = RC_AccessController.getJobReportingsForContact(jobId, idContact, currentContactId);
            System.debug('jobReportings ' + jobReportings);
            if(jobReportings.isEmpty()) {
                strMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params;
                isPageLoad = false;
                return;
            }
            
            Set<String> setFieldNames = new Set<String>{'Id'};
        
            lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_ViewCandidate').getFields();
        
            for(Schema.FieldSetMember field : lstFieldSet) 
                setFieldNames.add(field.getFieldPath());

        
            lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
            for(Schema.FieldSetMember field : lstFieldSet) 
                setFieldNames.add(field.getFieldPath());
            
            String strQuery = 'Select ' + String.join(new List<String>(setFieldNames), ',') + ', Consol_URL__c, Rating__c from Contact where id =\'' + idContact + '\'';  
           
            List<Contact> lstContact = RC_AccessController.query(strQuery);
            
            Integer index = 0;
            
            if(!lstContact.isEmpty())
                objContact = lstContact[index]; 
            else
            {
                strMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params;
                isPageLoad = false;
            }
                
        }
        else
        {
            strMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params;
            isPageLoad = false;
        }
    }  
   
}
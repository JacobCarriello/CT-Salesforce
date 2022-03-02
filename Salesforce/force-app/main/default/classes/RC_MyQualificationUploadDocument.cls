/* 
    Developer Name: 
    Created Date: 
    Description:    
*/

public with sharing class RC_MyQualificationUploadDocument
{   
    Id idContact;       
    String strQualificationId;
    
    public TR1__Associated_Qualification__c objAssociatedQualification  {get;set;}
    public Attachment objAttachment {get;set;}
    public string nextRedirectionPage {get;set;}
    public string prevRedirectionPage {get;set;}  
    
    private List<Schema.FieldSetMember> lstFieldSet;
    public Contact objContact           {get;set;}
    public Boolean isPageLoad   {get;set;}
    private integer index;
    //Constructor
    public RC_MyQualificationUploadDocument()
    {
        objAssociatedQualification = new TR1__Associated_Qualification__c();
        objAttachment = new Attachment();
        isPageLoad = false;
        index = 0;
    }
    
    //Page action
    public Pagereference redirectUnAuthenticatedUser()
    {
        if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
        {
            return new Pagereference('/Signin');
        }
        
        //To get the current logged in user contact Id
        idContact = [Select Id, ContactId                                           
                                   From User 
                                   where Id=: UserInfo.getUserId()].ContactId;
        
        //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.                                      
        if(idContact != null)
        {
            fetchContactInfo();
            fetchQualificationDetail();
            
        }
            
       return null;
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
               
        strQuery  += fieldNames + ' from Contact where id =: idContact' ;    
        system.debug('---strQuery-'+strQuery);
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
            
        system.debug('--lstContact--'+lstContact);
        system.debug('--objContact--'+objContact);
    } 
    
    
    //To fetch the contact detail
    private void fetchQualificationDetail()
    {
        string strCollectionMethods;
        try
        {
      
            if(System.currentPageReference().getParameters().containsKey('qId') && System.currentPageReference().getParameters().get('qId') != '')
            {
                strQualificationId = System.currentPageReference().getParameters().get('qId');
           
            
           
                 List <TR1__Associated_Qualification__c> lstAssociateQualification = RC_AccessController.getAssociatedQualificationsById(strQualificationId, idContact);
                 
                if(lstAssociateQualification.isEmpty())
                {
                    isPageLoad = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.RC_TimesheetApproveReject_Insufficient_Params));
                }
                else
                {
                    objAssociatedQualification = lstAssociateQualification[index];
                    
                    strCollectionMethods =  objAssociatedQualification.TR1__Qualification__r.TR1__Collection_Methods__c;
             
                    nextRedirectionPage = 'MyQualificationRedirect';
                    
                    isPageLoad = true; 
                        
                  /*  if(strCollectionMethods.contains('Docusign'))
                       prevRedirectionPage = 'MyQualificationDocuSign';
                    else if(strCollectionMethods.contains('Field Update'))
                       prevRedirectionPage = 'MyQualificationDetailEdit';
                    else
                       prevRedirectionPage = 'MyQualificationDetail'; */
                }
            }
            else
            {
                isPageLoad = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.RC_TimesheetApproveReject_Insufficient_Params));
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()+''+ex.getLineNumber()));
        }
           
    } 
    
    
    
    // Save the attachment for Qualification
    public Pagereference saveAttachment()
    {
        if(objAttachment.Body != null)
        {
            objAttachment.ParentId = objAssociatedQualification.Id;
            RC_AccessController.insertRecord(objAttachment);
        }
        
        if(objAssociatedQualification.TR1__Completed_Collection_Methods__c == null){
        objAssociatedQualification.TR1__Completed_Collection_Methods__c  = '';
      }
      if(!objAssociatedQualification.TR1__Completed_Collection_Methods__c.contains('Upload File')){
        objAssociatedQualification.TR1__Completed_Collection_Methods__c += ';Upload File;';
      }
        RC_AccessController.updateRecord(objAssociatedQualification);
        system.debug('--- nextRedirectionPage ----'+nextRedirectionPage);
        return new Pagereference('/'+nextRedirectionPage+'?qId='+objAssociatedQualification.Id);
        
    }
}
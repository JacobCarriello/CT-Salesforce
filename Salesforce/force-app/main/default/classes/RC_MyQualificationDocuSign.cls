/* 
    Developer Name: 
    Created Date: 
    Description:    
*/

public with sharing class RC_MyQualificationDocuSign
{   
    Id idContact;       
    String strQualificationId;
    public string nextRedirectionPage {get;set;}
    public string prevRedirectionPage {get;set;}  
    public Contact objCont {get;set;}
    public Boolean isPageLoad {get;set;}
    
    public TR1__Associated_Qualification__c objAssociatedQualification  {get;set;}    
    private  Integer index;
    
    //Constructor
    public RC_MyQualificationDocuSign()
    {
        objAssociatedQualification = new TR1__Associated_Qualification__c();
        index = 0;
        isPageLoad = false;
    }
    
    //Page action
    public Pagereference redirectUnAuthenticatedUsers()
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
            fetchQualificationDetail();
        }
            
       return null;
    }
    
    //To fetch the contact detail
    public void fetchContactInfo()
    {
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        List<Schema.FieldSetMember> lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        strQuery  += fieldNames + ' from Contact where id =: idContact' ;    
        
        List<Contact> lstContact = Database.query(strQuery);
        
       
        
        if(!lstContact.isEmpty())
            objCont = lstContact[index]; 
        
    } 
    
    //To fetch the contact detail
    private void fetchQualificationDetail()
    {
        string strCollectionMethods;
        
        if(System.currentPageReference().getParameters().containsKey('qId') && System.currentPageReference().getParameters().get('qId') != '')
        {
    
            strQualificationId = System.currentPageReference().getParameters().get('qId');
        
              List <TR1__Associated_Qualification__c> lstAssociateQualification = RC_AccessController.getAssociatedQualificationsById(strQualificationId, idContact);             
         
             if(!lstAssociateQualification.isEmpty())
             {
                strCollectionMethods =  lstAssociateQualification[index].TR1__Qualification__r.TR1__Collection_Methods__c;
                objAssociatedQualification = lstAssociateQualification[index];
        
         
                nextRedirectionPage = 'MyQualificationRedirect';
                
                if(strCollectionMethods.contains('Field Update'))
                    prevRedirectionPage = 'MyQualificationDetailEdit';
                else
                    prevRedirectionPage = 'MyQualificationsList';
                
                if(objAssociatedQualification.TR1__Completed_Collection_Methods__c == null){
                    objAssociatedQualification.TR1__Completed_Collection_Methods__c = '';
                }
                
                if(!objAssociatedQualification.TR1__Completed_Collection_Methods__c.contains('Docusign')){
                    objAssociatedQualification.TR1__Completed_Collection_Methods__c += ';Docusign;';
                }
                RC_AccessController.updateRecord(objAssociatedQualification);
                isPageLoad = true;
             }
            else
            {
                isPageLoad = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.RC_TimesheetApproveReject_Insufficient_Params));
            }
      
        }
        else
        {
            isPageLoad = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.RC_TimesheetApproveReject_Insufficient_Params));
        }
      
    } 
}
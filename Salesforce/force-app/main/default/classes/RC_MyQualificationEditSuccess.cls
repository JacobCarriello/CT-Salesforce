/* 
    Developer Name: 
    Created Date: 
    Description:    
*/

public with sharing class RC_MyQualificationEditSuccess
{   
    Id idContact;       
    String strQualificationId;
    
    public TR1__Associated_Qualification__c objAssociatedQualification  {get;set;}
    private List<Schema.FieldSetMember> lstFieldSet;
    public Contact objCont          {get;set;} 
    public boolean isPageLoad   {get;set;}
    private Integer index;
    //Constructor
    public RC_MyQualificationEditSuccess()
    {
        objAssociatedQualification = new TR1__Associated_Qualification__c();
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
            fetchAndUpdateQualification();
            fetchContactInfo();
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
            objCont = lstContact[index]; 
     
    } 
    
    //To fetch the contact detail
    private void fetchAndUpdateQualification()
    {
        if(System.currentPageReference().getParameters().containsKey('qId') && System.currentPageReference().getParameters().get('qId') != '')
        {
            strQualificationId = System.currentPageReference().getParameters().get('qid');
            
            List<TR1__Associated_Qualification__c> lstAssociatedQualification = RC_AccessController.getAssociatedQualificationsById(strQualificationId);
                 
            if(!lstAssociatedQualification.isEmpty())
            {
                lstAssociatedQualification[index].TR1__Status__c = 'Submitted';
                RC_AccessController.updateRecord(lstAssociatedQualification[index]);
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
        
        
        System.debug('--- objAssociatedQualification ---'+objAssociatedQualification);
    } 
}
/* 
    Developer Name: 
    Created Date: 
    Description:    
*/

public without sharing class RC_MyQualificationDetail
{   
    Id idContact;       
    string strQualificationId;
    
    public string strIssueDate  {get;set;} 
    public string strExpireDate {get;set;}
    public string strFieldSetName {get;set;}
    public string nextRedirectionPage {get;set;}
    public Contact objCont  {get;set;}
        
    public TR1__Associated_Qualification__c objAssociatedQualification  {get;set;}
    public boolean isPageLoad   {get;set;}
    private List<Schema.FieldSetMember> lstFieldSet;
    Private User loggedInUser;
    public String strDateFormat   {get;set;}
	 public Boolean isAmPmTime {get;set;}
    
    
    //Constructor
    public RC_MyQualificationDetail()
    {
        lstFieldSet = new List<Schema.FieldSetMember>();  
        isPageLoad = false;
        strDateFormat = (RC_RelatedListHistoryDetails.MapValues()).get(UserInfo.getLocale());
		isAmPmTime = (RC_RelatedListHistoryDetails.MapTimeZoneValues()).get(UserInfo.getLocale()) == '24' ? false : true;
    }
    
    //Checking for security
    public Pagereference redirectUnAuthenticatedUser()
    {
        if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
        {
            return new Pagereference('/Signin');
        }
        
        loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
        
       fetchCredentialDetail();
       fetchContactInfo();
            
       return null;
    }
    
    //To fetch the contact detail
    private void fetchCredentialDetail()
    {
      try{
        objAssociatedQualification = new TR1__Associated_Qualification__c();  
        
        Integer index = 0;
        
        TR1__Associated_Qualification__c objGetQualifcationFieldSet =  new TR1__Associated_Qualification__c();
        
        String fieldNames='';
        
        if(System.currentPageReference().getParameters().containsKey('qId') && System.currentPageReference().getParameters().get('qId') != '')
        {
            strQualificationId = System.currentPageReference().getParameters().get('qId');
       
    
            List <TR1__Associated_Qualification__c> lstAssociateQualification = [Select   TR1__Qualification__c, TR1__Qualification__r.TR1__Field_Set_ID__c,
                                                                                            TR1__Qualification__r.TR1__Collection_Methods__c
                                                                                            from TR1__Associated_Qualification__c where id =: strQualificationId];
                                                                                            
                                                                                            
            if(!lstAssociateQualification.isEmpty())
            {   
                nextRedirectionPage = 'MyQualificationRedirect';   
                strFieldSetName = lstAssociateQualification[index].TR1__Qualification__r.TR1__Field_Set_ID__c;
            
                if(SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().containsKey(strFieldSetName))
                {
                    
                    lstFieldSet = SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().get(strFieldSetName).getFields();
                    
                    for(Schema.FieldSetMember field : lstFieldSet) 
                        fieldNames += ', ' + field.getFieldPath();
                }
            
                String strQuery = 'Select Id, TR1__Associated_Qualification__c.TR1__Qualification__r.Name, '+
                ' TR1__Associated_Qualification__c.TR1__Qualification__r.TR1__Instructions_External__c, TR1__Completed_Collection_Methods__c ';
            
                string qalId = strQualificationId;
            
                strQuery  += fieldNames + ' from TR1__Associated_Qualification__c where id =: qalId';
            
                List<TR1__Associated_Qualification__c> lstAssociatedQualification = Database.Query(strQuery);
            
                if(!lstAssociatedQualification.isEmpty())
                    objAssociatedQualification = lstAssociatedQualification[0];
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
        catch(Exception ex)
        {
         system.debug('-- message --'+ex.getMessage());
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
        
        String strContactId =  loggedInUser.ContactId; 
        
        strQuery  += fieldNames + ' ,Community_Contact_Type__c from Contact where id =: strContactId' ;    
        
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objCont = lstContact[index]; 
        
    } 
    
    public Pagereference saveQualifaction()
    {
        try
        {
          if(objAssociatedQualification.TR1__Completed_Collection_Methods__c == null){
          objAssociatedQualification.TR1__Completed_Collection_Methods__c = '';
        }
        if(!objAssociatedQualification.TR1__Completed_Collection_Methods__c.contains('Field Update')){
          objAssociatedQualification.TR1__Completed_Collection_Methods__c += ';Field Update;';
        }
            update objAssociatedQualification;
            return new Pagereference('/'+nextRedirectionPage+'?qId='+strQualificationId);  
        }
        catch(Exception ex)
        {
            system.debug('--- ex ---'+ex);
            return null;
        }
       
    } 
    
}
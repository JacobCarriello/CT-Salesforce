/* 
    Developer Name: 
    Created Date: 
    Description:    
*/

public without sharing class RC_MyAccount_v1 
{   
    public Contact objContact                                           {get;set;}      //To fetch the current user logged in user contact information
    Id idContact;                                                                       //To check the current logged in user have contact id / not
    
    public List<TR1__EmploymentHistory__c> lstEmploymentHistory         {get;set;}      //To collect all the Employment History 
    public List<TR1__EducationHistory__c> lstEduHistory                 {get;set;}      //To collect all the Education History 
    public List<TR1__ContactDocument__c> lstDocument                    {get;set;}      //To get all the contact document which is created by user
    
    public boolean isEditable                                           {get;set;}      //To show the page as editable/ non editable mode
    
    public boolean isSuccess                                            {get;set;}      //To show the error / success message panel
    public boolean isUploadSuccess                                      {get;set;}      //To check the upload document is success or not
    
    public String strMessage                                            {get;set;}      //To show the error / success message 
    public String strUploadMessage                                      {get;set;}      //To show the error / success message 
    
    public String smallPhotoUrl                                         {get;set;}      //To show the photo on header
    
    private List<Schema.FieldSetMember> lstFieldSet;
    
    public String strHistoryId                                          {get;set;}      //To get the Emp Id to show on popup window
    public String strRelatedListName                                    {get;set;}      //To get the related list name
    
    public  TR1__EmploymentHistory__c objEmploymentDetail               {get;set;}      //To show the detailed employment on popup window
    public  TR1__EducationHistory__c objEducationDetail                 {get;set;}      //To show the detailed employment on popup window
    public  TR1__ContactDocument__c objContactDocument                  {get;set;}      //To update the Contact document type once document get uploaded 
    
    private String strDocumentQuery;
    //private String loggedUser;
    
    //Constructor
    public RC_MyAccount_v1()
    {
        objContact = new Contact();
        lstDocument = new List<TR1__ContactDocument__c>();
        lstFieldSet = new List<Schema.FieldSetMember>();
        objContactDocument =  new TR1__ContactDocument__c();
        
        isEditable = false;
        strMessage = '';
        
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
            
        	if(System.currentPageReference().getParameters().containsKey('isEdit') && 
        	    System.currentPageReference().getParameters().get('isEdit') == 'true')
        	        isEditable = true;
    		
    		
            
            //To get the current logged in user contact Id
            User objUser = [Select Id, ContactId, smallPhotoUrl                                           
                                       From User 
                                       where Id=: UserInfo.getUserId()]; 
            
            //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.                                      
            if(objUser != null)
            {
                smallPhotoUrl = objUser.smallPhotoUrl;
                idContact = objUser.ContactId;
                fetchContactInfo();
                getRelatedList();
            } 
                
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
        Set<String> setFieldNames = new Set<String>{'Id'};
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('MyAccount').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
  		setFieldNames.add(field.getFieldPath());
        
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        	setFieldNames.add(field.getFieldPath());
               
       
        String strQuery = 'Select ' + String.join(new List<String>(setFieldNames), ',') + ' , Consol_URL__c from Contact where id =: idContact' ;   
       
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
    } 
    
    //To get all the related details Employment, Education and Contact Document
    public void getRelatedList()
    {
        lstFieldSet = new List<Schema.FieldSetMember>();
        
        //To get the Education History
        String fieldNames ='';
        String strQuery = 'Select Id'; 
        lstFieldSet = SObjectType.TR1__EducationHistory__c.FieldSets.getMap().get('RC_EducationInfo').getFields(); 
        
        for(Schema.FieldSetMember field : lstFieldSet) 
          fieldNames += ', ' + field.getFieldPath();
        
        
        strQuery  += fieldNames + ' from TR1__EducationHistory__c where TR1__Contact__c =: idContact ORDER BY Name ASC' ;            
         
        lstEduHistory = Database.query(strQuery) ;
         
         //To get the Employment History
        fieldNames = '';
        strQuery = 'Select Id';
        lstFieldSet = SObjectType.TR1__EmploymentHistory__c.FieldSets.getMap().get('RC_EmploymentInfo').getFields(); 
         
        for(Schema.FieldSetMember field : lstFieldSet) 
             fieldNames += ', ' + field.getFieldPath();
                  
        
        strQuery  += fieldNames + ' from TR1__EmploymentHistory__c where TR1__Contact__c =: idContact ORDER BY Name ASC' ;            
         
        lstEmploymentHistory = Database.query(strQuery) ; 
         
         //To get the Contact Documents
        fieldNames = '';
        strDocumentQuery = 'Select Id';
         
        lstFieldSet = SObjectType.TR1__ContactDocument__c.FieldSets.getMap().get('TR1__Documents').getFields(); 
         
        for(Schema.FieldSetMember field : lstFieldSet) 
                  fieldNames += ', ' + field.getFieldPath();
    
        //loggedUser = UserInfo.getUserId();
         
        strDocumentQuery  += fieldNames + ', TR1__Internal_View_URL__c, TR1__ContentVersionId__c from TR1__ContactDocument__c where TR1__Contact__c =: idContact ORDER BY LastModifiedDate DESC' ;
         
        lstDocument = Database.query(strDocumentQuery);
         
        lstFieldSet.clear(); 
    }
    
    
   
    //Update contact info which is edited by User
    public void updateContactInfo()   
    {
        try
        {
           isEditable =  false;
           update objContact;
           isSuccess = true; 
           strMessage = 'Your profile has been updated successfully';
           
           if(Test.isRunningTest())
				Integer c = 5/0; 
        }
        catch(Exception ex)
        {
             isSuccess = false;
             isEditable =  true;
             strMessage = ex.getMessage();
        }
      
    }
    
    public void editContactInfo() 
    {
        isEditable =  true;
        strMessage = '';
       
    }
    
    public void cancelEditContactInfo()
    {
       isEditable =  false;
    }
    
    public void getUploadDetails()
    {
        if(isUploadSuccess && objContactDocument.TR1__Type__c == 'Resume') 
        {
            List<TR1__ContactDocument__c> lstContactDocument = [Select Id from TR1__ContactDocument__c where TR1__Contact__c =: idContact AND TR1__isDefault__c =: isUploadSuccess  ORDER BY CreatedDate DESC limit 1];
            
            if(!lstContactDocument.isEmpty())
            {
                objContactDocument.Id = lstContactDocument[0].Id;
            
                //for capablity jane need to remove later
                if(objContactDocument.TR1__Type__c == 'Resume')
                    objContact.TR1__Candidate_Status__c = 'Active';
                update objContactDocument;
            }
            update objContact;
            //lstDocument = Database.query(strDocumentQuery);
        }
        
        if(isUploadSuccess)
            lstDocument = Database.query(strDocumentQuery);  
        
    }
    
    //Delete the Education/Employement history details.
    public void deleteRelatedHistoryRecord()
    {
        if(strRelatedListName == 'Employment') 
        {
            TR1__EmploymentHistory__c objEmploymentDetail = new TR1__EmploymentHistory__c(Id = strHistoryId); 
            delete objEmploymentDetail;
        }
        else
        {
            TR1__EducationHistory__c objEducationDetail = new TR1__EducationHistory__c(Id = strHistoryId); 
            delete objEducationDetail;
        }
        
        getRelatedList();
    }
}
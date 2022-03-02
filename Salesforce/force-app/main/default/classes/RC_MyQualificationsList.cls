public with sharing class RC_MyQualificationsList 
{
	Id idContact;                                               
    public List<TR1__Associated_Qualification__c> lstQualifications { get; set; }
    private List<Schema.FieldSetMember> lstFieldSet;
    public Contact objContact			{get;set;}
    
    //Constructor
    public RC_MyQualificationsList ()
    {
        lstQualifications = new List<TR1__Associated_Qualification__c>(); 
        lstFieldSet = new List<Schema.FieldSetMember>();
        objContact = new Contact();
    }
    
    //Checking for security
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
            fetchCredentialsInfo();
            fetchContactInfo();
        }
            
       return null;
    }
    
    //To fetch the contact detail
    private void fetchCredentialsInfo()
    {
    	
    	String fieldNames ='';
        String strQuery = 'Select Id'; 
        lstFieldSet = SObjectType.TR1__Associated_Qualification__c.FieldSets.getMap().get('RC_QualificationInfo').getFields(); 
        
        for(Schema.FieldSetMember field : lstFieldSet) 
          fieldNames += ', ' + field.getFieldPath();
        
        
         strQuery  += fieldNames + ' from TR1__Associated_Qualification__c where TR1__Contact__c =\'' + idContact + '\' ORDER BY Name ASC' ;            
         
         lstQualifications = RC_AccessController.query(strQuery) ;
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
}
/** 
 *  This class is used with 'TravelDetailsListing' vf page, on Travel Details tab on RC community.[TR-3227]
**/
public with sharing class RC_TravelDetailsListingController {
    
    //Properties
    Id idContact;                                               
    public List<TR1__Worker_Comp__c> travelDetails { get; set; }
    private List<Schema.FieldSetMember> lstFieldSet;
    public Contact contact   {get;set;}
    
    //Constructor
    public RC_TravelDetailsListingController ()
    {
        travelDetails = new List<TR1__Worker_Comp__c>();  
        lstFieldSet = new List<Schema.FieldSetMember>();
        contact = new Contact();
    }
    
    //Checking for security
    public Pagereference redirectUnAuthenticatedUser() {
        if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess') {
            return new Pagereference('/Signin');
        }
        
        //To get the current logged in user contact Id
        idContact = [Select Id, ContactId From User 
                     Where Id=: UserInfo.getUserId()].ContactId;
        
        //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.                                      
        if(idContact != null) {
            
            //Call the methods
            fetchTravelDetailsInfo();
            fetchContactInfo();
        }
        
        //Return 
        return null;
    }
    
    //To fetch the contact detail
    private void fetchTravelDetailsInfo() {
        
        //Properties to hold the data
        String fieldNames ='';
        String strQuery = 'Select Id'; 
        lstFieldSet = SObjectType.TR1__Worker_Comp__c.FieldSets.getMap().get('RC_TravelDetailsInfo').getFields(); 
        
        //Loop through the fieldset values
        for(Schema.FieldSetMember field : lstFieldSet) 
            fieldNames += ', ' + field.getFieldPath();
        
        strQuery  += fieldNames + ' from TR1__Worker_Comp__c where Contact__c =\'' + idContact + '\' ORDER BY Name ASC' ;            
        
        travelDetails = RC_AccessController.query(strQuery) ;
    } 
    
    //To fetch the contact detail
    private void fetchContactInfo() {
        String fieldNames ='';
        String strQuery = 'Select Id'; 
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        strQuery  += fieldNames + ' from Contact where id =: idContact' ;    
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            contact = lstContact[index]; 
    } 
}
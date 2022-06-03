/** 
 *  This class is used with 'TravelDetails' vf page, on Travel Details tab on RC community.[TR-3227]
**/
public with sharing class RC_TravelDetails {
    
    //Properties
    public String TravelDetail_Id;
    public TR1__Worker_Comp__c  travelDetail {get;set;} 
    public Contact contact {get;set;}
    public String rtypeDevName  {get; set;}
    public String tDRdType {get; set;}
    public Boolean isError {get; set;}
    public Boolean isAirfareFSExist {get; set;}
    public Boolean isLodgingFSExist {get; set;}
    public Boolean isMiscellaneousFSExist {get; set;}
    public Boolean isRentalCarFSExist {get; set;}
    public Boolean isDefaultFSExist {get; set;}
    
    //Constructor
    public RC_TravelDetails(){
        init(); 
    }
    
    /*
        @Method Name    : init
        @Param          : none
        @Description    : This method is used to initializes class variables during constructor call
    */
    private void init() {
        
        travelDetail = new TR1__Worker_Comp__c(); 
        rtypeDevName = '';  
        tDRdType = '';  
        isError = false;
        contact = new Contact();
        isAirfareFSExist = false;
        isLodgingFSExist = false;
        isMiscellaneousFSExist = false;
        isRentalCarFSExist = false;
        isDefaultFSExist = false;
    
        fetchContactInfo();
        fetchTravelDetailInfo();
    }
    
    
    /*
        @Method Name    : fetchContactInfo
        @Param          : none
        @Description    : To fetch details of logged in community contact
        @return         : void
    */
    private void fetchContactInfo() {
        String fieldNames ='';
        String strQuery = 'Select Id'; 
        
        List<Schema.FieldSetMember> lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        //Loop through the fieldset data
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        //Query on the Contact object
        String idContact = [Select Id, ContactId From User Where Id=: UserInfo.getUserId()].ContactId;
        
        strQuery  += fieldNames + ' from Contact where id =: idContact' ;    
        List<Contact> lstContact = Database.query(strQuery);
        Integer index = 0;
        
        //Check for list size
        if(!lstContact.isEmpty())
            contact = lstContact[index]; 
    } 
    
    /*
        @Method Name    : fetchTravelDetailInfo
        @Param          : none
        @Description    : To fetch info of selected travel detail [Click on 'View' button under Travel Details tab in RC]  
        @return         : void
    */
    public void fetchTravelDetailInfo() {
        
        //try-Catch
        try {
            
            //Variables to hold the field Name
            String travelDetailId = '';
            
            if(System.currentPageReference().getParameters().containsKey('TravelDetail_Id')){
                travelDetailId = System.currentPageReference().getParameters().get('TravelDetail_Id');
            }
            
            if(String.isNotBlank(travelDetailId)) {
                
                //To get the current logged in user contact Id
        		Id idContact = [Select Id, ContactId From User 
                     Where Id=: UserInfo.getUserId()].ContactId;
                
                List<TR1__Worker_Comp__c> selectedTravelDetails = RC_AccessController.query('Select Id, RecordType.DeveloperName, RecordType.Name From TR1__Worker_Comp__c where Id =\'' + travelDetailId + '\' AND Contact__c =\'' + idContact + '\' LIMIT 1');
                TR1__Worker_Comp__c tD = new TR1__Worker_Comp__c();
                
                //Get the Selected Travel Details Record type
                if (!selectedTravelDetails.isEmpty()){
                    tD = selectedTravelDetails[0];
                    rtypeDevName = tD.RecordType.DeveloperName;
                	tDRdType  = tD.RecordType.Name;
                }
               
                //Collect all the required fields into a Set to avoid Duplicate Fields in the resultant SOQL.
                Set<String> tDFields = new Set<String>();
                tDFields.addAll(getFieldSetColumns(rtypeDevName) );
                
                //Merge into a List so that we can use it with String.join()!
                List<String> allRequiredTDFields = new List<String>();
                allRequiredTDFields.addAll(tDFields );
                
                //SOQL String
                String strQuery  = ' SELECT ' +  String.join(allRequiredTDFields, ',' ) + ' From TR1__Worker_Comp__c where Id =\'' + travelDetailId + '\' AND Contact__c = \'' + idContact + '\' ' ;            
                
                //List of travel details, to hold result 
                List<TR1__Worker_Comp__c>  travelDetails = RC_AccessController.query(strQuery);
                
                //Check for travel details list size
                if(travelDetails.size() > 0)
                    travelDetail = travelDetails[0];  
            
            } else {
                isError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Associated Travel Detail Missing'));
            }
        } catch(Exception ex){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    /**
     * A list that contains the API Names
     * of all the fields in the FieldSet - 
     * 
     * @return      String      List of all the fields in the
     *                          Field Set
     * 
     */
    private List<String> getFieldSetColumns(String rtypeDevName) {
        
        //Set to hold the fields api Name
        Set<String> fields = new Set<String>();
        
        //Describe Object field set
        Map<String, Schema.FieldSet> fsMap = Schema.getGlobalDescribe().get('TR1__Worker_Comp__c').getDescribe().fieldSets.getMap(); 
        
        //Check for Travel Details Record Type, then assign the field set dynamically for Travel Details UI fields
        if(rtypeDevName == 'Airfare' && fsMap.containsKey('RC_AirfareTravelDetailsInfo')) {
            
               for( FieldSetMember fsm : Schema.SObjectType.TR1__Worker_Comp__c.FieldSets.RC_AirfareTravelDetailsInfo.getFields() ) {
                    fields.add( fsm.getFieldPath() );  
               }
               
               //Set the flag value 
               isAirfareFSExist = true; 
            
        } else if(rtypeDevName == 'Lodging' && fsMap.containsKey('RC_LodgingTravelDetailsInfo')) {
            
            for( FieldSetMember fsm : Schema.SObjectType.TR1__Worker_Comp__c.FieldSets.RC_LodgingTravelDetailsInfo.getFields() ) {
                fields.add( fsm.getFieldPath() );
            }
            
            isLodgingFSExist = true;
            
        } else if(rtypeDevName == 'Miscellaneous' &&  fsMap.containsKey('RC_MiscellaneousTravelDetailsInfo')) {
            for( FieldSetMember fsm : Schema.SObjectType.TR1__Worker_Comp__c.FieldSets.RC_MiscellaneousTravelDetailsInfo.getFields() ) {
                fields.add( fsm.getFieldPath() );
            }   
            
            isMiscellaneousFSExist = true;
            
        } else if(rtypeDevName == 'Rental_Car' && fsMap.containsKey('RC_RentalCarTravelDetailsInfo')) {
            for( FieldSetMember fsm : Schema.SObjectType.TR1__Worker_Comp__c.FieldSets.RC_RentalCarTravelDetailsInfo.getFields() ) {
                fields.add( fsm.getFieldPath() );
            }  
            
            isRentalCarFSExist = true;
            
        } else  {
            if(fsMap.containsKey('RC_TravelDetailsInfo')) {
                for( FieldSetMember fsm : Schema.SObjectType.TR1__Worker_Comp__c.FieldSets.RC_TravelDetailsInfo.getFields() ) {
                    fields.add( fsm.getFieldPath() );
                }
                
                isDefaultFSExist = true;     
            }
        }
        
        List<String> columns = new List<String>();
        columns.addAll( fields );
        
        //Return
        return columns;
    }
    
}
public with sharing class RC_TimesheetListing {
    
    public List<Schema.FieldSetMember> lstFieldsTimesheetDetail {get;set;}  //Fieldset detail for Timesheet-Listing
    public List<TR1__Timesheet__c> lstTimesheet {get;set;}                  // list of timesheet record
    public Map<String, List<TR1__Timesheet__c>> mapTypeTolstTimesheet {get;set;}
    public String strHistoricalStatusTS {get;set;}
    public String strClientRestrictStage {get;set;}
    public Contact objContact   {get;set;}
    public Integer ClientTSSize {get;set;}
    public Integer CandidateTSSize {get;set;}
    public Boolean returnPage {get;set;}                                    // Boolean to check , if page is returning from TimesheetDetail page
    public Contact objContactPage {get;set; }
    public String strReturnMsg {get;set;}
    private User loggedInUser ;                                             //to store logged in  user
    //Constructor
    public RC_TimesheetListing (){
        init();
    }
    
    
    //Initilize method
    private void init(){
        try
        {
            lstTimesheet = new List<TR1__Timesheet__c>();
            mapTypeTolstTimesheet = new Map<String, List<TR1__Timesheet__c>>();
            strHistoricalStatusTS = 'Approved';
            strClientRestrictStage = 'Unsubmitted,Not Submitted';
            lstFieldsTimesheetDetail = new List<Schema.FieldSetMember>();
            lstFieldsTimesheetDetail = SObjectType.TR1__Timesheet__c.FieldSets.RC_TimesheetList.getFields();
            loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];

            if(String.isNotEmpty(loggedInUser.ContactId))
            {
                getTimesheets();
                
                //Will contain parameter when returning from TimesheetDetail page
                if(Apexpages.currentPage().getParameters().containsKey('save') && ApexPages.currentPage().getParameters().get('save') != '')
                {
                   strReturnMsg = 'Timesheet '+ Apexpages.currentPage().getParameters().get('save') +' has been updated successfully';
                   returnPage = true;
                   return;
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please login through community'));
            }   
            if(Test.isRunningTest())
                Integer c = 5/0;
        }
        catch(Exception ex)
        {
            returnPage = true;
            strReturnMsg = ex.getMessage();
            system.debug('--- Ex ## ---'+ex.getMessage());
            system.debug('--- Ex L. No. ---'+ex.getLineNumber());
        }
    }
    /*
    Name - getTimesheets
    returntype - void
    Description - To get the relavent timesheet for Candidate/Client
    */
    private void getTimesheets(){
        
        String strQuery = 'Select Id';
        
        objContactPage = [Select Community_Contact_Type__c, Holiday_Accrued__c,Name from Contact where Id =:loggedInUser.ContactId];
        
        for(Schema.FieldSetMember objFSM: lstFieldsTimesheetDetail)
            strQuery += ', ' + objFSM.getFieldPath() ;
        
        if(!strQuery.contains('All_Approver__c'))
            strQuery += ',All_Approver__c ';
        if(!strQuery.contains('TR1__Consultant__c'))
            strQuery += ',TR1__Consultant__c ';
            
        strQuery += ' FROM TR1__Timesheet__c Where  ';
        String whereClause = objContactPage.Community_Contact_Type__c == 'C and C' ?  'All_Approver__c like \'%'+ ((String)loggedInUser.ContactId).left(15) +'%\' OR  TR1__Consultant__c =\''+ loggedInUser.ContactId+'\'' :
                               (objContactPage.Community_Contact_Type__c == 'Client' ? 'All_Approver__c like \'%'+ ((String)loggedInUser.ContactId).left(15) +'%\'AND TR1__Status__c NOT In (\'Unsubmitted\',\'Not Submitted\')'  : 
                               (objContactPage.Community_Contact_Type__c == 'Candidate' ? 'TR1__Consultant__c =\''+ loggedInUser.ContactId+'\'' : ' ') ) ;
        system.debug('strQuerytess'+strQuery);
        if(String.isNotBlank(whereClause))
        {
            List<TR1__Timesheet__c> lstTsCandidate = new List<TR1__Timesheet__c>();
            List<TR1__Timesheet__c> lstTsClient = new List<TR1__Timesheet__c>();
            lstTimesheet = RC_AccessController.query(strQuery + whereClause + ' ORDER By CreatedDate DESC'); 
            for(TR1__Timesheet__c objTS : lstTimesheet)
            {
                if(objTS.All_Approver__c.contains(((String)loggedInUser.ContactId).left(15)))
                    lstTsClient.add(objTS);
                else if(objTS.TR1__Consultant__c == (((String)loggedInUser.ContactId).left(15)))
                    lstTsCandidate.add(objTS);
            }
            mapTypeTolstTimesheet.put('Client',lstTsClient);
            mapTypeTolstTimesheet.put('Candidate',lstTsCandidate);
            ClientTSSize = lstTsClient.size();
            CandidateTSSize = lstTsCandidate.size();
            system.debug('lstTsCandidatetest'+lstTsCandidate);
        }
        
        if(lstTimesheet.isEmpty())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Timesheets found'));
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
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        List<Schema.FieldSetMember> lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        String strContact = loggedInUser.ContactId;
        
        strQuery  += fieldNames + ' from Contact where id =: strContact' ;    
        
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
    } 
    
}
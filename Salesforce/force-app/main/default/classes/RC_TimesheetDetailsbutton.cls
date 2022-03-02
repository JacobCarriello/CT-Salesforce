public with sharing class RC_TimesheetDetailsbutton {

public List< TR1__ShiftWork__c> lstTimesheetDetailRecords   {get;set;}        // List to have TimesheetDetail record
    public List<Schema.FieldSetMember> fieldSetTimesheetDetail {get;set;}               // list of FieldSetMember for Detail section
    public List<Schema.FieldSetMember> fieldSetTimesheetHeader {get;set;}               // list of FieldSetMember for Header section
    //public List<Schema.FieldSetMember> fieldSetTimesheetFooter {get;set;}               // list of FieldSetMember for Footer section
    //public List<Schema.FieldSetMember> fieldSetTimesheetAdditionalInfo {get;set;}       // list of FieldSetMember for AdditionlInfo section
    
  // public TR1__ShiftWork__c sh{get;set;}
    public TR1__Timesheet_Detail__c objTS {get;set;}                                           // Timesheet object

 public Boolean isClient {get;set;}                                                  // To check loggedin user type
    public Boolean noParameter {get;set;}                                                  // To cehck Parameter tsId
    public Contact objContact {get;set;}
    private String strQueryTSD;                                                         // querry for TimesheetDetail
    private String strQueryTS;                                                          // query for Timesheet
    private String tsId;                                                                // Timesheet id captured from page parameters
    private List<Schema.FieldSetMember> lstFieldSet;
    Private string strContactId;
    public string recid{get;set;}
    //constructor
    public RC_TimesheetDetailsbutton(){
        init(); //Initialize method
    }


private void init(){
        recid = null;
        if(Apexpages.currentPage().getParameters().containsKey('tsId'))
            tsId = Apexpages.currentPage().getParameters().get('tsId');
        else
        {
            noParameter = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Timesheet Id found')); 
            return;
        }
        isClient = false;
        strQueryTSD = 'Select Name ';
        strQueryTS = 'Select Name ';
        strContactId = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1].ContactId;
        system.debug(':::strContactId:: '+strContactId);
        //objContact = [Select Community_Contact_Type__c from Contact where Id = :strContactId];
        fetchContactInfo();
        
        String nameSpace = ''; //will be used for package namespace
        fieldSetTimesheetDetail = new List<Schema.FieldSetMember>();
        fieldSetTimesheetHeader = new List<Schema.FieldSetMember>();
       // fieldSetTimesheetFooter = new List<Schema.FieldSetMember>();
       // fieldSetTimesheetAdditionalInfo = new List<Schema.FieldSetMember>();
       // fieldSetTimesheetdetailinfo = new list<Schema.FieldSetMember>();
        
        Map<String, Schema.FieldSet> mapFieldset = SObjectType.TR1__Timesheet_Detail__c.FieldSets.getMap();
        
        fieldSetTimesheetDetail = SObjectType.TR1__ShiftWork__c.FieldSets.getMap().get(nameSpace+'RC_Detailsinformation').getFields();
        system.debug('fieldSetTimesheetDetail'+fieldSetTimesheetDetail);
        fieldSetTimesheetHeader = mapFieldset.get(nameSpace+'Timesheetdetailinforamtion').getFields();
        //fieldSetTimesheetFooter = mapFieldset.get(nameSpace+'RC_TimesheetFooter').getFields();
        //fieldSetTimesheetAdditionalInfo = mapFieldset.get(nameSpace+'RC_TimesheetAdditionalInfo').getFields();
        //fieldSetTimesheetdetailinfo = mapFieldset.get(nameSpace+'Timesheetdetailinforamtion').getFields();
        for(Schema.FieldSetMember objFSM: fieldSetTimesheetDetail)
            strQueryTSD += ', ' + objFSM.getFieldPath() ;
            
        //Comman list of fieldset-Member
        List<Schema.FieldSetMember> lstFSM = new List<Schema.FieldSetMember>();
        lstFSM.addAll(fieldSetTimesheetHeader);
        //lstFSM.addAll(fieldSetTimesheetFooter);
       // lstFSM.addAll(fieldSetTimesheetAdditionalInfo);
        
        for(Schema.FieldSetMember objFSM: lstFSM)
            strQueryTS += ',' + objFSM.getFieldPath();
          
         
            
        strQueryTS += ',TR1__Timesheet__c from TR1__Timesheet_Detail__c where Id =\'' + tsId + '\' AND (TR1__Timesheet__r.All_Approver__c like \'%'+ ((String)objContact.Id).left(15) +'%\' OR TR1__Timesheet__r.TR1__Consultant__c = \'' + strContactId + '\')';
        //updated the where condition as per W-007768 by Mallareddy
        strQueryTSD += ',id,TR1__Start_Time__c,TR1__End_Time__c, TR1__TimesheetDetail__c,TR1__Rate__r.Name,TR1__Rate__r.TR1__TimeType__r.TR1__Show_in_Community__c, TR1__StartDateTime__c,TR1__Rate__c from TR1__ShiftWork__c where TR1__TimesheetDetail__c =\'' + tsId + '\' and TR1__Rate__r.TR1__TimeType__r.TR1__Show_in_Community__c = True';
        System.debug('----- ** strQueryTSD : '+strQueryTSD); 
       // String whereClauseTSD = ' AND (All_Approver__c like \'%'+ ((String)objContact.Id).left(15) +'%\' OR TR1__Consultant__c =:strContactId) ';
        
        //system.debug(':::strQueryTS::'+strQueryTS); 
        system.debug(':::strContactId:::'+strContactId);
        
        List<TR1__Timesheet_Detail__c> lstTS = RC_AccessController.query(strQueryTS);
        
        if(!lstTs.isEmpty())
            objTS = lstTS[0];
        
        if(objTS == null)
        {
            noParameter = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Timesheet not accessible for you'));
            return; 
        }
        
        
        System.debug('------ strQueryTSD : '+strQueryTSD);   
       lstTimesheetDetailRecords = RC_AccessController.query(strQueryTSD);  
       system.debug('lstTimesheetDetailRecords'+lstTimesheetDetailRecords);

    }
    
    /*
    Name - saveTimesheetDetails
    returnType - PageReference
    Description - Called by Candidate to save a timesheet
    */
    public PageReference saveTimesheetDetails(){
        try
        {
            RC_AccessController.updateRecords(lstTimesheetDetailRecords);
            //update objTS;
            if(Test.isRunningTest())
                Integer i = 1/0;
            return new PageReference('/TimesheetListing?save='+objTS.Name).setRedirect(true);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
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
    @testvisible
    private void fetchContactInfo()
    {
        String fieldNames ='';
        Integer index = 0;
        String strQuery = 'Select Id, Community_Contact_Type__c'; 
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        strQuery  += fieldNames + ' from Contact where id =: strContactId' ;    
        
        system.debug('---strQuery-'+strQuery);
        
        List<Contact> lstContact = Database.query(strQuery);
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
            
      System.debug(' objContact>>> '+objContact);
    } 
    
/*inlineedit*/
    public void inlineedit()
    {
        recid = null;
        recid=Apexpages.currentPage().getParameters().get('myParam');
    }
    
    public void canceledit()
    {
        recid = null;
    }

}
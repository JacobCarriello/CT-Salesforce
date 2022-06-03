public with sharing class RC_Shiftwork {

public List< TR1__ShiftWork__c> lstTimesheetDetailRecords   {get;set;}        // List to have TimesheetDetail record
    public List<Schema.FieldSetMember> fieldSetTimesheetDetail {get;set;}               // list of FieldSetMember for Detail section
    public List<Schema.FieldSetMember> fieldSetTimesheetHeader {get;set;}               // list of FieldSetMember for Header section
    public List<Schema.FieldSetMember> fieldSetTimesheetFooter {get;set;}               // list of FieldSetMember for Footer section
    public List<Schema.FieldSetMember> fieldSetTimesheetAdditionalInfo {get;set;}       // list of FieldSetMember for AdditionlInfo section
    list<SelectOption> options {get;set;} 
    //list<SelectOption> optionss {get;set;}
   public Boolean inTimeOutTimeError {get;set;}    
   public Boolean isError {get;set;}
   public String selectedRecordType{get;set;} 
   //public String selectedRecordTypes{get;set;} 
   public TR1__ShiftWork__c sh{get;set;}
   public TR1__TimeType__c timetype{get;set;}
   public string ratetitmetype{get;set;}
   public string rTsId{get;set;}
   public TR1__ShiftWork__c shift(TR1__ShiftWork__c shiftNew){
     this.sh=shiftNew;
     return sh;
   }
    public TR1__Timesheet_Detail__c objTS {get;set;}        
     //public TR1__Timesheet__c objT {get;set;}                                           // Timesheet object

 public Boolean isClient {get;set;}                                                  // To check loggedin user type
    public Boolean noParameter {get;set;}                                                  // To cehck Parameter tsId
    public Contact objContact {get;set;}
    private String strQueryTSD;                                                         // querry for TimesheetDetail
    private String strQueryTS;                                                          // query for Timesheet
    public String tsId;                                                                // Timesheet id captured from page parameters
    private List<Schema.FieldSetMember> lstFieldSet;
    Private string strContactId;
    
    //
   public list<TR1__Rate__c> rt{get;set;}
   //public list<TR1__Purchase_Order__c > rtt{get;set;}
   //public list<TR1__Timesheet_Detail__c> slistcl{get;set;}
   public boolean show1{get;set;}
   public boolean show2{get;set;}
   public TR1__Timesheet_Detail__c slist;
    
    //constructor
    public RC_Shiftwork(){
        show1= false;
        show2= false;
        inTimeOutTimeError = false ;
        init(); //Initialize method
        
        sh=new TR1__ShiftWork__c();
        
        /*lookupdropdown*/
         slist = RC_AccessController.getTimesheetDetailById(tsId);//TR1__TimeType__r.RecordType.name = 'Timesheet Time Type' AND TR1__TimeType__r.RecordType.name,   TR1__ClosingReport__c =:slist.TR1__Timesheet__r.TR1__Closing_Report__c
         //rt=[select id,name,TR1__TimeType__c,TR1__Timesheet__c,TR1__TimeType__r.TR1__Show_in_Community__c, TR1__TimeType__r.TR1__EntryType__c, TR1__Active__c,TR1__TimeType__r.Name from TR1__Rate__c where  TR1__TimeType__r.RecordType.developername = 'Timesheet_Time_Type' and TR1__Active__c = true AND TR1__Timesheet__c =:rTsId AND TR1__TimeType__r.TR1__Show_in_Community__c=true];
        rt= RC_AccessController.getTimesheetRatesByTimesheetId(rTsId);
        system.debug('>>>'+rt);
        list<string> slist1=new list<string>();
        for(TR1__Rate__c g:rt){
           slist1.add(g.name); 
        }
     }
     
    public void amountslection(){
        show1= false;
        show2= false;
        string ss;
        ss = selectedRecordType;
        if(ss!=null){ 
            system.debug('sssss'+ss);
             TR1__Rate__c r= RC_AccessController.getTimesheetRateById(ss);
             system.debug('rrrrr'+r.TR1__TimeType__r.TR1__EntryType__c);
             system.debug('timetype'+r.TR1__TimeType__r.Name);
             ratetitmetype = r.TR1__TimeType__r.Name; 
             if(r.TR1__TimeType__r.TR1__EntryType__c =='Hours & Minutes'){
            show1= true;
            }
            else if(r.TR1__TimeType__r.TR1__EntryType__c =='Start & Finish'){
            show2= true;
            
            }
         }
         
        system.debug('show1rr'+show1);
        system.debug('show2dd'+show2);
       
    }
   
/* lookupdropdownend*/
        

   // }
 /*   public list<SelectOption> getRecordType1s() 
   { 
      optionss = new list<SelectOption>(); 
      if(!slistcl.ISEmpty())
      {
        optionss.add(new selectOption('', '- None -'));
        for(TR1__Timesheet_Detail__c ttd:slistcl)
        {
            if(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.TR1_INV__Purchase_Order__c != null && ttd.TR1__Timesheet__r.TR1__Closing_Report__r.TR1_INV__Purchase_Order__r.Name != null)
            optionss.add(new selectOption(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.TR1_INV__Purchase_Order__c, ttd.TR1__Timesheet__r.TR1__Closing_Report__r.TR1_INV__Purchase_Order__r.Name));
            if(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order2__c != null && ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order2__r.Name != null)
            optionss.add(new selectOption(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order2__c, ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order2__r.Name));
            if(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order3__c != null && ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order3__r.Name != null)
            optionss.add(new selectOption(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order3__c, ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order3__r.Name));
            if(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order4__c != null && ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order4__r.Name != null)
            optionss.add(new selectOption(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order4__c, ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order4__r.Name));
            if(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order5__c != null && ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order5__r.Name != null)
            optionss.add(new selectOption(ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order5__c, ttd.TR1__Timesheet__r.TR1__Closing_Report__r.Purchase_Order5__r.Name));
        }
     }
     else{
         optionss.add(new selectOption('', '- None -'));
     }
      return optionss; 
  }  */
   // Map<string,string> maptimetype = new map<string,string>();
    public list<SelectOption> getRecordTypes() 
   { 
      options = new list<SelectOption>(); 
      options.add(new selectOption('', '- None -'));
      for(TR1__Rate__c r:rt) 
      { 
         if(r != null) 
         {
           options.add(new SelectOption(r.ID,r.Name +' - '+r.TR1__TimeType__r.Name)); 
          // maptimetype.put(r.ID,r.TR1__TimeType__r.TR1__EntryType__c);
         }
      } 
      return options; 
  }  
     

     public void init(){
        if(Apexpages.currentPage().getParameters().containsKey('tsId') && ApexPages.currentPage().getParameters().get('tsId') != ''){
            tsId = Apexpages.currentPage().getParameters().get('tsId');
            if(Apexpages.currentPage().getParameters().containsKey('rTsId') && ApexPages.currentPage().getParameters().get('rTsId') != ''){
               rTsId = Apexpages.currentPage().getParameters().get('rTsId');
             }  
         }   
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
        fieldSetTimesheetFooter = new List<Schema.FieldSetMember>();
        fieldSetTimesheetAdditionalInfo = new List<Schema.FieldSetMember>();
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
        lstFSM.addAll(fieldSetTimesheetFooter);
        lstFSM.addAll(fieldSetTimesheetAdditionalInfo);
        
        for(Schema.FieldSetMember objFSM: lstFSM){
            if(objFSM.getFieldPath() != 'Work_Location__c')
                strQueryTS += ', ' + objFSM.getFieldPath();
        }
          
         
        
        strQueryTS += ',TR1__Timesheet__c, Work_Location__c from TR1__Timesheet_Detail__c where Id = \'' + tsId + '\' AND (TR1__Timesheet__r.All_Approver__c like \'%'+ ((String)objContact.Id).left(15) +'%\' OR TR1__Timesheet__r.TR1__Consultant__c = \'' + strContactId + '\')';
        strQueryTSD += ',id, TR1__TimesheetDetail__c, TR1__StartDateTime__c,TR1__Rate__c from TR1__ShiftWork__c where TR1__TimesheetDetail__c = \'' + tsId + '\'';
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
    
      //To calculate time difference between start and end time
    private decimal calculateTimeDifference(Datetime starttime,Datetime endtime){
         long milliseconds = endtime.getTime() - starttime.getTime();
         Decimal seconds = milliseconds / 1000;
         Decimal minutes = seconds / 60;
         Decimal hours = minutes / 60;     
         return  hours.setScale(2) ;
    }
   
    
    /*
    Name - saveTimesheetDetails
    returnType - PageReference
    Description - Called by Candidate to save a timesheet
    */
    public pagereference errorOnStartEndTimeFormate(){
     isError = true;
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Time In and Time out formats are incorect.'));
     return null ;
    }
    public void StartEndTimeFormate(){
     isError = true;
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Time Out format is incorect.'));
    }
    public pagereference StartStartTimeFormate(){
     isError = true;
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Time In format is incorect.'));
     return null ;
    }
    public pagereference Save(){
       
    try{
        string ss = selectedRecordType;
        TR1__Rate__c r = new TR1__Rate__c();
        if(ss!=null){ 
        system.debug('sssss'+ss);
        r = RC_AccessController.getTimesheetRateById(ss);
        }
        TR1__ShiftWork__c shi = New TR1__ShiftWork__c() ;
        shi.TR1__Rate__c = (id)selectedRecordType;
        //shi.PurchaseOrder__c = (id)selectedRecordTypes;
        shi.TR1__TimesheetDetail__c = tsId;
        if(r.TR1__TimeType__r.TR1__EntryType__c =='Start & Finish' && sh.TR1__Start_Time__c != null && sh.TR1__End_Time__c != null){
            
            shi.TR1__Start_Time__c = string.valueof(sh.TR1__Start_Time__c) ;
            shi.TR1__End_Time__c = string.valueof(sh.TR1__End_Time__c) ;
            List<String> startTimevalues = shi.TR1__Start_Time__c.split(':');
            List<String> endTimevalues = shi.TR1__End_Time__c.split(':');
            Integer StartTimeHours = Integer.valueOf(startTimevalues[0]);
            Integer StartTimeMinutes = Integer.valueOf(startTimevalues[1].substring(0,startTimevalues[1].length()-2));
            if(startTimevalues[1].right(2) == 'PM' && StartTimeHours <= 11)
                StartTimeHours += 12;
            if(startTimevalues[1].right(2) == 'AM' && StartTimeHours == 12)
                StartTimeHours = 0;
            Date startdate = slist.TR1__Date__c ;
            Integer day = startdate.day();
            Integer month = startdate.month();
            Integer year = startdate.year();
            DateTime starttime = Datetime.newInstanceGMT(year, month, day, StartTimeHours, StartTimeMinutes, 0);
            Integer endTimeHours = Integer.valueOf(endTimevalues[0]);
            Integer endTimeMinutes = Integer.valueOf(endTimevalues[1].substring(0,endTimevalues[1].length()-2));
             if(endTimevalues[1].right(2) == 'PM' && endTimeHours <= 11)
                endTimeHours += 12;
             if(endTimevalues[1].right(2) == 'AM' && endTimeHours == 12)
                endTimeHours = 0;
            DateTime endtime = Datetime.newInstanceGMT(year, month, day, endTimeHours, endTimeMinutes, 0); 
            if(starttime >= endtime){
                 isError = true;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Finish time should be greater than start time '));
                 return null;
               }else if(starttime.dayGMT() != endtime.dayGMT()){
                  isError = true;
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Start and finish time should be today only on '));
                  return null;
              } 
             Datetime dt1 = DateTime.newInstanceGMT(year, month, day, StartTimeHours, StartTimeMinutes, 0);
             Datetime dt2 = DateTime.newInstanceGMT(year, month, day, endTimeHours, endTimeMinutes, 0);
             decimal hoursinscale = calculateTimeDifference(dt1,dt2);
             shi.TR1__Hours__c = hoursinscale;
        }
        else if(r.TR1__TimeType__r.TR1__EntryType__c =='Hours & Minutes'){
          shi.TR1__Hours__c = sh.TR1__Hours__c;  
        }
        RC_AccessController.insertRecord(shi);
        //upsert objTS;
        RC_AccessController.upsertRecord(objTS);
         
    } 
    catch(Exception e) 
     {
          //system.debug('getmessage===>'+e.getMessage()+ ''+e.getLineNumber());
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage() +''+e.getLineNumber()));
          return null;
     } 
     TR1__Timesheet_Detail__c ti = RC_AccessController.getTimesheetDetailById(objTS.id);
     return new PageReference('/TimesheetDetails?tsId='+ti.TR1__Timesheet__c).setRedirect(true);
  }
    
    
     public pagereference SaveNew(){
     try
     {
         string ss = selectedRecordType;
        TR1__Rate__c r = new TR1__Rate__c();
        if(ss!=null){ 
        system.debug('sssss'+ss);
         r = RC_AccessController.getTimesheetRateById(ss);
        }
     TR1__ShiftWork__c shi = New TR1__ShiftWork__c();
    shi.TR1__Rate__c = (id)selectedRecordType;
    //shi.PurchaseOrder__c = sh.PurchaseOrder__c;
    shi.TR1__Hours__c = sh.TR1__Hours__c;
    shi.TR1__TimesheetDetail__c = tsId;
    if(r.TR1__TimeType__r.TR1__EntryType__c =='Start & Finish' && sh.TR1__Start_Time__c != null && sh.TR1__End_Time__c != null ){
           shi.TR1__Start_Time__c = string.valueof(sh.TR1__Start_Time__c) ;
            shi.TR1__End_Time__c = string.valueof(sh.TR1__End_Time__c) ;
            List<String> startTimevalues = shi.TR1__Start_Time__c.split(':');
            List<String> endTimevalues = shi.TR1__End_Time__c.split(':');
            Integer StartTimeHours = Integer.valueOf(startTimevalues[0]);
            Integer StartTimeMinutes = Integer.valueOf(startTimevalues[1].substring(0,startTimevalues[1].length()-2));
            if(startTimevalues[1].right(2) == 'PM' && StartTimeHours <= 11)
                StartTimeHours += 12;
            if(startTimevalues[1].right(2) == 'AM' && StartTimeHours == 12)
                StartTimeHours = 0;
            Date startdate = slist.TR1__Date__c ;
            Integer day = startdate.day();
            Integer month = startdate.month();
            Integer year = startdate.year();
            DateTime starttime = Datetime.newInstanceGMT(year, month, day, StartTimeHours, StartTimeMinutes, 0);
            Integer endTimeHours = Integer.valueOf(endTimevalues[0]);
            Integer endTimeMinutes = Integer.valueOf(endTimevalues[1].substring(0,endTimevalues[1].length()-2));
             if(endTimevalues[1].right(2) == 'PM' && endTimeHours <= 11)
                endTimeHours += 12;
             if(endTimevalues[1].right(2) == 'AM' && endTimeHours == 12)
                endTimeHours = 0;
            DateTime endtime = Datetime.newInstanceGMT(year, month, day, endTimeHours, endTimeMinutes, 0); 
            if(starttime >= endtime){
                 isError = true;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Finish time should be greater than start time '));
                 return null;
               }else if(starttime.dayGMT() != endtime.dayGMT()){
                  isError = true;
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Start and finish time should be today only on '));
                  return null;
              } 
             Datetime dt1 = DateTime.newInstanceGMT(year, month, day, StartTimeHours, StartTimeMinutes, 0);
             Datetime dt2 = DateTime.newInstanceGMT(year, month, day, endTimeHours, endTimeMinutes, 0);
             decimal hoursinscale = calculateTimeDifference(dt1,dt2);
             shi.TR1__Hours__c = hoursinscale;
     }else if(r.TR1__TimeType__r.TR1__EntryType__c =='Hours & Minutes'){
       shi.TR1__Hours__c = sh.TR1__Hours__c;  
    } 
    RC_AccessController.insertRecord(shi);
   pagereference p = Apexpages.currentpage();
   p.setRedirect(true);
   return p;
   }
catch(Exception e) 
        {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getmessage()));//System.Label.Time_Sheet_Detail_Validation_Rule
            return null;
        } 
    }
    
    public pageReference cancelRedirect(){
         String urlId = ApexPages.currentPage().getParameters().get('retURL');
         system.debug('&&&&********'+label.BackUrlInCommunity_ShiftworkPage+urlId);
         return new Pagereference(label.BackUrlInCommunity_ShiftworkPage+urlId);
       
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
           system.debug('the exception is ===>'+e.getmessage());
           return null;
        }
    }
    
    //To fetch the contact detail
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
    




}
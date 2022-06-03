@IsTest
Public class RateCreationHandler_test {
 @TestSetup
    public static void testSetUpData(){
        TR1__TalentRoverProperties__c objCSTR = TR1__TalentRoverProperties__c.getOrgDefaults();  
        objCSTR.Use_Rate_Card_Module_Cust__c  = true;
        objCSTR.TR1__Use_Rate_Card_Module__c=false;
        insert objCSTR;
    }
    @IsTest
    Public static void CreateTimesheetHelper_Validate () {
        set<id> crids = new set<id>();
          
      account acc = new account();
      acc.name = 'test';
      insert acc ;
    
  
    
    contact con = new contact();
    con.LastName = 'test';
    con.Accountid = acc.id ;
    con.TR1__Candidate_Status__c = 'Prospect';
    con.TR1__Client_Status__c = 'Past';
    con.TR1__Regional_Area__c = 'Hawaii All';
    con.TR1__State_Area__c = 'Hawaii' ;
    con.Email = 'test@gmail.com';
    insert con ;

    list<TR1__Job__c> joblist = new list<TR1__Job__c>();
    TR1__Job__c job = new TR1__Job__c();
    job.TR1__Account__c = acc.id ;
    job.Name = 'test';
    job.TR1__Contact__c = con.id;
    job.TR1__Hiring_Manager__c = con.id;
    job.TR1__Maximum_Pay_Rate__c = 54;
    job.TR1__Maximum_Bill_Rate__c = 90;
    job.TR1__Primary_Matching_Requirement__c = 'test' ;
    job.TR1__State_Area__c = 'Oregon';
    job.TR1__Regional_Area__c = 'Oregon All';
    job.TR1__City__c = 'Chicago';
    job.TR1__Status__c   = 'Open';
    job.TR1__Open_Date__c =  system.today();
    job.TR1__Rates_From_Account__c = 'Yes';
    insert job ;
    joblist.add(job);
    
  
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'testkaja@asdf.com',
                           Username = 'testkaja@ved.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr ;                   
    
    TR1__Closing_Report__c crs = new TR1__Closing_Report__c();
    crs.TR1__Account__c = acc.id ;
    crs.TR1__Timesheet_Approver__c = con.id;
    crs.TR1__Timesheet_Type__c = 'Online';
    crs.TR1__Payroll_Type__c = 'W2 - Exempt';
    crs.TR1__Assignment_Ended__c = 'No';
    crs.TR1__Person_Placed__c = con.id ;
    crs.TR1__Generate_Timesheet__c = true ;
    crs.TR1__Rates_From_Job__c = 'yes';
    crs.TR1__Start_Date__c = system.today();
    crs.TR1__End_Date__c = system.today() + 3 ;
    crs.TR1__Pay_Rate__c = 34 ;
    crs.TR1__Bill_Rate__c = 56 ;
    crs.TR1__OT_Bill_Rate_Multiplier_Percentage__c = 45 ;
    crs.TR1__DT_Bill_Rate_Multiplier_Percentage__c = 23 ;
    crs.TR1__Job_Percentage__c = 100 ;
    crs.TR1__Payment_Terms__c = 'Net 15';
    crs.TR1__Job_Credit__c = usr.id ;
    crs.TR1__Billing_Street__c = 'test str';
    crs.TR1__Billing_City__c = 'city';
    crs.TR1__Billing_State__c = 'NY';
    crs.TR1__Billing_Zip_Code__c = '356789544';
    crs.TR1__Job__c = job.id ;
    insert crs ;
    
   
    
    TR1__TimeType__c tt1 = new TR1__TimeType__c();
    tt1.Name = 'Regular Daily';
    //tt1.EntryType__c = 'Hours & Minutes';
    insert tt1 ;
    String JOB_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Job Rate').getRecordTypeId();
   String CLOSINGREPORT_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
   
    TR1__Rate__c rt = new TR1__Rate__c();
    rt.name = 'test name';
        rt.TR1__TimeType__c=tt1.id;
        rt.RecordTypeId=JOB_RECORDTYPE_RATE;
        rt.TR1__Active__c=true;
    rt.TR1__Account__c = acc.id ;
    rt.TR1__ClosingReport__c = crs.id ;
    rt.TR1__Job__c = job.id ;
    rt.TR1__RateBill__c = 23 ;
    rt.TR1__RatePay__c = 12 ;
    rt.TR1__TimeType__c = tt1.id ;
    insert rt;
    list<TR1__Rate__c> rate = new list<TR1__Rate__c>();
    rate.add(rt);
    
    TR1__Timesheet__c ts = new TR1__Timesheet__c();
    ts.TR1__Status__c = 'Unsubmitted';
    ts.TR1__Closing_Report__c = crs.id;
    ts.TR1__Consultant__c = con.id;
    ts.TR1__Job_Order__c = job.id;
    ts.TR1__Approver__c = con.id;
    ts.TR1__Timesheet_Second_Approver__c = con.id;
    ts.TR1__Client__c = acc.id;
    insert ts ;
    
    list<TR1__Timesheet__c> tsts = new list<TR1__Timesheet__c>();
    tsts.add(ts) ;
    
    TR1__Timesheet_Detail__c tsDetail = new TR1__Timesheet_Detail__c();
    tsDetail.TR1__Timesheet__c = ts.id;
    tsDetail.TR1__Day__c = 'Monday';
    tsDetail.TR1__Date__c = date.today()+5;
    Insert tsDetail ;
    
    TR1__ShiftWork__c sw = new TR1__ShiftWork__c() ;
    sw.TR1__Rate__c = rt.id ;
    sw.TR1__Units__c = 5 ;
    sw.TR1__TimesheetDetail__c = tsDetail.id ;
    insert sw ;
    
    List <TR1__Closing_Report__c> recordNewList = new List <TR1__Closing_Report__c>(); 
    recordNewList.add(crs);
    for(TR1__Closing_Report__c cr : recordNewList){
      crids.add(cr.id);
    }
         
    RateCreationHandlerCtrl.getRateFromJob(recordNewList);
    RateCreationHandlerCtrl.getRateFromCR(tsts);
    RateCreationHandlerCtrl.getRateFromAccount(joblist);
         
   }

   @IsTest
   Public static void CreateTimesheetHelper_ValidateFalseCases () {
       set<id> crids = new set<id>();
     
    
       
     account acc = new account();
     acc.name = 'test';
     insert acc ;
   
   contact con = new contact();
   con.LastName = 'test';
   con.Accountid = acc.id ;
   con.TR1__Candidate_Status__c = 'Prospect';
   con.TR1__Client_Status__c = 'Past';
   con.TR1__Regional_Area__c = 'Hawaii All';
   con.TR1__State_Area__c = 'Hawaii' ;
   con.Email = 'test@gmail.com';
   insert con ;

   list<TR1__Job__c> joblist = new list<TR1__Job__c>();
   TR1__Job__c job = new TR1__Job__c();
   job.TR1__Account__c = acc.id ;
   job.Name = 'test';
   job.TR1__Contact__c = con.id;
   job.TR1__Hiring_Manager__c = con.id;
   job.TR1__Maximum_Pay_Rate__c = 54;
   job.TR1__Maximum_Bill_Rate__c = 90;
   job.TR1__Primary_Matching_Requirement__c = 'test' ;
   job.TR1__State_Area__c = 'Oregon';
   job.TR1__Regional_Area__c = 'Oregon All';
   job.TR1__City__c = 'Chicago';
   job.TR1__Status__c   = 'Open';
   job.TR1__Open_Date__c =  system.today();
   job.TR1__Rates_From_Account__c = 'Yes';
   insert job ;
   joblist.add(job);
   
  String JOB_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Job Rate').getRecordTypeId();
   String CLOSINGREPORT_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
     String TIMETYPE_RECORDTYPE_RATE = Schema.SObjectType.TR1__TimeType__c.getRecordTypeInfosByName().get('Timesheet Time Type').getRecordTypeId();
  String TIMESHEET_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Timesheet Rate').getRecordTypeId();
 
   Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
       
       User usr = new User(LastName = 'LIVESTON',
                          FirstName='JASON',
                          Alias = 'jliv',
                          Email = 'testkaja@asdf.com',
                          Username = 'testkaja@ved.com',
                          ProfileId = profileId.id,
                          TimeZoneSidKey = 'GMT',
                          LanguageLocaleKey = 'en_US',
                          EmailEncodingKey = 'UTF-8',
                          LocaleSidKey = 'en_US'
                          );
       insert usr ;                   
   
   TR1__Closing_Report__c crs = new TR1__Closing_Report__c();
   crs.TR1__Account__c = acc.id ;
   crs.TR1__Timesheet_Approver__c = con.id;
   crs.TR1__Timesheet_Type__c = 'Online';
   crs.TR1__Payroll_Type__c = 'W2 - Exempt';
   crs.TR1__Assignment_Ended__c = 'No';
   crs.TR1__Person_Placed__c = con.id ;
   crs.TR1__Generate_Timesheet__c = true ;
   crs.TR1__Rates_From_Job__c = 'yes';
   crs.TR1__Start_Date__c = system.today();
   crs.TR1__End_Date__c = system.today() + 3 ;
   crs.TR1__Pay_Rate__c = 34 ;
   crs.TR1__Bill_Rate__c = 56 ;
   crs.TR1__OT_Bill_Rate_Multiplier_Percentage__c = 45 ;
   crs.TR1__DT_Bill_Rate_Multiplier_Percentage__c = 23 ;
   crs.TR1__Job_Percentage__c = 100 ;
   crs.TR1__Payment_Terms__c = 'Net 15';
   crs.TR1__Job_Credit__c = usr.id ;
   crs.TR1__Billing_Street__c = 'test str';
   crs.TR1__Billing_City__c = 'city';
   crs.TR1__Billing_State__c = 'NY';
   crs.TR1__Billing_Zip_Code__c = '356789544';
   crs.TR1__Job__c = job.id ;
   insert crs ;
   
  
   
   TR1__TimeType__c tt1 = new TR1__TimeType__c();
   tt1.Name = 'Regular Daily';
          tt1.TR1__Show_in_Community__c=true;
       tt1.RecordTypeId=TIMETYPE_RECORDTYPE_RATE;
   tt1.TR1__EntryType__c = 'Hours & Minutes';
   insert tt1 ;
   
   TR1__Rate__c rt = new TR1__Rate__c();
   rt.name = 'test name';
      // rt.TR1__TimeType__c=tt1.id;
       rt.RecordTypeId=CLOSINGREPORT_RECORDTYPE_RATE;
       rt.TR1__Active__c=true;
   rt.TR1__Account__c = acc.id ;
   rt.TR1__ClosingReport__c = crs.id ;
   rt.TR1__Job__c = job.id ;
   rt.TR1__RateBill__c = 23 ;
   rt.TR1__RatePay__c = 12 ;
   rt.TR1__TimeType__c = tt1.id ;
   insert rt;
       System.debug('::::'+CLOSINGREPORT_RECORDTYPE_RATE);
      
   list<TR1__Rate__c> rate = new list<TR1__Rate__c>();
   rate.add(rt);
   
   TR1__Timesheet__c ts = new TR1__Timesheet__c();
   ts.TR1__Status__c = 'Unsubmitted';
   ts.TR1__Closing_Report__c = crs.id;
   ts.TR1__Consultant__c = con.id;
   ts.TR1__Job_Order__c = job.id;
   ts.TR1__Approver__c = con.id;
   ts.TR1__Timesheet_Second_Approver__c = con.id;
   ts.TR1__Client__c = acc.id;
   insert ts ;
   
   list<TR1__Timesheet__c> tsts = new list<TR1__Timesheet__c>();
   tsts.add(ts) ;
   
   TR1__Timesheet_Detail__c tsDetail = new TR1__Timesheet_Detail__c();
   tsDetail.TR1__Timesheet__c = ts.id;
   tsDetail.TR1__Day__c = 'Monday';
   tsDetail.TR1__Date__c = date.today()+5;
   Insert tsDetail ;
   
   TR1__ShiftWork__c sw = new TR1__ShiftWork__c() ;
   sw.TR1__Rate__c = rt.id ;
   sw.TR1__EndDateTime__c = date.today()+2 ;
   sw.TR1__StartDateTime__c = date.today() ;
   sw.TR1__TimesheetDetail__c = tsDetail.id ;
   insert sw ;
   
   List <TR1__Closing_Report__c> recordNewList = new List <TR1__Closing_Report__c>(); 
   recordNewList.add(crs);
   for(TR1__Closing_Report__c cr : recordNewList){
     crids.add(cr.id);
   }
        
   RateCreationHandlerCtrl.getRateFromJob(recordNewList);
   RateCreationHandlerCtrl.getRateFromCR(tsts);
  RateCreationHandlerCtrl.getRateFromAccount(joblist);
        
  }
  
  @IsTest
    Public static void CreateTimesheetHelperElseCase_Validate () {
        set<id> crids = new set<id>();
          
      account acc = new account();
      acc.name = 'test';
      insert acc ;
    
    
    
    contact con = new contact();
    con.LastName = 'test';
    con.Accountid = acc.id ;
    con.TR1__Candidate_Status__c = 'Prospect';
    con.TR1__Client_Status__c = 'Past';
    con.TR1__Regional_Area__c = 'Hawaii All';
    con.TR1__State_Area__c = 'Hawaii' ;
    con.Email = 'test@gmail.com';
    insert con ;

    list<TR1__Job__c> joblist = new list<TR1__Job__c>();
    TR1__Job__c job = new TR1__Job__c();
    job.TR1__Account__c = acc.id ;
    job.Name = 'test';
    job.TR1__Contact__c = con.id;
    job.TR1__Hiring_Manager__c = con.id;
    job.TR1__Maximum_Pay_Rate__c = 54;
    job.TR1__Maximum_Bill_Rate__c = 90;
    job.TR1__Primary_Matching_Requirement__c = 'test' ;
    job.TR1__State_Area__c = 'Oregon';
    job.TR1__Regional_Area__c = 'Oregon All';
    job.TR1__City__c = 'Chicago';
    job.TR1__Status__c   = 'Open';
    job.TR1__Open_Date__c =  system.today();
    job.TR1__Rates_From_Account__c = 'Yes';
    insert job ;
    joblist.add(job);
    
  
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'testkaja@asdf.com',
                           Username = 'testkaja@ved.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr ;                   
    
    TR1__Closing_Report__c crs = new TR1__Closing_Report__c();
    crs.TR1__Account__c = acc.id ;
    crs.TR1__Timesheet_Approver__c = con.id;
    crs.TR1__Timesheet_Type__c = 'Online';
    crs.TR1__Payroll_Type__c = 'W2 - Exempt';
    crs.TR1__Assignment_Ended__c = 'No';
    crs.TR1__Person_Placed__c = con.id ;
    crs.TR1__Generate_Timesheet__c = true ;
    crs.TR1__Rates_From_Job__c = 'yes';
    crs.TR1__Start_Date__c = system.today();
    crs.TR1__End_Date__c = system.today() + 3 ;
    crs.TR1__Pay_Rate__c = 34 ;
    crs.TR1__Bill_Rate__c = 56 ;
    crs.TR1__OT_Bill_Rate_Multiplier_Percentage__c = 45 ;
    crs.TR1__DT_Bill_Rate_Multiplier_Percentage__c = 23 ;
    crs.TR1__Job_Percentage__c = 100 ;
    crs.TR1__Payment_Terms__c = 'Net 15';
    crs.TR1__Job_Credit__c = usr.id ;
    crs.TR1__Billing_Street__c = 'test str';
    crs.TR1__Billing_City__c = 'city';
    crs.TR1__Billing_State__c = 'NY';
    crs.TR1__Billing_Zip_Code__c = '356789544';
    crs.TR1__Job__c = job.id ;
    insert crs ;
    
   
    
    TR1__TimeType__c tt1 = new TR1__TimeType__c();
    tt1.Name = 'Regular Daily';
    //tt1.EntryType__c = 'Hours & Minutes';
    insert tt1 ;
    
    TR1__Rate__c rt = new TR1__Rate__c();
    rt.name = 'test name';
   
    rt.TR1__Account__c = acc.id ;
    rt.TR1__ClosingReport__c = crs.id ;
    rt.TR1__Job__c = job.id ;
    rt.TR1__RateBill__c = 23 ;
    rt.TR1__RatePay__c = 12 ;
    rt.TR1__TimeType__c = tt1.id;
    rt.TR1__Active__c = true;
    rt.TR1__Date_Valid_From__c = system.today().addDays(-2);
    rt.TR1__Date_Valid_To__c = system.today().addDays(-1);
    insert rt;
    list<TR1__Rate__c> rate = new list<TR1__Rate__c>();
    rate.add(rt);
        
    TR1.Batch_RatesStatusUpdate rateBatch = new TR1.Batch_RatesStatusUpdate();   
    Database.executeBatch(rateBatch);
        
    TR1__Timesheet__c ts = new TR1__Timesheet__c();
    ts.TR1__Status__c = 'Unsubmitted';
    ts.TR1__Closing_Report__c = crs.id;
    ts.TR1__Consultant__c = con.id;
    ts.TR1__Job_Order__c = job.id;
    ts.TR1__Approver__c = con.id;
    ts.TR1__Timesheet_Second_Approver__c = con.id;
    ts.TR1__Client__c = acc.id;
    insert ts ;
    
    list<TR1__Timesheet__c> tsts = new list<TR1__Timesheet__c>();
    tsts.add(ts) ;
    
    TR1__Timesheet_Detail__c tsDetail = new TR1__Timesheet_Detail__c();
    tsDetail.TR1__Timesheet__c = ts.id;
    tsDetail.TR1__Day__c = 'Monday';
    tsDetail.TR1__Date__c = date.today()+5;
    Insert tsDetail ;
    
    TR1__ShiftWork__c sw = new TR1__ShiftWork__c() ;
    sw.TR1__Rate__c = rt.id ;
    sw.TR1__TimesheetDetail__c = tsDetail.id ;
    //sw.EndDateTime__c = date.today()+2 ;
    //sw.StartDateTime__c = date.today() ;
    insert sw ;
    
    List <TR1__Closing_Report__c> recordNewList = new List <TR1__Closing_Report__c>(); 
    recordNewList.add(crs);
    for(TR1__Closing_Report__c cr : recordNewList){
      crids.add(cr.id);
    }
    
    RateCreationHandlerCtrl.getRateFromJob(recordNewList);
    RateCreationHandlerCtrl.getRateFromCR(tsts);
    RateCreationHandlerCtrl.getRateFromAccount(joblist);
         
   }
  
}
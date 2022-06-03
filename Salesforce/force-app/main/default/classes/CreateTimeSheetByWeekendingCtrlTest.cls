@isTest(seealldata = False)
private class CreateTimeSheetByWeekendingCtrlTest{
  public static testMethod void Createtimesheet_Button() {
      createUserRecords();
      Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1=[Select Id,Name From User where ProfileId =:objProfile.Id AND isActive = true limit 1 ];
      system.runAs(u1){
                Account accApp = new Account(Name='Calif Account Test');
                insert accApp;
                Contact conApp = new Contact(LastName='Approv Calif Contact Test',Email='abac@abconsulting.com',AccountId=accApp.Id);
                insert conApp;
                
                Account acc = new Account(Name='CVP');
                insert acc;
                    
                Contact con = new Contact(LastName='CVP Contact',Email='test@test.com');
                insert con;
                
    
                Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                
                TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 2', TR1__Contact__c = con.Id);//, TRBO_Rate_Card__c = contract_rate.id);
                TR1__Job__c[] joblist = new TR1__Job__c[] {job1};
                insert joblist;
                Test.startTest();           
                Contact candidate1 = new Contact(LastName = 'Candidate 1');
                Contact[] candidatelist = new Contact[]{candidate1};  
                insert candidatelist;
               // Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
          // List<TR1__Closing_Report__c>  crlist = new List<TR1__Closing_Report__c>();  
          TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(
                                                    TR1__Account__c= accApp.Id,
                                                    //RecordTypeId = crconsultingId,
                                                    TR1__Job__c=job1.Id,
                                                    TR1__Person_Placed__c=candidate1.Id,
                                                    //Division_lookup__c = testDivision1.Id,
                                                    TR1__Salary__c=125000.00,
                                                    TR1__Job_Percentage__c = 25,
                                                    TR1__Week_Ending__c = 'Monday',
                                                    TR1__Candidate_Percentage__c = 25,
                                                    TR1__Marketing_Percentage__c = 25,
                                                    TR1__Other_Percentage__c = 15,
                                                    TR1__Other2_Percentage__c = 10,
                                                    TR1__Job_Credit__c = u1.Id,
                                                    TR1__Candidate_Credit__c = u1.Id,
                                                    TR1__Marketing_Credit__c = u1.Id,
                                                    TR1__Other_Credit__c = u1.Id,
                                                    TR1__Other2_Credit__c = u1.Id,
                                                    TR1__Start_Date__c = Date.today().addDays(-15),
                                                    TR1__End_Date__c = Date.today().addDays(30),
                                                    TR1__Generate_Timesheet__c = true ,
                                                    TR1__Timesheet_Approver__c = con.Id,
              										TR1__Assignment_Ended__c = 'No'
                                                    //Do_Not_Auto_Create_Past_Timesheet__c = true
                                                 );
             
                insert cr1;
         
          TR1__Closing_Report__c[] crlist = new TR1__Closing_Report__c[]{cr1};
          
                TRSCHED__Closing_Report_Schedule__c closingSchedule = new TRSCHED__Closing_Report_Schedule__c(
                														TRSCHED__Closing_Report__c  = cr1.id, 
                														TRSCHED__Schedule_Date__c = Date.today(),
                    													TRSCHED__Work_Shift_Location_lkId__c =accApp.id,
                    													Timesheet_Approver__c= conApp.id
                														);
                insert closingSchedule;
                Test.stopTest();
                Test.setCurrentPage(Page.CreateTimesheetByWeekending);
                System.currentPageReference().getParameters().put('crid', cr1.id);
          
            //List<TR1__Timesheet__c> listOfTimeSheet = [Select Id From TR1__Timesheet__c Where TR1__Closing_Report__c =: cr1.Id];
          		 TR1__Timesheet__c otr = new TR1__Timesheet__c();
                otr.TR1__Week_Ending__c=system.today();
          
         
                
                CreateTimesheetByWeekendingCtrl objts = new CreateTimesheetByWeekendingCtrl(new ApexPages.StandardController(otr));
                objts.createts();
          		closingSchedule.TRSCHED__Schedule_Date__c = Date.today().addDays(1);
                update closingSchedule;
          		objts.createts();
                objts.goBack();         
             }
           }

   @future
    public static void createUserRecords(){
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        User objUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='standarduser2016@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = objProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2016'+String.valueOf(Math.random())+'@testorg.com');

        insert objUser;
        //return objUser;
    }
    
    //test method2
    public static testMethod void Createtimesheet2() {
      createUserRecords();
      Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1=[Select Id,Name From User where ProfileId =:objProfile.Id AND isActive = true limit 1 ];
      system.runAs(u1){
                Account accApp = new Account(Name='Calif Account Test');
                insert accApp;
                Contact conApp = new Contact(LastName='Approv Calif Contact Test',Email='abac@abconsulting.com',AccountId=accApp.Id);
                insert conApp;
                
                Account acc = new Account(Name='CVP');
                insert acc;
                    
                Contact con = new Contact(LastName='CVP Contact',Email='test@test.com');
                insert con;
                
    
                Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                
                TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 2', TR1__Contact__c = con.Id);//, TRBO_Rate_Card__c = contract_rate.id);
                TR1__Job__c[] joblist = new TR1__Job__c[] {job1};
                insert joblist;
                Test.startTest();           
                Contact candidate1 = new Contact(LastName = 'Candidate 1');
                Contact[] candidatelist = new Contact[]{candidate1};  
                insert candidatelist;
               // Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(
                                                    TR1__Account__c= accApp.Id,
                                                    //RecordTypeId = crconsultingId,
                                                    TR1__Job__c=job1.Id,
                                                    TR1__Person_Placed__c=candidate1.Id,
                   									
                                                    //Division_lookup__c = testDivision1.Id,
                                                    TR1__Salary__c=125000.00,
                                                    TR1__Job_Percentage__c = 25,
                                                    TR1__Week_Ending__c = '',
                                                    TR1__Candidate_Percentage__c = 25,
                                                    TR1__Marketing_Percentage__c = 25,
                                                    TR1__Other_Percentage__c = 15,
                                                    TR1__Other2_Percentage__c = 10,
                                                    TR1__Job_Credit__c = u1.Id,
                                                    TR1__Candidate_Credit__c = u1.Id,
                                                    TR1__Marketing_Credit__c = u1.Id,
                                                    TR1__Other_Credit__c = u1.Id,
                                                    TR1__Other2_Credit__c = u1.Id,
                                                    TR1__Start_Date__c = Date.today().addDays(-15),
                                                    TR1__End_Date__c = Date.today().addDays(30),
                                                    TR1__Generate_Timesheet__c = true ,
                                                    TR1__Timesheet_Approver__c = con.Id,
                    								TR1__Assignment_Ended__c = 'No'
                                                    //Do_Not_Auto_Create_Past_Timesheet__c = true
                                                 );
          
                 
                insert cr1;
          
              TR1__Closing_Report__c[] crlist = new TR1__Closing_Report__c[]{cr1};
                TRSCHED__Closing_Report_Schedule__c  closingSchedule = new TRSCHED__Closing_Report_Schedule__c(
                														TRSCHED__Closing_Report__c  = cr1.id, 
                														TRSCHED__Schedule_Date__c = Date.today(),
                    													TRSCHED__Work_Shift_Location_lkId__c =accApp.id,
                    													Timesheet_Approver__c= conApp.id
                														);
                insert closingSchedule;
                Test.stopTest();
                Test.setCurrentPage(Page.CreateTimesheetByWeekending);
                System.currentPageReference().getParameters().put('crid', cr1.id);
                TR1__Timesheet__c otr = new TR1__Timesheet__c();
                otr.TR1__Week_Ending__c=system.today();
                
                CreateTimesheetByWeekendingCtrl objts = new CreateTimesheetByWeekendingCtrl(new ApexPages.StandardController(otr));
                objts.createts();          
             }
           }
/*
   	public static testMethod void Createtimesheet3() {
      createUserRecords();
      Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1=[Select Id,Name From User where ProfileId =:objProfile.Id AND isActive = true limit 1 ];
      system.runAs(u1){
                Account accApp = new Account(Name='Calif Account Test');
                insert accApp;
                Contact conApp = new Contact(LastName='Approv Calif Contact Test',Email='abac@abconsulting.com',AccountId=accApp.Id);
                insert conApp;
                
                Account acc = new Account(Name='CVP');
                insert acc;
                    
                Contact con = new Contact(LastName='CVP Contact',Email='test@test.com');
                insert con;
                
    
                Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                
                TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 2', TR1__Contact__c = con.Id);//, TRBO_Rate_Card__c = contract_rate.id);
                TR1__Job__c[] joblist = new TR1__Job__c[] {job1};
                insert joblist;
                //Test.startTest();           
                Contact candidate1 = new Contact(LastName = 'Candidate 1');
                Contact[] candidatelist = new Contact[]{candidate1};  
                insert candidatelist;
                //Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(
                                                    TR1__Account__c= accApp.Id,
                                                    //RecordTypeId = crconsultingId,
                                                    TR1__Job__c=job1.Id,
                                                    TR1__Person_Placed__c=candidate1.Id,
                   									 
                                                    //Division_lookup__c = testDivision1.Id,
                                                    TR1__Salary__c=125000.00,
                                                    TR1__Job_Percentage__c = 25,
                                                    TR1__Week_Ending__c = '',
                                                    TR1__Candidate_Percentage__c = 25,
                                                    TR1__Marketing_Percentage__c = 25,
                                                    TR1__Other_Percentage__c = 15,
                                                    TR1__Other2_Percentage__c = 10,
                                                    TR1__Job_Credit__c = u1.Id,
                                                    TR1__Candidate_Credit__c = u1.Id,
                                                    TR1__Marketing_Credit__c = u1.Id,
                                                    TR1__Other_Credit__c = u1.Id,
                                                    TR1__Other2_Credit__c = u1.Id,
                                                    TR1__Start_Date__c = Date.today().addDays(-15),
                                                    TR1__End_Date__c = Date.today().addDays(30),
                                                    TR1__Generate_Timesheet__c = true ,
                                                    TR1__Timesheet_Approver__c = con.Id,
                   									 TR1__Assignment_Ended__c = 'No'
                                                    //Do_Not_Auto_Create_Past_Timesheet__c = true
                                                 );
               
                insert cr1;
         
          TR1__Closing_Report__c[] crlist = new TR1__Closing_Report__c[]{cr1};
                Test.stopTest();
                Test.setCurrentPage(Page.CreateTimesheetByWeekending);
                System.currentPageReference().getParameters().put('crid', cr1.id);
                TR1__Timesheet__c otr = new TR1__Timesheet__c();
                otr.TR1__Week_Ending__c=system.today();
                
                CreateTimesheetByWeekendingCtrl objts = new CreateTimesheetByWeekendingCtrl(new ApexPages.StandardController(otr));
                objts.createts();          
             }
           }
 */
 }
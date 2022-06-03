@isTest(seealldata = False)
private class ClosingReportSchedulesBatchTest {
	
	@isTest  
    private static void testClosingReportNextWorkingDateUpdate() {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User objUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='standarduser20XX@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = objProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser20XX'+String.valueOf(Math.random())+'@testorg.com');
        
        insert objUser;   
        system.runAs(objUser){
            Account accApp = new Account(Name='Calif Account Test');
            insert accApp;
            
            Account acc = new Account(Name='CVP');
            insert acc;
            
            Contact con = new Contact(LastName='CVP Contact',Email='test@test.com');
            insert con;
            
            
            Id consultingid = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
            TR1__Job__c job1 = new TR1__Job__c(RecordTypeId = consultingid, TR1__Account__c = acc.Id, Name = 'Job 2', TR1__Contact__c = con.Id);//, TRBO_Rate_Card__c = contract_rate.id);
            TR1__Job__c[] joblist = new TR1__Job__c[] {job1};
                insert joblist;
            
            Contact candidate1 = new Contact(LastName = 'Candidate 1',Email='test@test.com');
            Contact[] candidatelist = new Contact[]{candidate1};  
                insert candidatelist;
            Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            TR1__Closing_Report__c cr1 = new TR1__Closing_Report__c(
                TR1__Account__c= accApp.Id,
                RecordTypeId = crconsultingId,
                TR1__Job__c=job1.Id,
                TR1__Person_Placed__c=candidate1.Id,
                TR1__Salary__c=125000.00,
                TR1__Job_Percentage__c = 100,
                TR1__Job_Credit__c = objUser.Id,
                TR1__Start_Date__c = Date.today(),
                TR1__End_Date__c = Date.today().addDays(30)
            );
            insert cr1;
            
            TRSCHED__Vacancy_D2D__c vs = new TRSCHED__Vacancy_D2D__c();
	        vs.TRSCHED__Vacancy__c = job1.id;
	        vs.TRSCHED__Work_Shift_Location_lkId__c = job1.TR1__Account__c;
	        vs.TRSCHED__Vacancy_Date__c = Date.Today(); 
	        vs.TRSCHED__Start_Date_Time__c = DateTime.now().addDays(2);
	        vs.TRSCHED__End_Date_Time__c = DateTime.now().addDays(2);
	        insert vs;
	        
	        TRSCHED__Closing_Report_Schedule__c crs = new TRSCHED__Closing_Report_Schedule__c();
	        crs.TRSCHED__Closing_Report__c = cr1.id;
	        crs.TRSCHED__Work_Shift_Location_lkId__c = job1.TR1__Account__c;
	        crs.TRSCHED__Vacancy_Schedule__c = vs.id;
	        crs.TRSCHED__Job_s_account__c = job1.TR1__Account__c;
	        crs.TRSCHED__Schedule_Date__c = Date.Today().addDays(2);
	        insert crs;
	        
            Test.startTest();
                String CRON_EXP = '0 0 0 3 9 ? 2022';
                System.schedule('testClosingReportScheduler'+CRON_EXP, CRON_EXP, new ClosingReportSchedulesBatch());
            Test.stopTest();
        }
    }
}
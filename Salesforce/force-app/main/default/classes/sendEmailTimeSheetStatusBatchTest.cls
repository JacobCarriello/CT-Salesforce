@isTest(seealldata = False)
private class sendEmailTimeSheetStatusBatchTest {
    @isTest  
    private static void timesheetUnsubmitSendEmailBatch() {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User objUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='standarduser2016@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = objProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2016'+String.valueOf(Math.random())+'@testorg.com');
        
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
                TR1__Job_Percentage__c = 25,
                TR1__Candidate_Percentage__c = 25,
                TR1__Marketing_Percentage__c = 25,
                TR1__Other_Percentage__c = 15,
                TR1__Other2_Percentage__c = 10,
                TR1__Job_Credit__c = objUser.Id,
                TR1__Candidate_Credit__c = objUser.Id,
                TR1__Marketing_Credit__c = objUser.Id,
                TR1__Other_Credit__c = objUser.Id,
                TR1__Other2_Credit__c = objUser.Id,
                TR1__Start_Date__c = Date.today().addDays(-15),
                TR1__End_Date__c = Date.today().addDays(30),
                TR1__Generate_Timesheet__c = true ,
                TR1__Timesheet_Approver__c = con.Id
            );
            insert cr1;
            TR1__Timesheet__c timeseetObj = new TR1__Timesheet__c(TR1__Job_Order__c=joblist[0].Id,TR1__Status__c='Unsubmitted',TR1__Closing_Report__c=cr1.Id);
            insert timeseetObj;
            Test.startTest();
                String CRON_EXP = '0 0 0 3 9 ? 2022';
                System.schedule('testTimeSheetssubmit'+CRON_EXP, CRON_EXP, new ScheduleSendEmailTimeSheetStatusBatch());
            Test.stopTest();
        }
    }
}
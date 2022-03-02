@istest
class Batch_CandidateStatusUpdate_Test{
    
    static testmethod void testschedule() {
        
        RecordType rt = [Select Id From RecordType Where Name = 'Candidate'];
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.RecordTypeId = rt.Id; 
        insert con;
        
        TR1__Closing_Report__c cr = new TR1__Closing_Report__c();
        cr.TR1__Job_Percentage__c = 20;
        cr.TR1__Candidate_Percentage__c  = 20;
        cr.TR1__Marketing_Percentage__c  = 20;
        cr.TR1__Other_Percentage__c  = 20;
        cr.TR1__Other2_Percentage__c = 20;
        cr.TR1__Job__c = RC_UtilityClass.insertJob().Id; 
        cr.TR1__Person_Placed__c = con.Id;
        insert cr;
        
        TRSCHED__Candidate_Availability__c ca = new TRSCHED__Candidate_Availability__c();
        ca.TRSCHED__Candidate__c = con.Id;
        ca.TRSCHED__Start_Date__c = System.today();
        ca.TRSCHED__End_Date__c = System.today();
        insert ca;
        
        TRSCHED__Closing_Report_Schedule__c crs = new TRSCHED__Closing_Report_Schedule__c();
        crs.TRSCHED__Closing_Report__c = cr.Id;
        crs.TRSCHED__Candidate_Availability__c = ca.Id;
        crs.TRSCHED__Schedule_Date__c = System.today().addDays(-1);
        insert crs;
        
        Test.StartTest();
        ScheduledBatch_CandidateStatusUpdate sh1 = new ScheduledBatch_CandidateStatusUpdate ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test Schedule', sch, sh1);
        Test.stopTest();
        
    }
}
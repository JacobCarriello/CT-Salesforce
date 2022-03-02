@isTest
private class ClosingReportTriggerHandlerTest {
    static testMethod void testFieldAssignment() {
        
        
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Con');
        insert con;
        
        TR1__Job__c Job = new TR1__Job__c();
        Job.TR1__Account__c = acc.id;
        Job.TR1__Sourcing_Recruiter__c = UserInfo.getUserId();
        insert Job;
        
        TR1__Send_Out__c sendout = new TR1__Send_Out__c();
        sendout.TR1__Job__c = Job.id;
        insert sendout;
        
        TR1__Send_Out_Schedule__c sch = new TR1__Send_Out_Schedule__c();
        sch.TR1__Interviewee__c = con.id;
        sch.TR1__Send_Out__c = sendout.id;
        sch.Split_Recruiter__c = UserInfo.getUserId();
        sch.TR1__Date__c = Date.today();
        sch.TR1__Account__c = Job.TR1__Account__c;
        sch.TR1__Account_Contact__c = con.Id;
        sch.TR1__Location__c = 'Location';
        sch.TR1__Time__c = '10:30';
        sch.TR1__Job__c = Job.id;
        insert sch;
        
        List<TR1__Closing_Report__c> closingReportToInsert = new List<TR1__Closing_Report__c>();
        
        TR1__Closing_Report__c cr = new TR1__Closing_Report__c();
        cr.TR1__Account__c = acc.Id;
        cr.TR1__Start_DAte__c = System.Today();
         cr.TR1__END_DAte__c = System.Today() + 14;
         cr.TR1__Job_Percentage__c =25;
         cr.TR1__Candidate_Percentage__c  =25;
         cr.TR1__Marketing_Percentage__c  = 10;
         cr.TR1__Other_Percentage__c  =20;
         cr.TR1__Other2_Percentage__c =20;
         cr.TR1__Generate_Timesheet__c = true;
         cr.TR1__Job__c = Job.Id;
         cr.TR1__Rate_Change_Effective_Date__c = System.Today();
         cr.TR1__Conversion_Date__c = System.Today() +14 ;
         cr.TR1__Salary__c = 100;
         cr.TR1__Person_Placed__c = con.id;
         cr.TR1__Job_Credit__c = UserInfo.getUserId();
         cr.TR1__Marketing_Credit__c = UserInfo.getUserId();
         cr.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__Closing_Report__c', 'TES');
         
         closingReportToInsert.add(cr);
         
         TR1__Closing_Report__c cr2 = new TR1__Closing_Report__c();
         cr2.TR1__Account__c = acc.Id;
         cr2.TR1__Start_DAte__c = System.Today();
         cr2.TR1__END_DAte__c = System.Today() + 14;
         cr2.TR1__Job_Percentage__c =25;
         cr2.TR1__Candidate_Percentage__c  =25;
         cr2.TR1__Marketing_Percentage__c  = 10;
         cr2.TR1__Other_Percentage__c  =20;
         cr2.TR1__Other2_Percentage__c =20;
         cr2.TR1__Generate_Timesheet__c = true;
         cr2.TR1__Job__c = Job.Id;
         cr2.TR1__Rate_Change_Effective_Date__c = System.Today();
         cr2.TR1__Conversion_Date__c = System.Today() +14 ;
         cr2.TR1__Salary__c = 100;
         cr2.TR1__Person_Placed__c = con.id;
         cr2.TR1__Job_Credit__c = UserInfo.getUserId();
         cr2.ECB_Amount__c = 100;
         cr.TR1__Marketing_Credit__c = UserInfo.getUserId();
         cr2.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__Closing_Report__c', 'TES');
         closingReportToInsert.add(cr2);
         
         insert closingReportToInsert;
         
         //assert
         system.assertEquals(UserInfo.getUserId(), [Select TR1__Candidate_Credit__c from TR1__Closing_Report__c where id =: cr.id limit 1].TR1__Candidate_Credit__c);
    }
    
    static testMethod void testSplitRecordsInsertion() {
        
        
        Account acc = new Account(Name = 'Test');
        acc.BillingStreet = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Test';
        acc.BillingPostalCode = '45981';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Con');
        insert con;
        
        TR1__Job__c Job = new TR1__Job__c();
        Job.TR1__Account__c = acc.id;
        Job.TR1__Sourcing_Recruiter__c = UserInfo.getUserId();
        insert Job;
        
        TR1__Send_Out__c sendout = new TR1__Send_Out__c();
        sendout.TR1__Job__c = Job.id;
         
        insert sendout;
        
        
        List<TR1__Closing_Report__c> closingReportToInsert = new List<TR1__Closing_Report__c>();
        
        TR1__Closing_Report__c cr = new TR1__Closing_Report__c();
        cr.TR1__Account__c = acc.Id;
        cr.TR1__Start_DAte__c = System.Today();
         cr.TR1__END_DAte__c = System.Today() + 14;
         cr.TR1__Job_Percentage__c =25;
         cr.TR1__Candidate_Percentage__c  =25;
         cr.TR1__Marketing_Percentage__c  = 10;
         cr.TR1__Other_Percentage__c  =20;
         cr.TR1__Other2_Percentage__c =20;
         cr.TR1__Generate_Timesheet__c = true;
         cr.TR1__Job__c = Job.Id;
         cr.TR1__Rate_Change_Effective_Date__c = System.Today();
         cr.TR1__Conversion_Date__c = System.Today() +14 ;
         cr.TR1__Salary__c = 100;
         cr.TR1__Person_Placed__c = con.id;
         cr.TR1__Job_Credit__c = UserInfo.getUserId();
         cr.TR1__Marketing_Credit__c = UserInfo.getUserId();
         cr.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__Closing_Report__c', 'TES');

         closingReportToInsert.add(cr);
         
         TR1__Closing_Report__c cr2 = new TR1__Closing_Report__c();
         cr2.TR1__Account__c = acc.Id;
         cr2.TR1__Start_DAte__c = System.Today();
         cr2.TR1__END_DAte__c = System.Today() + 14;
         cr2.TR1__Job_Percentage__c =25;
         cr2.TR1__Candidate_Percentage__c  =25;
         cr2.TR1__Marketing_Percentage__c  = 10;
         cr2.TR1__Other_Percentage__c  =20;
         cr2.TR1__Other2_Percentage__c =20;
         cr2.TR1__Generate_Timesheet__c = true;
         cr2.TR1__Job__c = Job.Id;
         cr2.TR1__Rate_Change_Effective_Date__c = System.Today();
         cr2.TR1__Conversion_Date__c = System.Today() +14 ;
         cr2.TR1__Salary__c = 100;
         cr2.TR1__Person_Placed__c = con.id;
         cr2.TR1__Job_Credit__c = UserInfo.getUserId();
         cr2.ECB_Amount__c = 100;
         cr2.TR1__Marketing_Credit__c = UserInfo.getUserId();
         cr2.TR1__Candidate_Credit__c = UserInfo.getUserId();
         cr2.RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('TR1__Closing_Report__c', 'TES');

        closingReportToInsert.add(cr2);
         
        insert closingReportToInsert;
        
        TR1__Closing_Report__c closingReport = [Select TR1__Job_Reporting__c from TR1__Closing_Report__c where Id=: cr2.id];
        TR1__Job_Reporting__c jobReporting = new TR1__Job_Reporting__c(Id = closingReport.TR1__Job_Reporting__c);
        jobReporting.TR1__Send_Out__c = sendout.id;
        
        update jobReporting;
        
        sendout.Split_Recruiter_lookup__c = UserInfo.getUserId();
        update sendout;
        /*
        TR1__Job_Reporting__c jobReporting = new TR1__Job_Reporting__c();
        jobReporting.TR1__Send_Out__c = sendout.id;
        jobReporting.TR1__Job__c = job.id;
        jobReporting.TR1__Closing_Report__c = cr2.id;
        insert jobReporting;*/
    }
}
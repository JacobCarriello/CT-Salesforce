@
istest(seeAlldata = true)
public class JobSearchControllerTest {

    public static testmethod void TestJobSearchController() {
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.tr1__State_Area__c = 'Alabama';
        con.tr1__regional_Area__c = 'Mobile Metro Area';
        con.tr1__Primary_background__c = 'Test Primary Background';
        con.tr1__Secondary_background__c = 'Test Sec Background';
        insert con;
        Test.setCurrentPage(page.Jobsearch);
        apexpages.currentpage().getParameters().put('sitename', JobSearchController.DefaultJobBoardName);
        apexpages.currentpage().getParameters().put('Jobboard', JobSearchController.DefaultJobBoardName);


        JobSearchController jbboard = new JobSearchController();
        jbboard.jobTemp = new tr1__Job__c();
        jbboard.resumeflag = true;
        jbboard.cont();
        jbboard.jobKeyword = 'Test Contact';
        jbboard.jobTemp.tr1__State_Area__c = 'Alabama';
        jbboard.jobTemp.tr1__regional_Area__c = 'Mobile Metro Area';
        jbboard.jobTemp.tr1__Primary_background__c = 'Test Primary Background';
        jbboard.jobTemp.tr1__Secondary_background__c = 'Test Sec Background';
        jbboard.jobsearch();
        jbboard.getJobs();
        jbboard.cont();
        jbboard.firstjobs();
        jbboard.lastjobs();
        jbboard.previousjobs();
        jbboard.nextjobs();
        jbboard.cont();
		
        
        
        insert new tr1__job__c(TR1__Job_Board__c = JobSearchController.DefaultJobBoardName, TR1__Job_Title__c='Test Job', TR1__External_Job_Title__c='EXT-TEST001', tR1__Post_Externally__c = true, TR1__Status__c = 'Open',TR1__Client_Description__c ='test',TR1__Education_Requirements__c='aaa',TR1__Experience_Requirements__c='bbb',TR1__Responsibilities__c='ccc');
        
        List < tr1__job__c > jb = [select Id from tr1__job__c where TR1__Job_Board__c includes(: JobSearchController.DefaultJobBoardName)
            and TR1__Post_Externally__c = true and TR1__Status__c != 'Closed'  order by LastModifiedDate desc 
            limit 1
        ];
        if (jb.size() > 0) {

            Test.setCurrentPage(page.jobRegister);
            apexpages.currentpage().getParameters().put('jobId', jb[0].Id);
            JobSearchController jbboardnew = new JobSearchController();
            jbboardnew.resumeflag = true;
            jbboardnew.resumetype = 'Upload';
            jbboardnew.con = new Contact();
            jbboardnew.con.LastName = 'Test Last';
            jbboardnew.con.Email = 'Test.Last@test.com';
            jbboardnew.con.firstName = 'Test First';
            jbboardnew.con.phone = '123456';
            Attachment attchment = new Attachment();
            attchment.Body = blob.valueOf('This is Test Resume');
            jbboardnew.ResumeName = 'test Resume';
            jbboardnew.ResumeBody = attchment.Body;
            jbboardnew.resumecontentype = 'text/plain';
            jbboardnew.createUpdateResume();
            jbboardnew.cont();
        }


        if (jb.size() > 0) {

            Test.setCurrentPage(page.jobRegister);
            apexpages.currentpage().getParameters().put('jobId', jb[0].Id);
            JobSearchController jbboardnew = new JobSearchController();

            jbboardnew.resumeflag = true;
            jbboardnew.resumetype = 'Paste';
            jbboardnew.con = new Contact();
            jbboardnew.con.LastName = 'Test Last';
            jbboardnew.con.Email = 'Test.Last@test.com';
            jbboardnew.con.firstName = 'Test First';
            jbboardnew.con.phone = '123456';
            Attachment attchment = new Attachment();
            attchment.Body = blob.valueOf('This is Test Resume');
            jbboardnew.resumebodyText = 'This is Test Resume';
            jbboardnew.ResumeName = 'test Resume';
            jbboardnew.ResumeBody = attchment.Body;
            
            Test.startTest();
            jbboardnew.createUpdateResume();
            jbboardnew.cont();


        }
        if (jb.size() > 0) {

            Test.setCurrentPage(page.jobRegister);
            apexpages.currentpage().getParameters().put('jobId', jb[0].Id);
            JobSearchController jbboardnew = new JobSearchController();

            jbboardnew.resumeflag = true;
            jbboardnew.resumetype = 'Paste';
            jbboardnew.con = new Contact();
            jbboardnew.con.LastName = 'Test Last';
            jbboardnew.con.Email = 'Test.Last@test.com';
            jbboardnew.con.firstName = 'Test First';
            jbboardnew.con.phone = '123456';
            Attachment attchment = new Attachment();
            attchment.Body = blob.valueOf('This is Test Resume');
            jbboardnew.resumebodyText = 'This is Test Resume';
            jbboardnew.ResumeName = 'test Resume';
            jbboardnew.ResumeBody = attchment.Body;
            jbboardnew.SubmitWOResume();
            jbboardnew.cont();


        }

        if (jb.size() > 0) {

            Test.setCurrentPage(page.jobEmail);
            apexpages.currentpage().getParameters().put('jobId', jb[0].Id);
            JobSearchController jbboardnew = new JobSearchController();
            jbboardnew.sndEmail();
            jbboardnew.fromEmail = 'testa@test.com';
            jbboardnew.toEmail = 'testa@test.com';
            jbboardnew.sndEmail();
        }

		Test.stopTest();

    }


}
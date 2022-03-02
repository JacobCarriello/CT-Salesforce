@istest
public class Test_ExternalJobFeedsController {
    static testMethod void TestExternalJF() {
        List < TR1__Jobs_Feeds__c > testJFList = new List < TR1__Jobs_Feeds__c > ();
        TR1__Jobs_Feeds__c testJF1 = new TR1__Jobs_Feeds__c();
        TR1__Jobs_Feeds__c testJF2 = new TR1__Jobs_Feeds__c();
        TR1__Jobs_Feeds__c testJF3 = new TR1__Jobs_Feeds__c();
        TR1__Jobs_Feeds__c testJF4 = new TR1__Jobs_Feeds__c();
        TR1__Jobs_Feeds__c testJF5 = new TR1__Jobs_Feeds__c();
        testJF1.TR1__Element_Name__c = 'Owner';
        testJF1.TR1__field_name__c = 'Ownerid';
        testJF1.name = '1';
        testJFList.add(testJF1);
        testJF2.TR1__Element_Name__c = 'Name';
        testJF2.name = '2';
        testJFList.add(testJF2);
        testJF3.TR1__Element_Name__c = 'Company';
        testJF3.TR1__field_name__c = 'TR1__Job_Board__c';
        testJF3.name = '3';
        testJFList.add(testJF3);
        testJF4.TR1__Element_Name__c = 'Category';
        testJF4.TR1__field_name__c = '';
        testJF4.name = '4';
        testJFList.add(testJF4);
        testJF5.TR1__Element_Name__c = 'Id';
        testJF5.TR1__field_name__c = 'id';
        testJF5.name = '5';
        testJFList.add(testJF5);
        insert testJFList;

        TR1__Job__c job = new TR1__Job__c();
        job.ownerid = userinfo.getUserId();
        //job.of_Position_Available__c  = 5;
        job.name = 'test class';
        job.TR1__Post_Externally__c = true;
        job.TR1__External_Job_Title__c = 'JobTest';
        job.TR1__Job_Board__c = 'CVPartners';
        job.TR1__Client_Description__c = 'Client_Description__c';
        job.TR1__Education_Requirements__c = 'Education_Requirements__c';
        job.TR1__Experience_Requirements__c = 'Experience_Requirements__c ';
        job.TR1__Responsibilities__c = 'Responsibilities__c ';
        insert job;

        PageReference pageRef = Page.THMED_ExternalJobFeeds;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('THMED_ExternalJobFeeds', 'CVPartners');
        ExternalJobFeedsController jfc = new ExternalJobFeedsController();
        jfc.JobBoardName = 'CVPartners';
    }
}
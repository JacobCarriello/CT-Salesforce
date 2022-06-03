/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class jobsfeedcontrollerTest {

    static testMethod void Testjobsfeedcontroller() {
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
        testJF5.TR1__Element_Name__c = 'url';
        testJF5.TR1__field_name__c = 'id';
        testJF5.name = '5';
        testJFList.add(testJF5);

        insert testJFList;


        TR1__Job__c job = new TR1__Job__c();
        job.ownerid = userinfo.getUserId();
        job.name = 'test class';
        job.TR1__Post_Externally__c = true;
        job.TR1__External_Job_Title__c = 'JobTest';
        job.TR1__Job_Board__c = 'CVPartners';
        job.TR1__Client_Description__c = 'Client_Description__c';
        job.TR1__Education_Requirements__c = 'Education_Requirements__c';
        job.TR1__Experience_Requirements__c = 'Experience_Requirements__c ';
        job.TR1__Responsibilities__c = 'Responsibilities__c ';
        insert job;
        PageReference pageRef = Page.jobsfeed;
        Test.setCurrentPage(pageRef);
        //Setting required parameters <br/>
        ApexPages.currentPage().getParameters().put('jobboard', 'CVPartners');
        jobsfeedcontroller jfc = new jobsfeedcontroller();
        jfc.JobBoardName = 'CVPartners';
    }
}
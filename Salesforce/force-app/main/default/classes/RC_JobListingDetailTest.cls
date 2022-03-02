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
private class RC_JobListingDetailTest 
{
    static testMethod void JobListingDetailTest() 
    {
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        objJob.TR1__Post_Externally__c = true;
        objJob.TR1__Status__c = 'Open';
        objJob.TR1__Client_Description__c = 'Test';
        objJob.TR1__Education_Requirements__c = 'Test';
        objJob.TR1__Experience_Requirements__c = 'Test';
        objJob.TR1__Responsibilities__c = 'Test';
        objJob.TR1__External_Job_Title__c = 'Test';
        update objJob;
        
        User u = RC_UtilityClass.returnCommunityContactTypeUser('c&c');   
        Contact objContact = [Select id from Contact where Id =: u.contactId];
        objContact.TR1__Candidate_Status__c = 'Active';
        update objContact;
        Test.startTest();
            RC_JobListingDetail objJobTest = new RC_JobListingDetail();
            PageReference pgRedirect = objJobTest.redirectUnAuthenticatedUser();
            System.assertEquals('/Signin', pgRedirect.getURL());
        System.runAs(u)
        {   
            Apexpages.currentPage().getParameters().put('Id', objJob.Id);
            Apexpages.currentPage().getParameters().put('apply', '1');
            system.assertEquals('1',ApexPages.currentPage().getParameters().get('apply'));
            system.assertEquals(objJob.Id,ApexPages.currentPage().getParameters().get('Id'));
            RC_JobListingDetail objJobTest1 = new RC_JobListingDetail();
            PageReference pgRedirect1 = objJobTest1.redirectUnAuthenticatedUser();
            objJobTest1.updateCandidateStatusNJobApply();
            system.assertEquals('Active', objJobTest1.objContact.TR1__Candidate_Status__c);
        }
        Test.stopTest();
    }
}
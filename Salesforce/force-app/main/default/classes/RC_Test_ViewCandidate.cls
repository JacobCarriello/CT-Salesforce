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
private class RC_Test_ViewCandidate
{

    static testMethod void RC_Test_ViewCandidate()  
    {
        
        Candidate_Community__c setting = new Candidate_Community__c();
        setting.Name = 'RegistrationDetail';
        setting.Include_Stages__c = 'Shortlist:Client Interview:Submittal:Send Out:Sendout:Offer:Closing Report';
        insert setting;
             
    	User objUser = RC_UtilityClass.returnCommunityUser();
        Id candidateId = [Select contactId from User where id =: objUser.Id].contactId;
        system.debug('strId ' + candidateId);
              
        Contact objContact = [Select Id From Contact Where Id =: objUser.ContactId];
        objContact.Board_Certifications__c = 'Addiction Psychiatry (NOT Cert/Elig)';
        objContact.TR1__Certifications__c = 'CCRN';
        objContact.Has_DEA_ever_been_suspended_or_revoked__c = 'No';
        objContact.Malpractice_Pending_Settled_Dismissed__c = 'Unsure';
        objContact.Probations_Suspensions_on_state_license__c = 'No';
        objContact.Specialties__c = 'Addiction Medicine';
        objContact.State_Licensure__c = 'Colorado';
        objContact.Substance_Abuse_Issues_Alcohol_Drug__c = 'No';
        objContact.TR1__Systems_Experience__c = 'AdvantaChart EHR';
        update objContact;       
        
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        objJob.TR1__Hiring_Manager__c = candidateId;
        objJob.TR1__Contact__c = candidateId;
        objJob.Account_Manager__c = objUser.Id;
        
        update objJob;
        
        TR1__Application__c objApplication = new TR1__Application__c();
        objApplication.TR1__Job__c = objJob.Id;
        objApplication.TR1__Applicant__c = objUser.ContactId;
        insert objApplication;

        TR1__Job_Reporting__c jobReport = new TR1__Job_Reporting__c();
        jobReport.TR1__Job__c = objJob.Id;
        jobReport.TR1__Contact__c = candidateId;
        jobReport.TR1__Stage__c = 'Submittal';
        jobReport.TR1__Application__c = objApplication.Id;
        insert jobReport;
        
        System.debug('objJob ' + objJob);
        System.debug('jobReport ' + jobReport);
        
        system.runAs(objUser)
        {
            Apexpages.currentPage().getParameters().put('id', candidateId); 
            Apexpages.currentPage().getParameters().put('JobId', objJob.Id);
            Apexpages.currentPage().getParameters().put('rating', '4'); 

        	RC_ViewCandidate objCandidate = new RC_ViewCandidate();
        	objCandidate.redirectUnAuthenticatedUser();
             
        	System.assertNotEquals(null, objCandidate.smallPhotoUrl);
        	
        	//Empty Param
        	Apexpages.currentPage().getParameters().put('id', ''); 
            Apexpages.currentPage().getParameters().put('JobId', ''); 
        	
        	RC_ViewCandidate objCandidate1 = new RC_ViewCandidate();
        	
        	//Wrong Id
        	Apexpages.currentPage().getParameters().put('id', '003456784'); 
            Apexpages.currentPage().getParameters().put('JobId', '00000000000000'); 
        	
        	RC_ViewCandidate objCandidate2 = new RC_ViewCandidate();
        	
        }
        
    }
}
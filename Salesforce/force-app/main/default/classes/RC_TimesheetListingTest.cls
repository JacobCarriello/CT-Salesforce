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
private class RC_TimesheetListingTest {
    
    static testMethod void TimesheetListingTest() 
    {
        RC_TimesheetListing objListing;
        
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        
        TR1__Timesheet__c  objTimesheet = RC_UtilityClass.insertTimeSheet(objJob.Id);
        User thisUser = RC_UtilityClass.returnCommunityUser();
        objListing = new RC_TimesheetListing();
        PageReference pgRef2 = objListing.redirectUnAuthenticatedUser(); 
        System.assertEquals('/Signin', pgRef2.getUrl());
        
        System.RunAs(thisUser) 
        {
            
            Test.startTest(); 
            objListing = new RC_TimesheetListing();
            PageReference pgRef1 = objListing.redirectUnAuthenticatedUser();  
            System.assertEquals(null, pgRef1);
            
            Account objAcc = [SELECT id FROM Account LIMIT 1];
            Contact objContact = [SELECT id FROM Contact LIMIT 1];
            objTimesheet.TR1__Client__c = objAcc.Id;
            objTimesheet.TR1__Consultant__c = objContact.Id; 
            RC_AccessController.updateRecord(objTimesheet);
            Apexpages.currentPage().getParameters().put('save', '');
            RC_TimesheetListing objListingTest = new RC_TimesheetListing(); 
            system.debug('---lstTimesheet'+objListingTest.lstTimesheet);
            //system.assertEquals(1, objListingTest.lstTimesheet.size());   
            Test.stopTest();
        }
    }
}
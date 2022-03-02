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
private class RC_UtilityClassTest 
{

    static testMethod void myUnitTest() 
    {
    	
    		TR1__Job__c objJob = RC_UtilityClass.insertJob();
    		system.assertEquals(1, [Select id from TR1__Job__c where Id =: objJob.id].size());
    		
    		TR1__Timesheet__c objTimesheet = RC_UtilityClass.insertTimeSheet(objJob.Id);
    		system.assertEquals(1, [Select id from TR1__Timesheet__c where Id =: objTimesheet.Id].size());
    		
    		TR1__Timesheet_Detail__c objTimesheetDetail = RC_UtilityClass.insertTimeSheetDetail(objTimesheet.id);
    		system.assertEquals(1, [Select id from TR1__Timesheet_Detail__c where Id =: objTimesheetDetail.Id].size());
    		
    		User objUser = RC_UtilityClass.returnCommunityUser();
    		system.assertEquals(1, [Select id from User where Id =: objUser.Id].size());
    		
    		User objUserCommunityContactType2 = RC_UtilityClass.returnCommunityContactTypeUser('c&c');
            system.assertEquals(1, [Select id from User where Id =: objUserCommunityContactType2.Id].size());

            User objUserCommunityContactType = RC_UtilityClass.returnCommunityContactTypeUser('candidate', '1');
    		system.assertEquals(1, [Select id from User where Id =: objUserCommunityContactType.Id].size());
    		
    		TR1__Closing_Report__c objClosingReport = RC_UtilityClass.returnClosingReport(false);
        	objClosingReport.TR1__Person_Placed__c = objUserCommunityContactType2.contactId;
    		objClosingReport.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'TR1__Closing_Report__c' And isActive=true AND Name = 'Consulting'][0].Id;
        
        Test.startTest();
        
        	insert objClosingReport;
    		system.assertEquals(1, [Select id from TR1__Closing_Report__c where Id =: objClosingReport.id].size());
    		
    		TR1__Expense_Report__c objExpenseReport = RC_UtilityClass.returnExpenseReport();
    		system.assertEquals(1, [Select id from TR1__Expense_Report__c where Id =: objExpenseReport.Id].size());
    		
    		objExpenseReport.TR1__Status__c = 'Unsubmitted';
    		update objExpenseReport;
    		system.assertEquals('Unsubmitted', [Select TR1__Status__c from TR1__Expense_Report__c where Id =: objExpenseReport.Id].TR1__Status__c);
    		
    		TR1__Expense_Report_Detail__c objExpenseReportsDetail = RC_UtilityClass.returnExpenseReportDetail();
    		system.assertEquals(1, [Select id from TR1__Expense_Report_Detail__c where Id =: objExpenseReportsDetail.Id].size());
    	Test.stopTest();
    }
}
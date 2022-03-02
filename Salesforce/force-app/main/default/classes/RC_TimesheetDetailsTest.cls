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
private class RC_TimesheetDetailsTest 
{
    @isTest 
    static void TimesheetDetailsTest() 
    {
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        TR1__Timesheet__c  objTimesheet = RC_UtilityClass.insertTimeSheet(objJob.Id);
        User communityUser = RC_UtilityClass.returnCommunityUser();
        Id approverId = [Select ContactId from User where Id =: communityUser.Id limit 1].ContactId;
        Id consultantId = RC_UtilityClass.createAndGetContactId('ConsultantName');
        objTimesheet.TR1__Approver__c = approverId;
        objTimesheet.TR1__Consultant__c = consultantId;
        update objTimesheet;
        TR1__Timesheet_Detail__c objTimesheetDetail = RC_UtilityClass.insertTimeSheetDetail(objTimesheet.Id);
        objTimesheetDetail = [Select TR1__Date__c, TR1__Day__c , TR1__Regular_Hours__c, TR1__Overtime_Hours__c, TR1__Double_Time_Hours__c, TR1__Vacation_Hours__c, Total_Hours__c from TR1__Timesheet_Detail__c where TR1__Timesheet__c =:objTimesheet.id];

        
        System.runAs(communityUser)
        {
            Test.startTest();
                PageReference pageRef = Page.TimesheetDetails;
       			Test.setCurrentPage(pageRef);               
        		pageRef.getParameters().put('tsId', objTimesheet.id);
             	RC_TimesheetDetails objTimesheetDetails = new RC_TimesheetDetails();
                objTimesheetDetails.saveTimesheetDetails();
                objTimesheetDetails.saveNSubmitTimesheetDetails();
                System.debug('----- lstTimesheetDetailRecords : '+objTimesheetDetails.lstTimesheetDetailRecords);  
            	System.debug('[Select]' + RC_AccessController.query('Select Name, TR1__Status__c from TR1__Timesheet__c where Id = \'' + objTimesheet.Id + '\''));
                system.assertEquals('Submitted', ((TR1__Timesheet__c)RC_AccessController.query('Select Name, TR1__Status__c from TR1__Timesheet__c where Id = \'' + objTimesheet.Id + '\'')[0]).TR1__Status__c);
                objTimesheetDetails.approveTimesheet(); 
                system.assertEquals('Approved', ((TR1__Timesheet__c)RC_AccessController.query('Select TR1__Status__c from TR1__Timesheet__c where Id = \'' + objTimesheet.Id + '\'')[0]).TR1__Status__c);
                //objTimesheetDetails.objShift = objShiftWork;
                //objTimesheetDetails.logHoursShift();
                //objTimesheetDetails.editShiftWork();
                //objTimesheetDetails.deleteShiftWork();
                objTimesheet.TR1__Approvers_Notes__c = 'Test';
            	RC_AccessController.updateRecord(objTimesheet);
                objTimesheetDetails.rejectTimesheet();
                objTimesheetDetails.rejectTimesheet();
                system.assertEquals('Rejected', ((TR1__Timesheet__c)RC_AccessController.query('Select TR1__Status__c from TR1__Timesheet__c where Id = \'' + objTimesheet.Id + '\'')[0]).TR1__Status__c);
                
            Test.stopTest(); 
        }
    }
    
    @isTest 
    static void CheckRedirectUnAuthenticatedUser() 
    {
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        TR1__Timesheet__c  objTimesheet = RC_UtilityClass.insertTimeSheet(objJob.Id);       
        TR1__Timesheet_Detail__c objTimesheetDetail = RC_UtilityClass.insertTimeSheetDetail(objTimesheet.Id);
        RC_TimesheetDetails objTimesheetDetails = new RC_TimesheetDetails();
        PageReference pg = objTimesheetDetails.redirectUnAuthenticatedUser();
        System.assertEquals('/Signin', pg.getUrl()); 
    }
}
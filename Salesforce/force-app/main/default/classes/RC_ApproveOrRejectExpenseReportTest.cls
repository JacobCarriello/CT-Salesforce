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
private class RC_ApproveOrRejectExpenseReportTest 
{
    static testMethod void myUnitTest() 
    {
    	
    	User communityPlacedUser  = RC_UtilityClass.returnCommunityContactTypeUser('candidate', '1');
        User communityApproverUser  = RC_UtilityClass.returnCommunityContactTypeUser('c&c', '2');
        Account testAcc = new Account(name='Test');  
        insert testAcc; 

        Contact assignedPerson = new Contact(LastName = 'assigned/pased person');

        TR1__Closing_Report__c objCloseRep = new TR1__Closing_Report__c();
        objCloseRep.TR1__Account__c = testAcc.id;
        objCloseRep.TR1__Job_Percentage__c = 20;
        objCloseRep.TR1__Candidate_Percentage__c  = 20;
        objCloseRep.TR1__Marketing_Percentage__c  = 20;
        objCloseRep.TR1__Other_Percentage__c  = 20;
        objCloseRep.TR1__Other2_Percentage__c = 20;
        objCloseRep.TR1__Job__c = RC_UtilityClass.insertJob().id; 
        objCloseRep.TR1__Person_Placed__c = communityPlacedUser.contactId;
        objCloseRep.TR1__Timesheet_Approver__c = communityApproverUser.contactId;
        insert objCloseRep;

        TR1__Expense_Report__c objExpense = RC_UtilityClass.returnExpenseReport();
        objExpense.TR1__Closing_Report__c = objCloseRep.Id; 

        RC_AccessController.updateRecord(objExpense);

        System.runAs(communityApproverUser) {

            Test.startTest();
            RC_ApproveOrRejectExpenseReport objreport = new RC_ApproveOrRejectExpenseReport();

            // try to approve without parametrs
            Apexpages.currentPage().getParameters().put('id', ''); 
            Apexpages.currentPage().getParameters().put('action', '');            
            objreport.approveExpReportFromAction();
            system.assertEquals('Insufficient parameters in URL', objreport.strMessage);

            // approve Expense report
            Apexpages.currentPage().getParameters().put('id', objExpense.id);
            Apexpages.currentPage().getParameters().put('action', 'Approved');

            objreport.approveExpReportFromAction();
            system.debug('-----message--'+objreport.strMessage);
            String strConsultant = ((TR1__Expense_Report__c)RC_AccessController.query('Select TR1__Consultant__r.Name from TR1__Expense_Report__c where id = \'' + objExpense.Id + '\'')[0]).TR1__Consultant__r.Name;
            system.assertEquals('Expense report for '+strConsultant+' has been approved', objreport.strMessage);

            // try to approve without submit
            objExpense.TR1__Status__c = 'Unsubmitted'; 
            RC_AccessController.updateRecord(objExpense);
            objreport.approveExpReportFromAction();
            system.assertEquals('This Expense report has not been submitted for Approval', objreport.strMessage);

            // try to update status
            objExpense.TR1__Status__c = 'Rejected';
            RC_AccessController.updateRecord(objExpense);
            objreport.approveExpReportFromAction(); 
            system.assertEquals('Rejected', ((TR1__Expense_Report__c)RC_AccessController.query('Select TR1__Status__c from TR1__Expense_Report__c where Id = \''+ objExpense.id + '\'')[0]).TR1__Status__c);

            // update status to Approved
            objreport.UpdateStatusToApproved();
            system.assertEquals('Approved', ((TR1__Expense_Report__c)RC_AccessController.query('Select TR1__Status__c from TR1__Expense_Report__c where Id = \''+ objExpense.id + '\'')[0]).TR1__Status__c);

            // update Notes case 1: status Approved
            objreport.updateNotes();
            system.assertEquals('Comments added', objreport.strMessage);

            // new Expense report
            RC_ApproveOrRejectExpenseReport objreportTest1 = new RC_ApproveOrRejectExpenseReport();
            Apexpages.currentPage().getParameters().put('id', objExpense.id);
            Apexpages.currentPage().getParameters().put('action', 'Approved');
            objExpense.TR1__Comments__c = 'some comment';
            RC_AccessController.updateRecord(objExpense);

            // update Notes case 2: status is Rejected
            objreportTest1.updateNotes();
            system.debug('objreport.strMessage ' + objreportTest1.strMessage);
            system.assertEquals('Notes can\'t be empty when status is rejected', objreportTest1.strMessage);       

            // delete objExpense;
            system.assertEquals(1, (RC_AccessController.query('Select Id from TR1__Expense_Report__c where id = \''+ objExpense.id + '\'')).size()); 
            RC_AccessController.deleteRecord(objExpense);
            system.assertEquals(0, (RC_AccessController.query('Select Id from TR1__Expense_Report__c where id = \''+ objExpense.id + '\'')).size());
            Test.stopTest();
        }

    	
    }
}
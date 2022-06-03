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
private class RC_MyAccountTest
{

    static testMethod void MyAccountTest()  
    {
    	User objUser = RC_UtilityClass.returnCommunityUser();
        String strId = [Select contactId from User where id =: objUser.Id].contactId;
        
        TR1__EmploymentHistory__c objEmploymentHistory = new TR1__EmploymentHistory__c(TR1__Contact__c = strId, TR1__EndDate__c = string.valueOf(date.today().format()));
        insert objEmploymentHistory;
        
        TR1__EducationHistory__c objEducationHistory = new TR1__EducationHistory__c(TR1__Contact__c = strId, TR1__EndDate__c = string.valueOf(date.today().format()));
        insert objEducationHistory;
        
        TR1__ContactDocument__c objContactDocument = new TR1__ContactDocument__c(TR1__Contact__c = strId, TR1__isDefault__c = true);
        insert objContactDocument;
        
        
        
        system.runAs(objUser)
        {
	        Test.startTest();
	        	RC_MyAccount_v1 objMyAccount = new RC_MyAccount_v1();
	        	objMyAccount.objEmploymentDetail = objEmploymentHistory; 
	        	objMyAccount.objEducationDetail = objEducationHistory;
	        	Apexpages.currentPage().getParameters().put('isEdit', 'true'); 
	        	objMyAccount.redirectUnAuthenticatedUser();
	        	system.assertEquals(true, objMyAccount.isEditable);
	        	
	        	//objMyAccount.isEditable = false;
	        	//objMyAccount.isSuccess = true;
	        	objMyAccount.updateContactInfo();
	        	system.assertEquals(true, objMyAccount.isEditable);
	        	system.assertEquals(false, objMyAccount.isSuccess);
	        	
	        	objMyAccount.editContactInfo();
	        	system.assertEquals(true, objMyAccount.isEditable);
	        	
	        	objMyAccount.cancelEditContactInfo();
	        	system.assertEquals(false, objMyAccount.isEditable);
	        	
	        	objMyAccount.isUploadSuccess = true;
	        	objMyAccount.getUploadDetails();
	        	system.assertEquals(true, objMyAccount.isUploadSuccess);
	        	
	        	objMyAccount.strRelatedListName = 'Employment';
	        	objMyAccount.strHistoryId = objEmploymentHistory.Id;
	        	objMyAccount.deleteRelatedHistoryRecord();
	        	system.assertEquals(0, [Select id from TR1__EmploymentHistory__c where id=: objEmploymentHistory.id].size());
	        	
	        	objMyAccount.strRelatedListName = '';
	        	objMyAccount.strHistoryId = objEducationHistory.Id;
	        	objMyAccount.deleteRelatedHistoryRecord();
	        	system.assertEquals(0, [Select id from TR1__EmploymentHistory__c where id=: objEmploymentHistory.id].size());
	        	
	        Test.stopTest();
        }
        
    }
}
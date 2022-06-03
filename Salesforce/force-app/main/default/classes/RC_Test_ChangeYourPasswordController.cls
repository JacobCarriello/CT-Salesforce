@isTest
private class RC_Test_ChangeYourPasswordController 
{
	private static testMethod void test_RFRK_ResetYourPassword() 
    {
        Test.setCurrentPageReference(new PageReference('Page.ResetYourPassword'));
        System.currentPageReference().getParameters().put('retURL', 'MyProfile');
        
        RC_ChangeYourPasswordController objController = new RC_ChangeYourPasswordController();
        objController.redirectUnAuthenticatedUser();
        objController.changePassword();
        
    }	
}
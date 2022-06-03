@isTest
private class RC_Test_ForgotYourPasswordController 
{
    private static testMethod void test_RC_Test_ForgotYourPasswordController() 
    {
        RC_ForgotYourPasswordController objController = new RC_ForgotYourPasswordController();

        
        RC_Test_Utility.createUser();
        
        System.runAs(RC_Test_Utility.objUser)
        {
            objController.strUsername = 'test@salesforce.com';  
            objController.redirectAuthenticatedUser();
            System.assertEquals(objController.forgotPassword(),null); 
        }
    }

    private static testMethod void test_RC_Test_ForgotYourPasswordController2() 
    {
        RC_ForgotYourPasswordController objController = new RC_ForgotYourPasswordController();

        objController.strUsername = 'test@salesforce1.com';  
        objController.redirectAuthenticatedUser();
    
        System.assertEquals(objController.forgotPassword(),null); 
    }
    
}
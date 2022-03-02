@isTest
private class RC_Test_SigninController 
{

    private static testMethod void test() 
    {
       	RC_Test_Utility.createUser();
        
        RC_SigninController objController = new RC_SigninController();
        PageReference pageRef = objcontroller.redirectAuthenticatedUser();
        system.assertEquals(null,pageRef);
        System.runAs(RC_Test_Utility.objUser)
        {
            objController.login();
            PageReference pageRef1 = objcontroller.redirectAuthenticatedUser();
            system.assertNotEquals(null,pageRef1);  
        }
        
    }

}
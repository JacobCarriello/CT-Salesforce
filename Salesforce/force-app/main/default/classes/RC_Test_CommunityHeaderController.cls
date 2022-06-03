@isTest
private class RC_Test_CommunityHeaderController 
{
    private static testMethod void test()
    {
        
        RC_Test_Utility.createUser();
        
        System.runAs(RC_Test_Utility.objUser){
            PageReference pageRef = Page.MyAccount_v1;
            Test.setCurrentPage(pageRef);
            RC_CommunityHeaderController objController = new RC_CommunityHeaderController();
            system.assertEquals(RC_Test_Utility.objUser.ContactId, RC_Test_Utility.objContact.Id);
        }
        
    }

}
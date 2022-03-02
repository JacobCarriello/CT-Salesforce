@isTest()
public class RC_Test_ContactUsController 
{
    private static testMethod void TestContactUs()
    {
        RC_ContactUsController objContactUs = new RC_ContactUsController();
        System.assertEquals('Help Desk', objContactUs.strSubject);
        objContactUs.strEmail = 'wed.f@g.com, dew.g@y.com';
        
        
        objContactUs.redirectUnAuthenticatedUser();
        objContactUs.sendEmail();
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        System.assertEquals(objContactUs.strName, UserInfo.getFirstName()+' '+UserInfo.getLastName());
    }
}
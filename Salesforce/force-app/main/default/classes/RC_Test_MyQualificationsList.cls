@isTest
private class RC_Test_MyQualificationsList 
{
    private static testMethod void test_RC_MyQualificationsList() 
    {
        RC_MyQualificationsList objController = new RC_MyQualificationsList();
        PageReference pg = objController.redirectUnAuthenticatedUser();
        System.assertEquals('/Signin',pg.getURL()); 
        User u = RC_UtilityClass.returnCommunityUser();
        Contact con = [SELECT id FROM Contact LIMIT 1];

        TR1__Qualification__c objQualification = new TR1__Qualification__c(Name='Test-Qualification'); 
        insert objQualification;

        TR1__Associated_Qualification__c objAssociatedQualification = new TR1__Associated_Qualification__c(TR1__Qualification__c = objQualification.Id,TR1__Contact__c = con.id);
        insert objAssociatedQualification;

        System.runAs(u)
        {
            pg = objController.redirectUnAuthenticatedUser();
            System.assertEquals(null,pg);  
        }
    }
}
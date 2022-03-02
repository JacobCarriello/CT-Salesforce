@isTest
private class RC_Test_MyQualificationEditSuccess 
{

    private static testMethod void test() 
    {
        Test.startTest();
        RC_MyQualificationEditSuccess objController = new RC_MyQualificationEditSuccess();
        PageReference pg = objController.redirectUnAuthenticatedUser();
        System.assertEquals('/Signin',pg.getUrl());
        //RC_Test_Utility.createUser();
        User u = RC_UtilityClass.returnCommunityUser();

        TR1__Qualification__c objQualification = new TR1__Qualification__c(Name='Test-Qualification');
        insert objQualification;
        
        TR1__Associated_Qualification__c objAssociatedQualification = new TR1__Associated_Qualification__c(TR1__Qualification__c = objQualification.Id,TR1__Contact__c = u.ContactId ,TR1__Status__c='Requested');
        insert objAssociatedQualification; 
        
        Test.setCurrentPageReference(new PageReference('Page.MyQualificationEditSuccess'));
        System.currentPageReference().getParameters().put('qId', objAssociatedQualification.Id);
        
        System.runAs(u)
        {
            pg = objController.redirectUnAuthenticatedUser(); 
            System.assertEquals(null, pg); 
            System.assertEquals(true,objController.isPageLoad);
            //List<TR1__Associated_Qualification__c> lstAssociatedQualification = [Select TR1__Qualification__r.Name, TR1__Status__c From TR1__Associated_Qualification__c where id =: objAssociatedQualification.Id];
            List <TR1__Associated_Qualification__c> lstAssociatedQualification = RC_AccessController.query('Select TR1__Qualification__r.Name, TR1__Status__c From TR1__Associated_Qualification__c where id = \'' + objAssociatedQualification.Id + '\'');
            System.assertEquals('Submitted',lstAssociatedQualification[0].TR1__Status__c);  
            
            System.currentPageReference().getParameters().put('qId', '0030C000001fs8g'); 
            objController =  new RC_MyQualificationEditSuccess();
            pg = objController.redirectUnAuthenticatedUser(); 
            System.assertEquals(false,objController.isPageLoad); 
           
        }
        Test.stopTest(); 
        
    }

}
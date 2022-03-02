@isTest
private class RC_Test_MyQualificationDocuSign {
    
    private static testMethod void test_RC_MyQualificationsList() 
    {
        RC_MyQualificationDocuSign objController = new RC_MyQualificationDocuSign();
        PageReference pg = objController.redirectUnAuthenticatedUsers();
        System.assertEquals('/Signin',pg.getUrl());
        User u = RC_UtilityClass.returnCommunityUser();
        
        TR1__Qualification__c objQualification = new TR1__Qualification__c(Name='Test-Qualification',TR1__Collection_Methods__c='Docusign;Field Update');
        insert objQualification;

        TR1__Associated_Qualification__c objAssociatedQualification = new TR1__Associated_Qualification__c(TR1__Qualification__c = objQualification.Id,TR1__Contact__c = u.ContactId);
        insert objAssociatedQualification;

        ApexPages.currentPage().getParameters().put('qId',objAssociatedQualification.Id);  

        System.runAs(u)
        {
            pg = objController.redirectUnAuthenticatedUsers(); 
            System.assertEquals(null,pg);
            //System.assertEquals(objAssociatedQualification.Id,objController.strQualificationId);//prevRedirectionPage
            System.assertEquals('MyQualificationRedirect',objController.nextRedirectionPage);
            System.assertEquals('MyQualificationDetailEdit',objController.prevRedirectionPage);
            
            objQualification.TR1__Collection_Methods__c = 'Docusign';
            RC_AccessController.updateRecord(objQualification);
            objController = new RC_MyQualificationDocuSign();  
            objController.redirectUnAuthenticatedUsers();
            System.assertEquals('MyQualificationsList',objController.prevRedirectionPage); 
            
            ApexPages.currentPage().getParameters().remove('qId');
            objController = new RC_MyQualificationDocuSign(); 
            objController.redirectUnAuthenticatedUsers(); 
            System.assertEquals(false,objController.isPageLoad); 
            
            
        }
        objController.fetchContactInfo();  
    }
    
}
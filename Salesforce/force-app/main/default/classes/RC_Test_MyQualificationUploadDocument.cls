@isTest
private class RC_Test_MyQualificationUploadDocument {

    private static testMethod void test() {
        RC_MyQualificationUploadDocument objController = new RC_MyQualificationUploadDocument();
        PageReference pg = objController.redirectUnAuthenticatedUser();
        System.assertEquals('/Signin',pg.getURL());
        //RC_Test_Utility.createUser();  
        User u = RC_UtilityClass.returnCommunityUser();
        
        List<Contact> selectedContactList = [SELECT id FROM Contact];
        Contact con = selectedContactList[1];
        
        Attachment objAttachment = new Attachment(Name='Test-Attachment',Body=Blob.valueOf('Attachment body'));
        
        TR1__Qualification__c objQualification = new TR1__Qualification__c(Name='Test-Qualification',TR1__Collection_Methods__c = 'Docusign');
        insert objQualification;

        TR1__Associated_Qualification__c objAssociatedQualification = new TR1__Associated_Qualification__c(TR1__Qualification__c = objQualification.Id,TR1__Contact__c = con.id,TR1__Status__c='Requested');
        insert objAssociatedQualification;
        
        Test.setCurrentPageReference(new PageReference('Page.MyQualificationUploadDocument'));
        System.currentPageReference().getParameters().put('qId', objAssociatedQualification.Id); 
        
        objController.redirectUnAuthenticatedUser();
        
        System.runAs(u)
        {
            pg = objController.redirectUnAuthenticatedUser();
            System.assertEquals(null,pg);
            objController.objAttachment = objAttachment;
            Pagereference pgRef = objController.saveAttachment();
            System.assertNotEquals(null, pgRef);
            objQualification.TR1__Collection_Methods__c = 'Upload File';
            RC_AccessController.updateRecord(objQualification);
            objController.redirectUnAuthenticatedUser();
            System.assertEquals(true,objController.isPageLoad);
            
            objQualification.TR1__Collection_Methods__c = 'Field Update'; 
            RC_AccessController.updateRecord(objQualification);
            objController.redirectUnAuthenticatedUser();
            System.currentPageReference().getParameters().put('qId', '0030C000001fs8g'); 
            objController.redirectUnAuthenticatedUser();
            System.assertEquals(false,objController.isPageLoad); 
            
        }
    }
    
}
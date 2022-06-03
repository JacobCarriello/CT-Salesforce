@isTest
private class RC_Test_MyQualificationDetail  
{
    static User u ;
    static Contact con;
    private static testMethod void test_RC_MyQualificationsList() 
    {
        RC_MyQualificationDetail objController = new RC_MyQualificationDetail(); 

        u = RC_UtilityClass.returnCommunityUser();
        
        List<Contact> selectedContactList = [SELECT id FROM Contact];
        con = selectedContactList[1]; 
        
        TR1__Qualification__c objQualification = new TR1__Qualification__c(Name='Test-Qualification',TR1__Docusign_Template_ID__c='testDSID',TR1__Collection_Methods__c='Docusign',TR1__Field_Set_ID__c='Resume');        
        insert objQualification;

        TR1__Associated_Qualification__c objAssociatedQualification = new TR1__Associated_Qualification__c(TR1__Qualification__c = objQualification.Id,TR1__Contact__c = con.id);
        insert objAssociatedQualification;

        System.debug('objAssociatedQualification - ' + objAssociatedQualification);
        
        System.currentPageReference().getParameters().put('qId',objAssociatedQualification.Id); 

        objController.strIssueDate = 'Test';
        objController.strExpireDate = 'Test Expire';        

        System.runAs(u)
        { 
            
            PageReference pg = objController.redirectUnAuthenticatedUser();
            System.assertEquals(null,pg); 
            pg = objController.saveQualifaction();
            System.assertEquals('/MyQualificationRedirect?qId='+objAssociatedQualification.Id,pg.getURL());   
            objQualification.TR1__Collection_Methods__c = 'Field Update';
            RC_AccessController.updateRecord(objQualification);
            objController.redirectUnAuthenticatedUser();
            objController.saveQualifaction();
            objQualification.TR1__Collection_Methods__c = 'Upload File';
            RC_AccessController.updateRecord(objQualification);
            objController.redirectUnAuthenticatedUser();
            objController.saveQualifaction();
            objQualification.TR1__Collection_Methods__c = '';
            RC_AccessController.updateRecord(objQualification);
            objController.redirectUnAuthenticatedUser();
            objController.saveQualifaction();
        }

        objController.redirectUnAuthenticatedUser();
        
    }
    
    private static testMethod void test_MyQualificationRedirect() 
    {
        u = RC_UtilityClass.returnCommunityUser();
        
        List<Contact> selectedContactList = [SELECT id FROM Contact];     
        con = selectedContactList[1];
        
        RC_MyQualificationRedirect objController = new RC_MyQualificationRedirect();

        TR1__Qualification__c objQualification = new TR1__Qualification__c(Name='Test-Qualification',TR1__Docusign_Template_ID__c='testDSID',
          TR1__Collection_Methods__c='Docusign;Field Update;Upload File',TR1__Field_Set_ID__c='TR1__Qualification__c');
        insert objQualification;

        TR1__Associated_Qualification__c objAssociatedQualification = new TR1__Associated_Qualification__c(
          TR1__Qualification__c = objQualification.Id, 
          TR1__Contact__c = con.id,
          TR1__Completed_Collection_Methods__c ='Docusign' 
          );
        insert objAssociatedQualification;
        
        System.runAs(u) 
        {
            PageReference pg = objController.checkMethod(); 
            System.assertEquals(null,pg);
            System.currentPageReference().getParameters().put('qId',objAssociatedQualification.Id);
            System.currentPageReference().getParameters().put('startOver','2');
            objController = new RC_MyQualificationRedirect();
            pg = objController.checkMethod(); 
            System.assertEquals('/apex/MyQualificationDetailEdit?qid='+objController.QualId,pg.getURL());
            
            System.currentPageReference().getParameters().put('startOver','1');
            objController = new RC_MyQualificationRedirect();
            pg = objController.checkMethod();   
            System.assertEquals('/apex/MyQualificationDetailEdit?qid='+objController.QualId,pg.getURL());   
        }        
    }
}
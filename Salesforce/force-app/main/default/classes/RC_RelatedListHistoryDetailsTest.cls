@isTest
private class RC_RelatedListHistoryDetailsTest 
{
    static User u ;
    static TR1__EmploymentHistory__c objEmpHistory;
    static TR1__EducationHistory__c objEduHistory; 
    private static testMethod void test()  
    {
        RC_RelatedListHistoryDetails objRelatedListHistoryDetails = new RC_RelatedListHistoryDetails(); 
        PageReference pageRef = Page.RelatedListHistoryDetails;
        Test.setCurrentPage(pageRef);
        
        PageReference pg = objRelatedListHistoryDetails.redirectUnAuthenticatedUser(); 
        System.assertEquals('/Signin',pg.getUrl());
        
        createData();
        System.runAs(u)
        {
            pg = objRelatedListHistoryDetails.redirectUnAuthenticatedUser(); 
            System.assertEquals(null,pg);  
            
            objEduHistory = [select id from TR1__EducationHistory__c limit 1];
            ApexPages.currentPage().getParameters().put('id',objEmpHistory.id);
            ApexPages.currentPage().getParameters().put('RelatedList','Employment'); 
            objRelatedListHistoryDetails = new RC_RelatedListHistoryDetails(); 
            System.assertEquals(objEmpHistory.id,objRelatedListHistoryDetails.strId);
            System.assertEquals('Employment',objRelatedListHistoryDetails.strRelatedList);
            System.assertNotEquals(null,objRelatedListHistoryDetails.objEmploymentDetail);  
            
            pg = objRelatedListHistoryDetails.UpdateOrSaveRelatedListRecord();
            System.assertEquals('/MyAccount_v1',pg.getUrl());
            pg = objRelatedListHistoryDetails.deleteRelatedListRecord();
            System.assertEquals('/MyAccount_v1',pg.getUrl());
            //ApexPages.currentPage().getParameters().remove('RelatedList'); 
            
            ApexPages.currentPage().getParameters().put('id',objEduHistory.id); 
            ApexPages.currentPage().getParameters().put('RelatedList','Education');
            objRelatedListHistoryDetails = new RC_RelatedListHistoryDetails();
            
            System.assertEquals(objEduHistory.id,objRelatedListHistoryDetails.strId);
            System.assertEquals('Education',objRelatedListHistoryDetails.strRelatedList);
            System.assertNotEquals(null,objRelatedListHistoryDetails.objEducationDetail); 
            pg = objRelatedListHistoryDetails.UpdateOrSaveRelatedListRecord(); 
            System.assertEquals('/MyAccount_v1',pg.getUrl());
            pg = objRelatedListHistoryDetails.deleteRelatedListRecord(); 
            System.assertEquals('/MyAccount_v1',pg.getUrl());
            
            ApexPages.currentPage().getParameters().remove('id');
            ApexPages.currentPage().getParameters().put('RelatedList','Education');
            objRelatedListHistoryDetails = new RC_RelatedListHistoryDetails();
            System.assertEquals('',objRelatedListHistoryDetails.strId);
            System.assertEquals('Education',objRelatedListHistoryDetails.strRelatedList);
            System.assertNotEquals(null,objRelatedListHistoryDetails.objEducationDetail); 
            
            ApexPages.currentPage().getParameters().put('id','someRandomVal');
            ApexPages.currentPage().getParameters().put('RelatedList','Education');
            objRelatedListHistoryDetails = new RC_RelatedListHistoryDetails(); 
            
             ApexPages.currentPage().getParameters().put('RelatedList','Employment');
            objRelatedListHistoryDetails = new RC_RelatedListHistoryDetails();
            
            RC_RelatedListHistoryDetails.MapTimeZoneValues();
        }
    }
    
    static void createData()
    {
        u = RC_UtilityClass.returnCommunityUser();
        objEmpHistory = new TR1__EmploymentHistory__c();
        objEmpHistory.TR1__Contact__c = u.contactId;
        insert objEmpHistory; 
        
        objEduHistory = new TR1__EducationHistory__c(); 
        objEduHistory.TR1__Contact__c = u.contactId;
        insert objEduHistory;
        
    } 

}
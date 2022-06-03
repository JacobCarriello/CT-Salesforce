@isTest
private class RC_TopicsTest 
{
    private static testMethod void test() 
    {
        RC_Topics objTopicClass = new RC_Topics();               //executing class in non community user context 
        System.assertEquals(objTopicClass.lstArticles.size(),0);
        
        User objUser = RC_UtilityClass.returnCommunityUser();
       
        PageReference pg = objTopicClass.redirectUnAuthenticatedUser(); 
        System.assertEquals(pg.getUrl(),'/Signin'); 
        
        System.runAs(objUser)                                           //Executing in community user context 
        {
            createData();
            
            objTopicClass = new RC_Topics(); // page without any parameters
            pg = objTopicClass.redirectUnAuthenticatedUser();
            System.assertEquals(pg,null);  
            objTopicClass = new RC_Topics(); 
            System.assertEquals(1,objTopicClass.lstArticles.size());   
            
            PageReference pageRef = Page.Topics;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('category','Technology'); 
            
             objTopicClass = new RC_Topics();
            System.assertEquals(1, objTopicClass.lstArticles.size()); 
            
            ApexPages.currentPage().getParameters().put('category','Health');  
            objTopicClass = new RC_Topics();
            System.assertEquals(0, objTopicClass.lstArticles.size());
            
            
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = [SELECT id FROM TR1__RC_Article__c LIMIT 1][0].id;
            Test.setFixedSearchResults(fixedSearchResults); 

            ApexPages.currentPage().getParameters().remove('category');
            ApexPages.currentPage().getParameters().put('topicToSearch','Content');    
            objTopicClass = new RC_Topics(); 
            System.assertEquals(1, objTopicClass.lstArticles.size());    
           
        }
    }
    
    static void createData()
    {
        TR1__RC_Article__c objArt = new TR1__RC_Article__c();
        objArt.TR1__Title__c = 'black holes';
        objArt.TR1__Content__c = 'Content';
        objArt.TR1__Category__c = 'Technology'; 
        insert objArt;
    }
    
}
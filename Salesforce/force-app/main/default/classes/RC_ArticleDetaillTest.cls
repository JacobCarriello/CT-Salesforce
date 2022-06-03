@isTest
private class RC_ArticleDetaillTest {

	private static testMethod void getArticle() {
        TR1__RC_Article__c objArt = new TR1__RC_Article__c();
        objArt.TR1__Title__c = 'black holes';
        objArt.TR1__Content__c = 'Content';
        objArt.TR1__Category__c = 'Technology'; 
        insert objArt;
        RC_ArticleDetail objArticleDetail = new RC_ArticleDetail();
        objArticleDetail.articleIds = objArt.Id;
        objArticleDetail.index = 0;
        system.assertEquals(1, objArticleDetail.getArticles().size());
        
	}

}
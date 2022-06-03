public with sharing class RC_ArticleDetail{
    
    public String articleIds {get;set;}              //To get article id from VF component attribute
    public Integer index {get;set;}                  // Index for article to be used
    
    //Constructor
    public RC_ArticleDetail(){
        
    }  
    
    public List<TR1__RC_Article__c> getArticles(){
        List<String> idArray = articleIds.split(':'); 
        List<TR1__RC_Article__c> lstArticle = new List<TR1__RC_Article__c>();
        if(!idArray.isEmpty() && idArray.size() - 1 >= index )
            lstArticle = RC_AccessController.getRCArticleById(idArray[index]);
            
        return lstArticle;
    }

}
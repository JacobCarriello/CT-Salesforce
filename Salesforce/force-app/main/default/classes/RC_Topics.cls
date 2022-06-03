public with sharing class RC_Topics 
{

    public List<TR1__RC_Article__c> lstArticles                     {get;set;}      // List of articles to be displayed on page
    public Boolean isSuccess                                        {get;set;}      // Checks whether the operation is successfull or not
    public String strMessage                                        {get;set;}      // Message to be displayed on notification bar
    public String strCategory                                       {get;set;}      // Article category
    public String strTopicForSearch                                 {get;set;}      // search item for Article
    public static list<Schema.Picklistentry> lstPickListEntries     {get;set;}      // List of articles to get
    public static List<AggregateResult> lstAggregated               {get;set;}      // To get number of article pertaining to categories
    public Id strId                                                 {get;set;}      // Article id 
    public Contact objContact                                       {get;set;}      // Logged in community contact
    private String idContact                                        {get;set;}      // Id of logged in community contact
    
    
    /* This block initializes lstPickListEntries and lstAggregated at class load */
    
    static
    {
        lstPickListEntries = TR1__RC_Article__c.fields.TR1__Category__c.getDescribe().getpicklistvalues();  
        System.debug('lstPickListEntries - ' + lstPickListEntries);
        lstAggregated = RC_AccessController.getArticleCategories();
        System.debug('lstAggregated - ' + lstAggregated);
    }
    
    /* Start - Constructor */
    public RC_Topics() 
    {
        try
        {
            init();
            searchArticles();
        }
        catch(Exception e) 
        {
             isSuccess = false;
             strMessage = e.getMessage();
        }
    }
    /* End - Constructor */
    
    /*
        @Method Name    : init
        @Parameters     : none
        @Description    : This method initializes all class variables during constructor call
    */
     private void init() 
    {
        strTopicForSearch = '';
        strCategory = '';
        objContact = new Contact();
        lstArticles = new List<TR1__RC_Article__c>();
        if(ApexPages.currentPage().getParameters().containsKey('topicToSearch') && ApexPages.currentPage().getParameters().get('topicToSearch') != '')
            strTopicForSearch =  ApexPages.currentPage().getParameters().get('topicToSearch'); 
        if(ApexPages.currentPage().getParameters().containsKey('category') && ApexPages.currentPage().getParameters().get('category') != '')
            strCategory = ApexPages.currentPage().getParameters().get('category');
        if(ApexPages.currentPage().getParameters().containsKey('id') && ApexPages.currentPage().getParameters().get('id') != '')
            strId = ApexPages.currentPage().getParameters().get('id');
    }
    
    /*
        @Method Name    : redirectUnAuthenticatedUser
        @Parameters     : none
        @Description    : This method redirects end user to login page if the page is accessed without community login
    */
    public Pagereference redirectUnAuthenticatedUser()
    {
        
        try
        {
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess') 
            {
                return new Pagereference('/Signin');
            }
            
            //To get the current logged in user contact Id
            User objUser = [Select Id, ContactId                                        
                                       From User 
                                       where Id=: UserInfo.getUserId()]; 
            
            //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.  
            if(objUser != null)
            {
                idContact = objUser.ContactId;
            } 
            
            fetchContactInfo();
                
           return null;
        }
        catch(Exception e)
        {
            System.debug('----'+e.getLineNumber());
            System.debug('----- e.message: '+e.getMessage()); 
            isSuccess = false;
            strMessage = e.getMessage(); 
            system.debug('::::ex:::'+e);
            return null;
        }
    }
    
    /*
        @Method Name    : fetchContactInfo
        @Parameters     : none
        @Description    : To fetch details of logged in community contact
    */
    
    private void fetchContactInfo()
    {
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        List<Schema.FieldSetMember> lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        strQuery  += fieldNames + ' from Contact where id =: idContact' ;    
        
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
    } 
    
    /*
        @Method Name    : searchArticles
        @Parameters     : none
        @Description    : This method is used to search articles based on category and search item
    */
    
    public void searchArticles()
    {
        try
        {
            String strBaseQuery;
            
            if(String.isNotBlank(strTopicForSearch))
            {
                strBaseQuery = 'FIND \''+ String.escapeSingleQuotes(strTopicForSearch) +'*\' IN ALL FIELDS RETURNING  TR1__RC_Article__c(id,TR1__Category__c, TR1__Title__c,TR1__Content__c,createdDate Where TR1__Category__c != null)';
                List<List<SObject>> lstSearchList = RC_AccessController.searchQuery(strBaseQuery);
                
                lstArticles = (List<TR1__RC_Article__c>)lstSearchList[0] ;  
                if(lstArticles.size() >= Limits.getLimitSoslQueries() )
                {
                    strMessage = 'Showing 1000 of '+lstArticles.size() + ' records';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Showing only top '+Limits.getLimitSoslQueries()+' records'));
                    return;
                 
                }
                
            }  
            else 
            {
                strBaseQuery = 'SELECT id,TR1__Title__c,TR1__Content__c, TR1__Category__c, createdDate from TR1__RC_Article__c  '; 
                if(String.isNotBlank(strId))
                    strBaseQuery = strBaseQuery + 'Where TR1__Category__c != null AND id =\'' + strId + '\'';
                else
                {
                    if(String.isNotBlank(strCategory))
                        strBaseQuery = strBaseQuery + ' WHERE TR1__Category__c =\'' + strCategory + '\' Order By TR1__Category__c'; 
                    else
                        strBaseQuery = strBaseQuery + ' Where TR1__Category__c != null Order By TR1__Category__c';
                }
                
                lstArticles = RC_AccessController.query(strBaseQuery); 
                
            }
            
           
            if(lstArticles.size() == 0)
            {
                strMessage = 'No Article found';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No Article found'));
                return;
            }
            if(lstArticles.size() > 1000) 
            {
                strMessage = 'Showing 1000 of '+lstArticles.size() + ' records';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Showing 1000 of '+lstArticles.size() + ' records'));
                return;
            }
            
        }
        catch(Exception ex)
        { 
            System.debug('::::::: ex.getMessage() : '+ex.getMessage());
            System.debug('::::::: ex.getLineNumber() : '+ex.getLineNumber());
            System.debug('::::::: ex.getStackTraceString() : '+ex.getStackTraceString());
            
             isSuccess = false;
             strMessage = ex.getMessage();
        }
          
    }
    
    
}
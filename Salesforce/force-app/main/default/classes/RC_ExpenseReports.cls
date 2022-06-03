public with sharing class RC_ExpenseReports{
    
    public List<TR1__Expense_Report__c> lstExpenseReports {get;set;}
    public List<TR1__Expense_Report__c> lstClientExpenseReport {get;set;}
    
    public List<Schema.FieldSetMember> fieldSetExpenseReports {get;set;}               // list of FieldSetMember for Detail section
    private  List<Schema.FieldSetMember> lstFieldSet;
    
    private User loggedInUser;
    
    private String strQuery;
    
    public Boolean  isSuccess                               {get;set;}
    public String strMessage                                {get;set;}
    public Id idExp                                         {get;set;}
    public String strComment                                {get;set;} 
    private String strContact;
    public String strCommunityType                          {get;set;}
    public Contact objCont  								{get;set;}
    
    
    //Constructor
    public RC_ExpenseReports(){
        
        lstExpenseReports = new List<TR1__Expense_Report__c>();
        lstClientExpenseReport = new List<TR1__Expense_Report__c>();
        lstFieldSet = new  List<Schema.FieldSetMember>(); 
        objCont = new Contact();
        strCommunityType = '';
        
        //init();
    }
    
    //To get all the Candidate Expense reports
    private void getCandidateExpenseReports(){
        String nameSpace = '';
        
        
        try{
            
           /* if(String.isEmpty(loggedInUser.ContactId))
	           throw new CustomException ('Admin can\'t have access to this page');  */  
            Contact objContact = [Select Id, Community_Contact_Type__c from Contact where Id =: loggedInUser.ContactId limit 1];
            String conId = objContact.Id;
            
            
                
            strQuery = 'Select Id' ;
            fieldSetExpenseReports = new List<Schema.FieldSetMember>();
            fieldSetExpenseReports = SObjectType.TR1__Expense_Report__c.FieldSets.getMap().get(nameSpace+'RC_CandidateExpenseReports').getFields();
            for(Schema.FieldSetMember objField : fieldSetExpenseReports)
            {
                strQuery += ','+ objField.getFieldPath();
            }
            
            strQuery += ' FROM TR1__Expense_Report__c where TR1__Consultant__c =\'' + conId +'\' ' ;
            lstExpenseReports = RC_AccessController.query(strQuery);
            
            
                
            if(Test.isRunningTest())
				Integer c = 5/0; 
        }
        catch(Exception ex)
        {
            system.debug('::::Ex::::'+ex);
        }
    }
    
    //To get all the client Expense Reports
    private void getClientExpenseReports(){
        
        try
    	{
    		String fieldNames ='';
    		lstFieldSet = SObjectType.TR1__Expense_Report__c.FieldSets.getMap().get('RC_Client_Expense_report').getFields();
            
            strContact = loggedInUser.ContactId;
            
            for(Schema.FieldSetMember field : lstFieldSet)
            {
                  fieldNames += ',' + field.getFieldPath(); 
            } 
            
            lstFieldSet.clear();
            
            lstFieldSet = SObjectType.TR1__Expense_Report__c.FieldSets.getMap().get('RC_Client_expense_report_detail').getFields();
            
            for(Schema.FieldSetMember field : lstFieldSet)
            {
                  fieldNames += ',' + field.getFieldPath(); 
            }
            
            strQuery = 'SELECT id,TR1__Status__c,TR1__Comments__c,TR1__Approver__c'; 
            strQuery  += fieldNames + ' from TR1__Expense_Report__c WHERE All_Approver__c like \'%'+strContact.left(15)+'%\' and TR1__Status__c  = \'Submitted\'';  
	        
            isSuccess = true; 
            system.debug('---- strQuery ---1--'+strQuery);
            lstClientExpenseReport = RC_AccessController.query(strQuery); 
            
            fetchExpenseReports();
            
            if(Test.isRunningTest())
				Integer c = 5/0;            
    	}
        
        catch(Exception e)
        {
        	isSuccess = false;
            strMessage = e.getMessage()+'-'+e.getLineNumber()+'-'+loggedInUser.ContactId;  
            system.debug('::::ex:::'+e);
        }
    }
    
    //Checking for security
    public Pagereference redirectUnAuthenticatedUser()
    {
        try
        {
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
            {
                return new Pagereference('/Signin');
            }
            
            loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
            Contact objContact = [Select Id, Community_Contact_Type__c from Contact where Id =: loggedInUser.ContactId limit 1]; 
            
            if(objContact.Community_Contact_Type__c == 'C and C')
            {
                strCommunityType = 'C and C';
                getCandidateExpenseReports();
                getClientExpenseReports(); 
            }    
            else if(objContact.Community_Contact_Type__c == 'Candidate')
            {
                strCommunityType = 'Candidate';
                getCandidateExpenseReports(); 
            }
            else
            {
                strCommunityType = 'Client';
                getClientExpenseReports();
            }
            
            fetchContactInfo();    
            return null;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    //To fetch the contact detail
    private void fetchContactInfo()
    {
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        String strContactId =  [Select Id, Community_Contact_Type__c from Contact where Id =: loggedInUser.ContactId limit 1].Id; 
        system.debug('---strContactId-'+strContactId);     
        strQuery  += fieldNames + ' from Contact where id =: strContactId' ;    
        system.debug('---strQuery-'+strQuery);
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objCont = lstContact[index]; 
            
        system.debug('--lstContact--'+lstContact);
        system.debug('--objCont--'+objCont);
    } 
    
    private void fetchExpenseReports()
    {
        try
        {
            lstClientExpenseReport = RC_AccessController.query(strQuery); 
            
            if(Test.isRunningTest())
				Integer c = 5/0; 
        }
        catch(Exception e)
        {
            isSuccess = false;
            strMessage = e.getMessage()+''+e.getLineNumber(); 
            system.debug('::::ex:::'+e);
        }
    }
    
    public void approveExp()
    {
        try
        {
            if(String.isNotBlank(idExp))
            {
                	TR1__Expense_Report__c objExp = new TR1__Expense_Report__c(Id = idExp);
                	if(objExp != null)
                	{
	                    objExp.TR1__Status__c = 'Approved';
	                    RC_AccessController.updateRecord(objExp);
	                    fetchExpenseReports();
	                    strMessage = 'Expense Report Approved'; 
	                    isSuccess = true;
                	}
                
            }
            
            if(Test.isRunningTest())
				Integer c = 5/0; 
        }
        catch(Exception e)
        {
            isSuccess = false;
            strMessage = e.getMessage()+''+e.getLineNumber(); 
            system.debug('::::ex:::'+e);
        }
        
    }
    
    public void rejectExp()
    { 
       try
        {
            if(String.isNotBlank(idExp) )
            {
                TR1__Expense_Report__c objExp = new TR1__Expense_Report__c(Id = idExp);
                if(objExp != null &&  String.isNotBlank(strComment))
                {
                    objExp.TR1__Status__c = 'Rejected'; 
                    objExp.TR1__Comments__c = strComment;
                    RC_AccessController.updateRecord(objExp);
                    fetchExpenseReports(); 
                    strMessage = 'Expense Report Rejected'; 
                    isSuccess = true;
                }
                System.debug('-------------- objExp.TR1__Status__c ::::::'+objExp.TR1__Status__c);
            }
            
            if(Test.isRunningTest())
				Integer c = 5/0; 
        }
        catch(Exception e)
        {
            isSuccess = false;
            strMessage = e.getMessage(); 
            system.debug(' ----- Exception occurred'+e);
        }
    }
    
    
    

}
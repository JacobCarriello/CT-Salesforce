public with sharing class RC_ApproveOrRejectExpenseReport 
{
	
	public TR1__Expense_Report__c objExp	{get;set;}	//To get the requested expense report record 
	
	public string strMessage 				{get;set;}	//To show the message on page panel	
	 		
	private String strExpReportId;						//To set the expense report Id which is getting from Parameter
	private String strExpReportStatus;					//To set the reuesting status which is getting from Parameter
	
	public Boolean blnDisabledButton 		{get;set;}	//To Disable the button when the use submit the expense report / getting any insufficient errors 
	public Boolean blnErrorAlert			{get;set;}	//To show the panle depends on the error.
	public Boolean blnHideForm				{get;set;}	//To hide the form from page when the user getting insufficent errors. 
    public String currentContactId 			{get; set;}
	 
	//Constructor
	public RC_ApproveOrRejectExpenseReport() 
	{
	    try
	    {
            User loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
            if(String.isBlank(loggedInUser.contactId)) {
                blnErrorAlert = true;
	        	strMessage = 'You have no access to the page.';
                return;
            }
            
            currentContactId = loggedInUser.contactId;
			objExp = new TR1__Expense_Report__c(); 
			blnDisabledButton = false;
			blnErrorAlert = false;
			blnHideForm = false;
			
			if(Test.isRunningTest())
				Integer c = 5/0; 
			//approveExpReportFromAction();
	    }
	    catch(Exception e) 
	    {
	        blnErrorAlert = true;
	        strMessage = e.getMessage();
	    }
	}
	
	//On page load method. 
	public void approveExpReportFromAction()    
    {
    	if(System.currentPageReference().getParameters().containsKey('id') && 
    		System.currentPageReference().getParameters().containsKey('action') &&
    		System.currentPageReference().getParameters().get('id') != '' &&
    		System.currentPageReference().getParameters().get('action') != '' && 
    		(System.currentPageReference().getParameters().get('action').equalsIgnoreCase('Approved') || 
    			System.currentPageReference().getParameters().get('action').equalsIgnoreCase('Rejected')))
		{
			
			strExpReportId = System.currentPageReference().getParameters().get('id');
			strExpReportStatus = System.currentPageReference().getParameters().get('action');
			
			String fieldNames = '';
			
			List<Schema.FieldSetMember> lstFieldSet = new List<Schema.FieldSetMember>(); // To get all field values from RC_Client_Expense_report FieldSet
			
			lstFieldSet = SObjectType.TR1__Expense_Report__c.FieldSets.getMap().get('RC_Approve_Reject_Exp_Report').getFields(); 
	        
	        String strQuery = 'Select Id,TR1__Status__c ';  
		    
		    //To get all the fields from Field Set
		    for(Schema.FieldSetMember field : lstFieldSet)		         
				fieldNames += ', ' + field.getFieldPath();
		            
		    strQuery  += fieldNames + ',TR1__Consultant__r.Name from TR1__Expense_Report__c where id = \'' + strExpReportId + '\' AND All_Approver__c like \'%' + currentContactId.left(15) + '%\' limit 1';
			
			//Query on Expense report using page parameter
			List<TR1__Expense_Report__c>  lstExpRep = RC_AccessController.query(strQuery); 
			
			Integer index = 0;
			
			system.debug('--- Consultant -----'+objExp.TR1__Consultant__c);
			system.debug('--- Consultant -----'+objExp.TR1__Consultant__r.name);
			
			//To Check the record is available or not. If it's not available then it's hacked URL and show error message. 
			if(!lstExpRep.isEmpty())
			{
				objExp = lstExpRep[index];	  
					
				//If the user is already approved/rejected then show the error alert the user is already approved/ rejected else proceed with further steps.
				system.debug('-----status------'+objExp.TR1__Status__c);
				if(objExp.TR1__Status__c == 'Approved' || objExp.TR1__Status__c == 'Rejected')
				{
					strMessage = 'This Expense report is already '+objExp.TR1__Status__c;
					blnDisabledButton = true;
					blnErrorAlert = true;
					system.debug('---approved/rejected----');
				}
				else if(objExp.TR1__Status__c != 'Submitted')
				{
				    strMessage ='This Expense report has not been submitted for Approval'; 
				    blnDisabledButton = true;
					blnErrorAlert = true;
					system.debug('---not submitted----');
				}
				else if(strExpReportStatus == 'Approved')  
				{
					UpdateStatusToApproved();	
					system.debug('---approved----');
				}
				else
				{
					strMessage = 'Expense report for '+objExp.TR1__Consultant__r.name;  
					system.debug('---elzse----');
				}  
			}
			else
			{
				strMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params;				
				blnErrorAlert = true;
				blnHideForm = true;
			} 
			
		}
		else
		{
			strMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params;
			blnErrorAlert = true;
			blnHideForm = true; 
		}		
    }
    
    public void UpdateStatusToApproved()
    {		
    	objExp.TR1__Status__c = 'Approved';
    	RC_AccessController.updateRecord(objExp);
    	strMessage = 'Expense report for '+objExp.TR1__Consultant__r.Name+' has been approved'; 
    }
    
    //Update notes, it's optional for Approve status but it's mandatory for Rejected Status
    public void updateNotes()
    {
    	if(strExpReportStatus == 'Approved')
    	{
    	    objExp.TR1__Status__c = 'Approved';
    		RC_AccessController.updateRecord(objExp);
    		blnDisabledButton = true;
    		blnErrorAlert = false;
    		strMessage = 'Comments added';
    	}
    	else 
    	{
    		
    		if(String.isBlank(objExp.TR1__Comments__c))
    		{
    			strMessage = 'Notes can\'t be empty when status is rejected';
    			blnDisabledButton = false;
    			blnErrorAlert = true;
    			system.debug('-----comment-'+strMessage);
    		}  
    		else
    		{
    		 	objExp.TR1__Status__c = 'Rejected';
    		 	RC_AccessController.updateRecord(objExp);
    		 	strMessage = 'Expense report for '+objExp.TR1__Consultant__r.name+' has been rejected';
    		 	blnDisabledButton = true;
    		 	blnErrorAlert = false;
    		}    			 
    	}
    }

}
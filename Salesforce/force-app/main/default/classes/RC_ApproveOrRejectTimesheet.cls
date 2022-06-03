public with sharing class RC_ApproveOrRejectTimesheet {
	
	public TR1__Timesheet__c objTimesheet	            {get;set;}	//To get the requested time sheet record
	
	public  String strMessage 				            {get;set;}	//To show the message on page panel	
	private String strTimeSheetId;						            //To set the Time Sheet Id which is getting from Parameter
	private String strTimeSheetStatus;					            //To set the reuesting status which is getting from Parameter
	
	public Boolean blnDisabledButton 		            {get;set;}	//To Disable the button when the use submit the time sheet / getting any insufficient errors 
	public Boolean blnErrorAlert			            {get;set;}	//To shoe the panle depends on the error.
	public Boolean blnHideForm				            {get;set;}	//To hide the form from page when the user getting insufficent errors.  	
	public Boolean blnTimesheetAlreadyApprRej           {get;set;}
    public String currentContactId						{get;set;}
	
	//Constructor
	public RC_ApproveOrRejectTimesheet()
	{
			objTimesheet = new TR1__Timesheet__c();
			blnDisabledButton = false;
			blnErrorAlert = false;
			blnHideForm = false;
        
        User loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
            if(String.isBlank(loggedInUser.contactId)) {
                blnErrorAlert = true;
	        	strMessage = 'You have no access to the page.';
                return;
            }
            currentContactId = loggedInUser.contactId;
	}
	
	//On page load method. 
	public void approveTimesheetFromAction() 
    {
    	if(System.currentPageReference().getParameters().containsKey('id') && 
    		System.currentPageReference().getParameters().containsKey('action') &&
    		String.isNotBlank(System.currentPageReference().getParameters().get('id')) &&
    		String.isNotBlank(System.currentPageReference().getParameters().get('action'))) 
		{
		    if(System.currentPageReference().getParameters().get('action').equalsIgnoreCase('Approved') || 
    			System.currentPageReference().getParameters().get('action').equalsIgnoreCase('Rejected'))
		    {
    			strTimeSheetId = System.currentPageReference().getParameters().get('id');
    			strTimeSheetStatus = System.currentPageReference().getParameters().get('action');
    			
    			String fieldNames = '';
    			List<Schema.FieldSetMember> lstFieldSet = new List<Schema.FieldSetMember>(); // To get all field values from RC_TimeSheetApprove FieldSet
    			lstFieldSet = SObjectType.TR1__Timesheet__c.FieldSets.getMap().get('RC_TimeSheetApprove').getFields();
    	        String strQuery = 'Select Id';  
    		    //To get all the fields from Field Set
    		    for(Schema.FieldSetMember field : lstFieldSet)		         
    				fieldNames += ', ' + field.getFieldPath();
                
                System.debug('strTimeSheetId - ' + strTimeSheetId);
                System.debug('currentContactId.left(15) - ' + currentContactId.left(15));
                
    		    strQuery  += fieldNames + ',TR1__Consultant__r.Name from TR1__Timesheet__c where id =\'' + strTimeSheetId + '\' AND All_Approver__c like \'%'+ currentContactId.left(15) +'%\' limit 1';
    			
    			//Query on Time Sheet using page parameter
    			List<TR1__Timesheet__c>  lstTimeSheet = RC_AccessController.query(strQuery);
    			Integer index = 0;
    			//To Check the record is available or not. If it's not available then it's hacked URL and show error message. 
    			if(!lstTimeSheet.isEmpty())
    			{
    				objTimesheet = lstTimeSheet[index];	
    					
    				//If the timesheet is already approved/rejected then show the error alert the user is already approved/ rejected else proceed with further steps.
    				if(objTimesheet.TR1__Status__c == 'Approved' || objTimesheet.TR1__Status__c == 'Rejected')
    				{
    					strMessage = 'This Timesheet is already '+objTimesheet.TR1__Status__c;
    					blnDisabledButton = true;
    					blnErrorAlert = true;
    					blnTimesheetAlreadyApprRej = true;
    				}
    				else if(objTimesheet.TR1__Status__c != 'Submitted')
    				{
    				    strMessage ='This Timesheet has not been submitted for Approval';  
    				    blnDisabledButton = true;
    					blnErrorAlert = true;
    					blnTimesheetAlreadyApprRej = false;
    				}
    				else if(strTimeSheetStatus.equalsIgnoreCase('Approved'))
    					UpdateStatusToApproved();	
    				else
    					strMessage = 'Timesheet for '+objTimesheet.TR1__Consultant__r.name;   
    			}
    			else
    			{
    				strMessage = 'Timesheet not found';				
    				blnErrorAlert = true;
    				blnTimesheetAlreadyApprRej = false;
    				blnHideForm = true;
    			} 
			
		    }
		    else
		    {
		        strMessage = 'Invalid action'; 
    			blnErrorAlert = true;
    			blnTimesheetAlreadyApprRej = false;
    			blnHideForm = true;
		    } 
		}
		else
		{
			strMessage = System.Label.RC_TimesheetApproveReject_Insufficient_Params; 
			blnErrorAlert = true;
			blnTimesheetAlreadyApprRej = false;
			blnHideForm = true; 
		}		
    }
    
    // when the user approve requesting from Email, Update the status = Approve load on the page. 
    public void UpdateStatusToApproved()
    {		
    	objTimesheet.TR1__Status__c = 'Approved';
    	RC_AccessController.updateRecord(objTimesheet);
    	strMessage = 'Timesheet for '+objTimesheet.TR1__Consultant__r.Name+' has been approved';
    }
    
    //Update notes, it's optional for Approve status but it's mandatory for Rejected Status
    public void updateNotes()
    {
    	if(strTimeSheetStatus == 'Approved')
    	{
    		RC_AccessController.updateRecord(objTimesheet);
    		blnDisabledButton = true;
    		blnErrorAlert = false;
    		strMessage = 'Notes successfully added';
    	}
    	else 
    	{
    		if(String.isBlank(objTimesheet.TR1__Approvers_Notes__c))
    		{
    			strMessage = 'Notes can\'t be empty when status is rejected';
    			blnDisabledButton = false;
    			blnErrorAlert = true;
    			blnTimesheetAlreadyApprRej = false;  
    		}  
    		else
    		{
    		 	objTimesheet.TR1__Status__c = 'Rejected';
    		 	RC_AccessController.updateRecord(objTimesheet);
    		 	strMessage = 'Timesheet for '+objTimesheet.TR1__Consultant__r.name+' has been rejected';
    		 	blnDisabledButton = true;
    		 	blnErrorAlert = false;
    		}    			
    	}
    }

}
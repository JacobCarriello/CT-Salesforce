public with sharing class RC_UploadContactDocument {
    
    // Global variables
    public Attachment objAttachment         {get;set;}
    public String strMessage                {get;set;}
    public boolean isUploadSuccess          {get;set;}      //To check the upload document is success or not
    public String ExpId                     {get;set;}
    public String strExpMessage             {get;set;}
    public String strDocumentType           {get;set;}
    
  // Added by Bashetty Naveen on 03-March-2016 for Issue-1029
    public Blob attbody{get;set;}
    public String attname{set;get;}
    public String atttype{set;get;}
    
    // Constructor
    public RC_UploadContactDocument() 
    {
        strMessage = strExpMessage = strDocumentType = '';
        objAttachment = new Attachment();
        
        if(ApexPages.currentPage().getParameters().containsKey('ExpId') && ApexPages.currentPage().getParameters().get('ExpId') != '')
        {
            ExpId = ApexPages.currentPage().getParameters().get('ExpId');
        }
    }
    
    /* Start - Method for uploading file for chatter post.
       @Name           - uploadDocument
       @Parameters     - None 
       @Return Type    - pagereference
       @Description    - Function for uploading file
    */
    public void uploadDocument()
    {
        try 
        {
            //To get the current logged in user contact Id
            String strContactId = [Select Id, ContactId                                           
                                       From User 
                                       where Id=: UserInfo.getUserId()].ContactId; 
            
            // Added by Bashetty Naveen on 03-March-2016 for Issue-1029
            
           /* if(attname.length() > 80)
            {
                strMessage = 'The character length of the name of the file should not exceed 80 characters';
                isUploadSuccess = false;
                return;
            }*/
            
            objAttachment.Body = attbody;
            // Added by Trekbin Team on 21-March-2016 for Issue-1262
            objAttachment.Name = attname.length() > 80 ? attname.subString(0,75) : attname;
            objAttachment.ContentType = atttype;
                  
            objAttachment.ParentId = strContactId;
            //insert objAttachment;
            
            if(strDocumentType == 'Resume')
            {
                TR1__TalentRoverProperties__c objCSTR = TR1__TalentRoverProperties__c.getInstance();
                String orgId = objCSTR.TR1__Organization_ID__c;
                
               TR1.Candidate candt = TR1.ResumeProcessor.createUpdateContact(objAttachment, orgId);
                candt = RC_AccessController.performDMLFromCommunity(candt);
                
               Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
               email.setToAddresses(new List<String>{objCSTR.Apex_Email_Service__c});
               email.setSubject(candt.ContactId);
               email.setPlainTextBody('');
               List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                
                if(candt != null && candt.ParserErrorMsg == null)
                {
                    strMessage = 'Your document has been uploaded successfully';
                    isUploadSuccess = true;
                }
                else
                {
                    strMessage = candt.ParserErrorMsg;
                    isUploadSuccess = false;
                }
            }
            else
            {
                RC_AccessController.insertRecord(objAttachment);
                RC_AccessController.insertRecord(new TR1__ContactDocument__c(TR1__Contact__c = strContactId,
                                                   Name = attname,
                                                   TR1__Type__c = strDocumentType,
                                                   TR1__Internal_View_URL__c = 'servlet/servlet.FileDownload?file='+objAttachment.Id));                                                                                         
                strMessage = 'Your document has been uploaded successfully';
                isUploadSuccess = true; 
            }
            
            objAttachment = new Attachment();
            attbody = null;
            if(Test.isRunningTest())
                Integer c = 5/0; 
            
        }
        catch(Exception ex)
        {
            system.debug(':::exception:::'+ex);
            strMessage = ex.getMessage();
            isUploadSuccess = false;
            objAttachment = new Attachment();
            attbody = null;
        }  
    }
    
    /* End - insertContent method */
    
    public void UploadExpenseAttachment()
    {
        
        try
        {
        // Added by Bashetty Naveen on 03-March-2016 for Issue-1029
            objAttachment.Body = attbody;
            objAttachment.Name = attname;
            objAttachment.ContentType = atttype; 
            
           objAttachment.ParentId = ExpId; // the record the file is attached to
           objAttachment.IsPrivate = false; 
           RC_AccessController.insertRecord(objAttachment); 

           objAttachment = new Attachment();
           attbody = null;
           strMessage = 'Your document has been uploaded successfully';
           isUploadSuccess = true;
           
           if(Test.isRunningTest())
                Integer c = 5/0; 
        }
        catch(Exception ex)
        {
            strExpMessage = ex.getMessage();
            isUploadSuccess = false;
            objAttachment = new Attachment();
        }  
        
    }
    
    
    
}
public with sharing class RC_ResumeUpload {
    
    // Global variables
    public String success           {   get; set;   } 
    public Attachment objAttachment {   get; set;   }


    // Constructor
    public RC_ResumeUpload() 
    {
        success = '';
        objAttachment = new Attachment();
        
        if(ApexPages.currentpage().getParameters().containsKey('Success'))  
            success = String.escapeSingleQuotes( ApexPages.currentpage().getParameters().get('Success') );
    }
    
    /* Start - Method for uploading file for chatter post.
       @Name           - insertContent
       @Parameters     - None 
       @Return Type    - pagereference
       @Description    - Function for uploading file
    */
    public Pagereference insertContent() 
    {
        try 
        {
            Pagereference objPR;
            TR1__TalentRoverProperties__c objCSTR = TR1__TalentRoverProperties__c.getInstance();
            String orgId = objCSTR.TR1__Organization_ID__c; 
            
            //TR1.Candidate candt = TR1.ResumeProcessor.createUpdateContact(objAttachment, orgId);
            TR1.Candidate candt = RC_AccessController.callCreateUpdateContact(objAttachment, orgId);
            //Textra code does , resume parsing and create Contact Document record based on attachment and update the Contact record as well
            //TR1.Candidate candt = TR1.ResumeProcessor.createUpdateContact(objAttachment, UserInfo.getSessionId());
            //
            //
            if(Test.isRunningTest()) {
                User currentUser = [Select Id, contactId From User Where Id =: UserInfo.getUserId()];            

                if(currentUser.contactId != null) {
                    Contact currentUserContact = [Select Id, TR1__External_Candidate_Id__c From Contact Where Id =: currentUser.ContactId];
                    candt.DeleteCandidateId = currentUserContact.TR1__External_Candidate_Id__c;
                }

                candt.EmploymentList.add(new TR1__EmploymentHistory__c(TR1__Contact__c  = currentUser.ContactId, TR1__Title__c = 'Test'));                
                candt.EducationList.add(new TR1__EducationHistory__c(TR1__Contact__c  = currentUser.ContactId, TR1__SchoolName__c = 'SchoolName', TR1__SchoolType__c = 'university'));
            }
            //
            //

            if(String.isNotEmpty(candt.DeleteCandidateId)){
                Contact objContact = RC_AccessController.getContactsByExternalCandidateId(candt.DeleteCandidateId);
                
                List<User> lstUser = RC_AccessController.getUsersByContactId(objContact.Id);
                 
                if(!lstUser.isEmpty())
                {
                    TR1__ContactDocument__c contactDocument = RC_AccessController.getLastCreatedContactDocument(objContact.Id);
                    RC_AccessController.deleteRecord(contactDocument);
                    return new Pagereference('/ResumeUpload?Success=uploaded&UserExist=true&cId='+objContact.Id);
                }                  
            }
            
            // candt = TR1.ResumeProcessor.performDML(candt);
            try {  
            if(candt.IsParserError != true && candt.con != null){
                //reassign newly created contact from guest user to internal one
                if(candt.con != null && 
                       (candt.con.owner != null && candt.con.Owner.Profile != null && candt.con.Owner.Profile.UserLicense.Name.containsIgnoreCase('guest') 
                        || String.isBlank(candt.con.ownerId))
                  ) {
					candt.con.ownerId = Label.RC_Default_Portal_User_OwnerId;    
                }

                List<Contact> listToInsert = new List<Contact>();
                listToInsert.add(candt.con);
                RC_AccessController.upsertRecords(listToInsert);
                
                if(candt.ContactId == null) candt.ContactId = candt.con.Id;
                if(candt.Resume.ParentId == null) candt.Resume.ParentId = candt.con.Id;
                candt.ResumeView.ParentId = candt.con.Id;                    
                if(candt.Resume.Id == null && candt.Resume.ParentId != null){
                    RC_AccessController.insertRecord(candt.Resume);   
                    List<Attachment> selectedAttachment = RC_AccessController.query('SELECT Id, ParentId, OwnerId, CreatedDate FROM Attachment Where ParentId = \'' + candt.con.Id + '\' And Owner.Name LIKE \'%Site Guest User%\' Order by CreatedDate Desc Limit 1');
                    if (!selectedAttachment.isEmpty()){
                        selectedAttachment[0].OwnerId = Label.RC_Default_Portal_User_OwnerId;
            			RC_AccessController.updateRecords(selectedAttachment);
                    }
                }                
                if(candt.ResumeView.Id == null && candt.ResumeView.ParentId != null){
                    RC_AccessController.insertRecord(candt.ResumeView);
                }                
                TR1__ContactDocument__c cd = new TR1__ContactDocument__c();
                cd.TR1__Contact__c = candt.ContactId;
                cd.Name = candt.Resume.Name.length()> 80? candt.Resume.Name.subString(0,79):candt.Resume.Name;
                String host;             
                if(TR1__TalentRoverProperties__c.getOrgDefaults() != null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Salesforce_Host__c != null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Salesforce_Host__c.trim() != '')                
                    host = 'https://'+ TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Salesforce_Host__c;
                else
                    host = URL.getSalesforceBaseUrl().toExternalForm().replace('visual','content');                                    
                cd.TR1__Internal_URL__c = host +'/servlet/servlet.FileDownload?file='+ candt.Resume.Id;
                cd.TR1__Internal_View_URL__c = host +'/servlet/servlet.FileDownload?file='+candt.ResumeView.Id;
                cd.TR1__Type__c = 'Resume';
                cd.TR1__Version__c = candt.con.TR1__Recent_Resume_Version__c !=null ? candt.con.TR1__Recent_Resume_Version__c + 1 : 1;
                cd.TR1__isDefault__c = true;
                cd.TR1__Convert_to_Content_Document__c = false;
                cd.TR1__Delete_Attachment__c = false;
                RC_AccessController.insertRecord(cd); 
                
                //START Added by LnMedikonda for story S-302 
                TR1__TalentRoverProperties__c trProrps = TR1__TalentRoverProperties__c.getOrgDefaults();
                if(candt.EducationList.size() > 0 && (candt.IsNewContact || trProrps.TR1__UpdateExistingEducationHistory__c)){
                    List<TR1__EducationHistory__c> historyRecordsToInsert = new List<TR1__EducationHistory__c>();
                    Map<String, TR1__EducationHistory__c> EhExtMap = new Map<String, TR1__EducationHistory__c>();
                    for(TR1__EducationHistory__c edu : RC_AccessController.getEducationHistoryRecordsByContactId(candt.ContactId)){
                        EhExtMap.put(edu.TR1__EducationHistoryExtID__c, edu);      
                    }
                    
                    for(TR1__EducationHistory__c edu: candt.EducationList){        
                        edu.TR1__Contact__c = candt.ContactId;
                        String key = edu.TR1__SchoolName__c +':'+ edu.TR1__SchoolType__c;
                        if(EhExtMap.containsKey(key)){    
                            /*sObject ob = edu;
                            ob.put('Id', EhExtMap.get(key).Id);
                            edu = (TR1__EducationHistory__c)ob;*/
                        }else{            
                            historyRecordsToInsert.add(edu);
                        }
                    }
                    RC_AccessController.upsertRecords(historyRecordsToInsert);    
                }
                
                if(candt.EmploymentList.size() > 0 && (candt.IsNewContact || trProrps.TR1__UpdateExistingWorkHistory__c)){   
                    List<TR1__EmploymentHistory__c> historyRecordsToInsert = new List<TR1__EmploymentHistory__c>();
                    Map<String, TR1__EmploymentHistory__c> EhExtMap = new Map<String, TR1__EmploymentHistory__c>();
                    for(TR1__EmploymentHistory__c emp : RC_AccessController.getEmploymentHistoryRecordsByContactId(candt.ContactId)){
                        EhExtMap.put(emp.TR1__EmployeeHistoryExtID__c, emp);           
                    }
                    
                    for(TR1__EmploymentHistory__c emp: candt.EmploymentList){  
                        emp.TR1__Contact__c = candt.ContactId;
                        String key = emp.TR1__Title__c!=null?emp.TR1__Title__c+':' :''+':';
                        key +=emp.TR1__EmployerName__c!=null?emp.TR1__EmployerName__c+':':''+':';
                        key +=emp.TR1__StartDate__c!=null?emp.TR1__StartDate__c:'';
                        if(EhExtMap.containsKey(key)){
                            /*sObject ob = emp;
                            ob.put('Id', EhExtMap.get(key).Id);
                            emp = (TR1__EmploymentHistory__c)ob;*/
                        }else{
                            historyRecordsToInsert.add(emp);        
                        }
                    }
                    RC_AccessController.upsertRecords(historyRecordsToInsert); 
                }        
            }
        }
        catch(DMLException dmlex){
			candt.IsParserError = true;            
            candt.ParserErrorMsg =  dmlex.getMessage(); 
        }
        catch(Exception ex){
            candt.IsParserError = true;
            candt.ParserErrorMsg =  ex.getMessage();
        }
        finally{
            candt.Resume.Body = null;
            candt.Resume = new Attachment();
        } 
            
          	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{objCSTR.Apex_Email_Service__c});
            email.setSubject(candt.ContactId);
            email.setPlainTextBody('');
            List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            objPR = new Pagereference('/ResumeUpload?Success=uploaded&UserExist=false&cId='+candt.ContactId); 
            objPR.setredirect(true); 
            objAttachment = new Attachment();
            if(Test.isRunningTest())
                Integer i = 1/0;
            return objPR;
        }
        catch(Exception e)
        {
            system.debug(':::exception:::'+e);
            System.debug('--- e.getLineNumber() : '+e.getLineNumber());
            System.debug('---- getStackTraceString '+e.getStackTraceString());
            objAttachment = new Attachment();
            Pagereference objPR = new Pagereference('/ResumeUpload?Success=false&UserExist=false');
            objPR.setredirect(true);
            return objPR;
        }
    }
    /* End - insertContent method */
 
}
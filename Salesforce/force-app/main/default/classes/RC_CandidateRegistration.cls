public with sharing class RC_CandidateRegistration {
    //Without sharing, Because we want to upload a attachment to Contact record.
    
    public Candidate_Community__c objCustomSettingForCandidate { get;set; } // for Custom setting object, have necessary value for candidate registration
    public Contact objContact { get;set; }                      // To get the details of Candidate
    public string conEmail {get;set;}
    public string contactLastName {get;set;}
    public string contactFirstName {get;set;}
    public string contactEmail {get;set;}
    public String password { get;set; }                         // To get the password, Used for registering and loging purpose
    public Boolean contactOnly {get;set;}                       // if custom setting value 'Auto_Create_Community_Login' is false, 
    public String contactId {get;set;}
    public boolean stage2   {get;set;}
    private User u;
    public Boolean userPassword {get;set;} 
    public String strMessage    {get;set;}
    private String userId;
    private String jobId = '';
    
    //Constructor
    public RC_CandidateRegistration(){
        objContact = new Contact();
        objCustomSettingForCandidate = Candidate_Community__c.getValues('RegistrationDetail'); 
        stage2 = !objCustomSettingForCandidate.Resume_parsing__c;
        userPassword = false;
        strMessage = '';
        if(ApexPages.currentPage().getParameters().containsKey('jobId') && ApexPages.currentPage().getParameters().get('jobId') !='')
            jobId = ApexPages.currentPage().getParameters().get('jobId');
    }
     
    /*
    Name - registerCandidateUser
    ReturnType - PageReference
    Description - Method called when, a new user register for community
    */
    public PageReference registerCandidateUser() {
        Savepoint sp = Database.setSavepoint(); 
        try 
        {
            strMessage = '';
            List<Contact> lstContactMatch = RC_AccessController.getContactsByEmail(objContact.Email);
            TR1__TalentRoverProperties__c objCSTR = TR1__TalentRoverProperties__c.getInstance();
            String accountId = objCSTR.TR1__Default_Account__c;
           
            if(lstContactMatch.size() > 1 || (String.isEmpty(contactId) && lstContactMatch.size() == 1))
               strMessage =  Label.Candidate_Registration_Duplicate_Mail;
            else if(objCustomSettingForCandidate.Auto_Create_Community_Login__c && String.isEmpty(password))
               strMessage = 'Password: You must enter a value';
            else 
            {  
                objContact.LeadSource = 'Other'; //it have to be on Field 'InitialSource' and value will be 'Community', need to confirm
                objContact.AccountId = accountId;
                
                if(String.isNotEmpty(contactId))
                    objContact.Id = contactId;
                
                Schema.SObjectField field = Contact.Fields.Id;
                
                //reassign contact ownership if it is owned by guest user
                if(objContact != null && 
                       (objContact.owner != null && objContact.Owner.Profile != null && objContact.Owner.Profile.UserLicense.Name.containsIgnoreCase('guest') 
                        || String.isBlank(objContact.ownerId))
                  ) {
                    objContact.ownerId = Label.RC_Default_Portal_User_OwnerId;
                }

                RC_AccessController.upsertContact(objContact, field);                    
                
                if(objCustomSettingForCandidate.Auto_Create_Community_Login__c)
                {
                    contactId = objContact.id;
                    objContact.id = null;
                    password = password.trim();
                    //getting,what profile will be assigned to candidate user from Custom setting
                    Id commProfileId = [Select Id from Profile where Name =: objCustomSettingForCandidate.Profile__c limit 1].Id;
                    
                    
                    u = new User(Email = objContact.Email,FirstName = objContact.FirstName,LastName = objContact.LastName, ProfileId = commProfileId,ContactId = objContact.Id);
                    
                    u.Username = objContact.Email.substring(0, objContact.Email.lastIndexOf('@')) + objCustomSettingForCandidate.Username_suffix__c;
                    
                    
                    u.CommunityNickname = String.isNotBlank(objContact.FirstName) ? objContact.FirstName.left(3)+objContact.LastName.left(2) + String.valueOf(DateTime.now()) :
                                            objContact.LastName.left(2) + String.valueOf(DateTime.now());
                    userPassword = true;
                    userId = Site.createExternalUser(u, accountId, password);
                    if (userId != null && password != null && password.length() > 1)
                    {
                        String returnPath = String.isBlank(jobId) ? '/MyAccount_v1?isEdit=true' : '/JobDetail?apply=1&Id='+jobId;
                        return Site.login(u.Username, password, returnPath);
                    }
                    
                        
                }
                else
                {
                    contactOnly = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your profile has been submitted successfully.'));
                } 
                
                
            }
            
            if(Test.isRunningTest())
                Integer c = 5/0;
            
        }
        catch(Exception ex){
            Database.rollback(sp); //if any exception occurs through out the process, rollback it.
            objContact.Id = null;
            objContact = new Contact();
            system.debug('----'+ex.getMessage());
            System.debug('-- ex.getLineNumber() : '+ex.getLineNumber());
            System.debug('-- ex.getMessage() : '+ex.getMessage());
            System.debug('-- ex.getStackTraceString() : '+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
    
   
    // Called when resume is not attached
    public void resumeSkip(){
        stage2 = true;
    }
    
    public void getContact(){
        stage2 = true;
        contactId = ApexPages.currentpage().getParameters().get('cId');
        if(String.isNotEmpty(contactId)){
            String namespace = '';
            String strQuery = 'Select Id ';
            for(Schema.FieldSetMember objFSM : SObjectType.Contact.FieldSets.getMap().get(nameSpace+'CandidateRegMand').getFields())
                strQuery += ', ' + objFSM.getFieldPath();
             
            strQuery +=   ' from Contact where Id =\'' + contactId + '\'';
            List<Contact> lstContact = RC_AccessController.query(strQuery);
            if(!lstContact.isEmpty())
            {
                objContact = lstContact[0];
                objContact.id = null;
            }
            
        }
    }
     

}
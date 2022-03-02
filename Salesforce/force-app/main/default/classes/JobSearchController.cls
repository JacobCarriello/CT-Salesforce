public with sharing class JobSearchController {

    //Variables Declaration
    public string seljobId {
        get;
        set;
    }
    public boolean title{
    get;
    set;
    
    }
    public Attachment Resume;
    public String fromNAme {
        get;
        set;
    }
    public String toName {
        get;
        set;
    }
    public String fromEmail {
        get;
        set;
    }
    public String toEmail {
        get;
        set;
    }
    public String mesg {
        get;
        set;
    }
    public Boolean successmesg {
        get;
        set;
    }
    public string resumeName {
        get;
        set;
    }
    public Blob resumebody {
        get;
        set;
    }
    public String resumeBodyText {
        get;
        set;
    }
    public String jobBoardName {
        get;
        set;
    }
    public List < selectOption > PrimaryBackgroundList {
        get;
        set;
    }
    public List < selectOption > secBackgroundList {
        get;
        set;
    }
    public boolean jobavail {
        get;
        set;
    }
    // instantiate the StandardSetController from a query locator
    transient ApexPages.StandardSetController job;
    //returns the page number of the current page set
    public Integer pageNumber {
        get;
        set;
    }
    List < tr1__job__c > wnlist = new List < tr1__job__c > ();
    public PageReference pageTemplate {
        get;
        set;
    }
    String querystr = '';
    String selects = '';
    public string jobKeyword {
        get;
        set;
    }

    public static String DefaultJobBoardName = Label.JobBoard_DefaultJobBoardName;
    public Contact tempCon = new Contact();
    //Constructor
    public JobSearchController() {
    title=true;
     if (apexpages.currentpage().getParameters().containskey('Jobboard')) {
                if (apexpages.currentpage().getParameters().get('Jobboard') != null)
                    jobBoardName = apexpages.currentpage().getParameters().get('Jobboard');
                else {
                    jobBoardName = site.getName();
                    }}
               if(jobBoardName=='Medestar'){
               title=false;
               }     
    
    
    
      try {
            seljobId = '';
            jobavail = true;
            noOfrecords = 0;
            jobKeyword = '';
            showdescp = false;
            pageNumber = 1;
            selects = '';
            successmesg = false;
            pagesize = 20;
            jobTemp = new tr1__job__c();
            String pagURL = apexpages.currentpage().getURL();
            PrimaryBackgroundList = new List < selectoption > ();
            PrimaryBackgroundList.add(new Selectoption('NA', '--None--'));
            secBackgroundList = new List < selectoption > ();
            secBackgroundList.add(new Selectoption('NA', '--None--'));
            if (apexpages.currentpage().getParameters().containskey('jobId')) {
                if (apexpages.currentpage().getParameters().get('jobId') != null) {
                    selJobId = apexpages.currentpage().getParameters().get('jobId');
                    //showjob();
                }
            }
            String sitename = '';
            if (apexpages.currentpage().getParameters().containskey('sitename')) {
                if (apexpages.currentpage().getParameters().get('sitename') != null)
                    sitename =
                        apexpages.currentpage().getParameters().get('sitename');
                else
                    sitename = site.getname();
            } else {
                sitename = site.getname();

            }


            if (apexpages.currentpage().getParameters().containskey('Jobboard')) {
                if (apexpages.currentpage().getParameters().get('Jobboard') != null)
                    jobBoardName = apexpages.currentpage().getParameters().get('Jobboard');
                else {
                    jobBoardName = site.getName();

                    if (JobBoardsSiteMapping__c.getAll().containskey(jobboardName))
                        jobBoardName = JobBoardsSiteMapping__c.getAll().get(jobboardName).Job_Board_Name__c;
                    else
                        jobBoardName = JobBoardsSiteMapping__c.getAll().get(DefaultJobBoardName).Job_Board_Name__c;
                }
            } else {

                jobBoardName = site.getName();

                if (JobBoardsSiteMapping__c.getAll().containskey(jobboardName))
                    jobBoardName = JobBoardsSiteMapping__c.getAll().get(jobboardName).Job_Board_Name__c;
                else
                    jobBoardName = JobBoardsSiteMapping__c.getAll().get(DefaultJobBoardName).Job_Board_Name__c;

            }

            if (sitename == null)
                sitename = DefaultJobBoardName;



            system.debug('********* jobBoardName :' + jobBoardName);
            system.debug('********* sitename:' + sitename);
            if(jobBoardName == 'ASN'){
                pageTemplate = new Pagereference('/apex/JobBoardTemplateAlliedStaffingNetwork');
            }else if(jobBoardName == 'Medestar'){
                pageTemplate = new Pagereference('/apex/JobBoardTemplateMedestar');
            }else if(jobBoardName == 'THMED Executive Search'){
                pageTemplate = new Pagereference('/apex/JobBoardTemplateTHMEDEXE');
            }else if(jobBoardName == 'Fidelis'){
                pageTemplate = new Pagereference('/apex/JobBoardTemplateFidelisPartners');
            }else if(jobBoardName == 'THMED'){
                pageTemplate = new Pagereference('/apex/JobBoardTemplate');
            }

            String objectName = 'tr1__job__c';
            Map < string, Contact > ObjMapcon = new Map < string, Contact > ();

            // Get a map of field name and field token
            Map < String, Schema.SObjectField > fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).
            getDescribe().Fields.getMap();
            list < string > selectFields = new list < string > ();

            if (fMap != null) {
                for (Schema.SObjectField ft: fMap.values()) { // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)

                    selectFields.add(fd.getName());
                    system.debug('******** field name is ' + fd.getName());
                    if (fd.getName().tolowerCase() == 'TR1__Primary_Background__c'.tolowerCase()) {
                        system.debug('******** field name is ' + fd.getName());
                        List < Schema.PicklistEntry > picks = Fd.getPicklistValues();
                        for (Schema.PicklistEntry Picklst: picks) {
                            PrimaryBackgroundList.add(new selectoption(Picklst.getLabel(), Picklst.getLabel()));
                            secBackgroundList.add(new selectoption(Picklst.getLabel(), Picklst.getLabel()));
                        }
                    }

                }
            }

            if (!selectFields.isEmpty()) {
                selects = '';
                for (string s: selectFields) {
                    selects += s.trim() + ',';
                }
                if (selects.endsWith(',')) {
                    selects = selects.substring(0, selects.lastIndexOf(','));
                }

            }

            selects = 'SELECT owner.Alias,' + selects +
                ' FROM ' + objectName;
            //Checking whether the Page opened is the home page or a selected job page
            if (seljobId == '') {
                system.debug('****The JobBoard Name is ' + jobBoardName);
                system.debug('****The JobBoard Name is ' + Apexpages.currentpage().getURL());
                system.debug('****************selects is ' + selects);
                querystr = selects + ' where TR1__Job_Board__c includes (\'' + jobBoardName +
                    '\') and TR1__Status__c != \'Closed\'  and TR1__Post_Externally__c = true order by TR1__Open_Date__c desc limit 100';
                getjob();
            } else {
                querystr = selects + ' where Id = \'' + selJobId + '\' and TR1__Job_Board__c includes (\'' + jobBoardName +
                    '\')  and TR1__Post_Externally__c = true and TR1__Status__c != \'Closed\' order by TR1__Open_Date__c desc limit 1';
                job = null;
                List < tr1__job__c > tempjobList = new List < tr1__job__c > ();
                tempjobList = getjobs();
                if (!tempjobList.isempty()) {
                    seljob = tempjobList.get(0);
                    jobavail = true;
                } else
                    jobavail = false;
                showdescp = true;
                con = new Contact();
                resumeflag = false;
            }
        } catch (Exception e) {
            system.assert(false, e.getMessage() + '>>>>>>>>>>>>>' + e.getLinenumber());
       }

    }

    //Get the StandardSetController Job
    void getJob() {

        system.debug('************ querystr is' + querystr + '.');
        if (selects == '')
            selects = ' select owner.Alias,id,Name,tr1__State_Area__c,TR1__External_Job_Title__c,TR1__Job_Title__c,tr1__Regional_Area__c,tr1__Primary_background__c,tr1__Secondary_background__c' +
                ',tr1__Job_Number__c,tr1__Client_description__c, TR1__External_Job_Title__c ,tr1__Experience_Requirements__c,tr1__Education_Requirements__c from tr1__job__c ';



        if (job == null) {
            if (querystr == '')
                querystr = selects + ' where TR1__Job_Board__c includes (\'' + jobBoardName +
                    '\') and TR1__Status__c != \'Closed\'  and TR1__Post_Externally__c = true order by TR1__Open_Date__c desc limit 100';
            system.debug('************ querystr is' + querystr + '.');
            job = new ApexPages.StandardSetController(AccessController.getQueryLocatorWithoutSharing(querystr));


        }

        if (job.getResultSize() > 0) {
            noofrecords = job.getResultSize();
            job.setPageNumber(pagenumber);
            if (noofrecords < pagesize)
                job.setPageSize(noofrecords);
            else
                job.setPageSize(pagesize);
            system.debug('****************job.getPageSize is ' + job.getPageSize());
            system.debug('****************noofrecords  is ' + noofrecords);

        }
    }
    public Contact con {
        get;
        set;
    }
    public Boolean showdescp {
        get;
        set;
    }

    //Get the Current Page Jobs
    Public List < tr1__job__c > getJobs() {
        List < tr1__job__c > jobList = new List < tr1__job__c > ();

        if (job == null)
            getjob();

        if (job.getRecords() != null) {
            jobList.addAll((List < tr1__job__c > ) job.getRecords());

        }
        return jobList;
    }
    public tr1__job__c seljob {
        get;
        set;
    }
    public pagereference jobsearch() {

        string jobstr = '';

        //system.debug('************* jobBoardName is '+ jobBoardName  );
        if (jobBoardName != null) {

            jobstr = ' where TR1__Job_Board__c includes (\'' + jobBoardName +
                '\') ';
        } else
            jobstr = ' where ';
        if (jobKeyword != null) {
            if (jobKeyword != '') {
                jobstr += ' and '+Label.JobboardSearchstring+' like \'%' + jobKeyword + '%\'  ';
            }
        }
        
        
        if (jobTemp.TR1__Division__c != null) {

            jobstr += ' and TR1__Division__c =\'' +
                jobTemp.TR1__Division__c + '\'';
        }
        if (jobTemp.tr1__Primary_Background__c != null) {
            if (jobTemp.tr1__Primary_Background__c != 'NA') {
                jobstr += ' and tr1__Primary_Background__c =\'' +
                    jobTemp.tr1__Primary_Background__c + '\'';
            }
        }
        if (jobTemp.tr1__Secondary_Background__c != null) {
            if (jobTemp.tr1__Secondary_Background__c != 'NA')
                jobstr += ' and tr1__Secondary_Background__c =\'' +
                    jobTemp.tr1__Secondary_Background__c + '\'';
        }
        //system.debug('************* jobstr is ' + jobstr);
        querystr = selects + jobstr + ' and TR1__Status__c != \'Closed\'  and TR1__Post_Externally__c = true order by TR1__Open_Date__c desc';
        //system.debug('************* querystr  is ' + querystr );
        job = new ApexPages.StandardSetController(AccessController.getQueryLocatorWithoutSharing(querystr));
        noofrecords = job.getResultSize();
        job.setPageNumber(pagenumber);
        if (noofrecords < pagesize)
            job.setPageSize(noofrecords);
        else
            job.setPageSize(pagesize);
        getJobs();
        return null;


    }
    public Integer noOfRecords {
        get;
        set;
    }
    public Integer pagesize {
        get;
        set;
    }


    Public tr1__job__c jobTemp {
        get;
        set;
    }

    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return job.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return job.getHasPrevious();
        }
        set;
    }



    // returns the first page of records
    public void firstjobs() {

        getjob();
        job.first();
        pagenumber = job.getPageNumber();
    }

    // returns the last page of records
    public void lastjobs() {

        getjob();
        job.last();
        pagenumber = job.getPageNumber();
    }

    // returns the previous page of records
    public void previousjobs() {
        //pagenumber --;
        getjob();
        job.previous();
        pagenumber = job.getPageNumber();
    }

    // returns the next page of records
    public void nextjobs() {
        //pagenumber ++;
        getjob();
        job.next();
        pagenumber = job.getPageNumber();
        system.debug('****************** PageNumber is ' + pageNumber);
    }
    public String ResumeText {
        get;
        set;
    }
    Id currentContactId;
    public Boolean Success {
        get;
        set;
    }
    public String response;
    public String resumecontentype {
        get;
        set;
    }
    public TR1.Candidate candt;
    public PageReference createUpdateResume() {
        resume = new Attachment();
        //resume.body = resumebody;
        Success = false;
        Resume.ownerId = selJob.ownerId;
        List < Contact > cons = AccessController.selectContactsByFirstNameAndEmailWithoutSharing(con.Email, con.FirstName);
        if (cons.size() > 0) {
            Resume.ParentId = cons[0].Id;
        }
        /*else
            {
                insert con;
                Resume.ParentId = con.Id;
            }*/

        system.debug('**************** resumetype is  ' + resumetype);
        if (resumetype == 'Upload') {
            resume.body = resumebody;
            if (Resume.Body != null) {
                resume.Name = resumeName;
                resume.contentType = resumecontentype;
                system.debug('********The Resume is ' + Resume);
                if (tr1.skipan_Constants.ContentTypesMap.get(Resume.ContentType) != null) {

                    candt = AccessController.callCreateUpdateContactWithoutSharing(Resume, UserInfo.getSessionId());
                    candt.con.EMail = con.EMail;
                    candt.con.LastName = con.LastName ;
                    candt.con.FirstName= con.FirstName;
                    candt.con.phone= con.phone;
                    candt.con.mobilephone= con.mobilephone;
                    candt.con.MailingStreet= con.MailingStreet;
                    candt.con.MailingCity= con.MailingCity;
                    candt.con.MailingState= con.MailingState;
                    candt.con.mailingpostalcode= con.mailingpostalcode;
                    candt.con.Mailingcountry= con.Mailingcountry;
                    //set contact owner as job owner if record has not been inserted yet
                    //or change ownership to job owner if contact was already created by guest(eg existed in db, or just inserted inside managed package method)
                    if(candt.con.Id == null || AccessController.isContactOwnerGuest(candt.con.Id)) {
                        candt.con.ownerId = selJob.ownerId;
                    }
                    candt = AccessController.callPerformDMLWithoutSharing(candt);
                    if (candt.IsParserError != true) {

                        Success = true;
                        if (resume.ParentId != null) {
                            Contact tempcon = new Contact(Id = resume.ParentId,AccountId = cons[0].AccountId);
                            tempcon.Email = con.Email;
                            tempcon.LastName = con.LastName;
                            tempcon.FirstName = con.FirstName;
                            tempcon.phone = con.phone;
                            tempcon.mobilephone = con.mobilephone;
                            tempcon.MailingStreet = con.MailingStreet;
                            tempcon.MailingCity = con.MailingCity;
                            tempcon.MailingState = con.MailingState;
                            tempcon.mailingpostalcode = con.mailingpostalcode;
                            tempcon.Mailingcountry = con.Mailingcountry;
                            candt.con.ownerId =  selJob.ownerId;
                            if (tempcon.AccountId == null) {
                                tempcon.AccountId = system.label.JobBoard_Default_Account_Id;
                            }
                            AccessController.updateWithoutSharing(tempcon);
                        }
                    } else {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, candt.ParserErrorMsg));
                        clearViewState();
                    }

                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, TR1.skipan_Constants.UNKNOWN_FILE_TYPE));
                    clearViewState();
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, TR1.skipan_Constants.NO_FILE_ATTACHED));
                clearViewState();
            }

        } else if (resumetype == 'Paste') {
            if(resumebodyText != ''){
                    resume.body = Blob.valueOf(resumebodyText);
                    resume.Name = con.firstName + ' ' + con.lastName + '_resume.docx';
                    Resume.ContentType = TR1.skipan_Constants.PASTED_RESUME_CONTENT_TYPE;

                    candt = AccessController.callCreateUpdateContactWithoutSharing(Resume, UserInfo.getSessionId());
                    candt.con.EMail = con.Email;
                    candt.con.LastName = con.LastName ;
                    candt.con.FirstName= con.FirstName;
                    candt.con.phone= con.phone;
                    candt.con.mobilephone= con.mobilephone;
                    candt.con.MailingStreet= con.MailingStreet;
                    candt.con.MailingCity= con.MailingCity;
                    candt.con.MailingState= con.MailingState;
                    candt.con.mailingpostalcode= con.mailingpostalcode;
                    candt.con.Mailingcountry= con.Mailingcountry;
                	//candt.con.ownerId = selJob.ownerId;
                	//set contact owner as job owner if record has not been inserted yet
                    //or change ownership to job owner if contact was already created by guest(eg existed in db, or just inserted inside managed package method)
                	System.debug('candt.con.Id ' + candt.con.Id);
                	if(candt.con.Id == null || AccessController.isContactOwnerGuest(candt.con.Id)) {
                        candt.con.ownerId = selJob.ownerId;
                    }
                	candt = AccessController.callPerformDMLWithoutSharing(candt);
                    if (candt.IsParserError != true) {
                        Success = true;

                        if (resume.ParentId != null) {
                            Contact tempcon = new Contact(Id = resume.ParentId,AccountId = cons[0].AccountId);
                            tempcon.Email = con.Email;
                            tempcon.LastName = con.LastName;
                            tempcon.FirstName = con.FirstName;
                            tempcon.phone = con.phone;
                            tempcon.mobilephone = con.mobilephone;
                            tempcon.MailingStreet = con.MailingStreet;
                            tempcon.MailingCity = con.MailingCity;
                            tempcon.MailingState = con.MailingState;
                            tempcon.mailingpostalcode = con.mailingpostalcode;
                            tempcon.Mailingcountry = con.Mailingcountry;
                            if (tempcon.AccountId == null) {
                                tempcon.AccountId = system.label.JobBoard_Default_Account_Id;
                            }
                            AccessController.updateWithoutSharing(tempcon);
                        }
                    } else
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, candt.ParserErrorMsg));
                        clearViewState();
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please paste the resume before submitting the application'));
                    clearViewState();
                }
            }


        else if(resumetype == 'SubmitWOResume'){
                if(!cons.isEmpty()){
                    tempCon.Id = cons[0].Id;
                    tempCon.AccountId = cons[0].AccountId;
                }
                tempcon.Email = con.Email;
                tempcon.LastName = con.LastName;
                tempcon.FirstName = con.FirstName;
                tempcon.phone = con.phone;
                tempcon.mobilephone = con.mobilephone;
                tempcon.MailingStreet = con.MailingStreet;
                tempcon.MailingCity = con.MailingCity;
                tempcon.MailingState = con.MailingState;
                tempcon.mailingpostalcode = con.mailingpostalcode;
                tempcon.Mailingcountry = con.Mailingcountry;
            	//tempcon.ownerId = selJob.ownerId;
            	//set contact owner as job owner if record has not been inserted yet
            	//or change ownership to job owner if contact was already created by guest(eg existed in db, or just inserted inside managed package method)
            	if(tempcon.Id == null || AccessController.isContactOwnerGuest(tempcon.Id)) {
            		tempcon.ownerId = selJob.ownerId;
                }
                if (tempcon.AccountId == null) {
                    tempcon.AccountId = system.label.JobBoard_Default_Account_Id;
                }
            	AccessController.upsertWithoutSharing(tempcon);
                Success = true;
        }
        if (Success) {
            if (selJob.Id != null) {
                String rcdId = '';
                /*List<recordtype> rcdtyps = [select id from recordType where name = 'Application'
                        and sobjecttype = 'tr1_application__c'];
                if(rcdtyps.size() > 0)
                {
                    rcdId = rcdtyps[0].Id;
                }*/

                TR1__Application__c applcation = new TR1__Application__c();
                //applcation.TR1__Applicant__c = Resume.ParentId;
                if(resumetype == 'SubmitWOResume')
                    applcation.TR1__Applicant__c = tempcon.Id;
                else
                    applcation.TR1__Applicant__c = candt.ContactId;
                    applcation.tr1__job__c = selJob.Id;
                    applcation.TR1__Source__c = 'Job Board';
                    applcation.tr1__Status__c = 'Current';


                try {
                    AccessController.insertWithoutSharing(applcation);
                    system.debug('************The applcation is ' + applcation);
                    successmesg = true;
                    /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'Application_Notifcation'];
                    contact con = [select Id, email from contact where Id =: applcation.TR1__Applicant__c];
                    String[] toAddresses = new String[] {con.Email};
                    system.debug('emailID is '+con.Email);
                    system.debug(' tempConID is '+applcation.TR1__Applicant__c);
                    system.debug(' ApplicationID is '+applcation.ID);
                    mail.setTargetObjectId(applcation.TR1__Applicant__c);
                    mail.setTemplateId(et.id);
                    mail.setSaveAsActivity(true);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); */
                 /* String thankyoupageurl = '';
                   if(jobBoardName == 'ASN'){
                        thankyoupageurl = 'http://alliedstaffingnetwork.com/';
                    }else if(jobBoardName == 'Medester'){
                        thankyoupageurl = 'https://www.medestar.com/';
                    }else if(jobBoardName == 'THMED Executive Search'){
                        thankyoupageurl = 'http://thmedexec.com/';
                    }else if(jobBoardName == 'Fidelis'){
                        thankyoupageurl = 'http://fidelismp.com/';
                    }else if(jobBoardName == 'THMED'){
                        thankyoupageurl = 'http://thmedstaffing.com/';
                    }
                    return new PageReference(thankyoupageurl);
                    
                   */ 
                } catch (Exception e) {
                    clearViewState();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                    if(candt!=null) candt.ParserErrorMsg = e.getMessage();
                }
            }
        }
        return null;
    }

    public void clearViewState() {
        Resume = new Attachment();
        if(candt!=null) {
          candt.Resume = new Attachment();
          candt.ResumeView = new Attachment();
        }
        resumebody = null;
    }
    public boolean resumeflag {
        get;
        set;
    }
    public String resumetype {
        get;
        set;
    }
    public pagereference cont() {
        if (resumeflag)
            resumeflag = false;
        else
            resumeflag = true;
        resumetype = 'Upload';
       
        return null;
    }
    public pagereference SubmitWOResume(){
        resumetype = 'SubmitWOResume';
        return createUpdateResume();
    }
    //https://tr1.na12.visual.force.com/apex/tr1__jobRegister_Maleko?jobId=a0xF0000000teUGIAY
    public static Boolean emailvalidator(String email) {
        Pattern EmailPattern = Pattern.compile(tr1.skipan_Constants.EMAIL_VALIDATION_PATTERN);
        Matcher EmailMatcher = EmailPattern.matcher(email);
        return EmailMatcher.matches();
    }

    public Boolean haserror {
        get;
        set;
    }
    public pagereference sndEmail() {

        haserror = false;

        if (fromEmail == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'From Email is required'));
            haserror = true;
        } else if (!emailvalidator(fromEmail)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'From Email is not valid'));
            haserror = true;
        }
        if (toEmail == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'To Email is required'));
            haserror = true;
        } else if (!emailvalidator(toEmail)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'To Email is not valid'));
            haserror = true;
        }

        if (!haserror) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            String[] toAddresses = new List < String > {
                toEmail
            };
            email.setToAddresses(toAddresses);
            String senderdetails = '<br/> <br/> Note: This Email is send by ';
            if (fromNAme != null)
                senderdetails += fromName + '(' + fromEmail + ').';
            else
                senderdetails += fromEmail;
            System.debug('*************** The message is ' + mesg + ' <br/> ' +
                site.getCurrentSiteUrl() + 'JobSearch?jobId=' + selJobId + senderdetails);
            email.setSubject('Job Opening ' + selJob.Name);
            email.setHtmlBody(mesg + ' <br/> ' +
                site.getCurrentSiteUrl() + 'JobSearch?jobId=' + selJobId + senderdetails
            );

            if (FromEmail != null) {
                email.setReferences(FromEmail + 'cvpresources@joblabs.com');


            }


            List < Messaging.SendEmailResult > results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                email
            });


            return new pagereference('/' + site.getname() + '/jobsearch?JobId=' + selJobId);
        } else
            return null;
    }


}
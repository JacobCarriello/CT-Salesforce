/*
Developer Name : 
Description : 
*/
public with sharing class RC_UtilityClass 
{
    static TR1__Expense_Report__c objExpense;
    // for Custom setting object, have necessary value for candidate registration
    static Candidate_Community__c objCustomSettingForCandidate = Candidate_Community__c.getValues('RegistrationDetail'); 
    /* 
    Name : insertJob
    Parameter : None
    Purpose : Inserts a TR1__Job__c record and returns it accordingly.
    */
    public static TR1__Job__c insertJob()
    {
        TR1__Job__c objJob = new TR1__Job__c(); 
        insert objJob;
        return objJob;
    }
    
    /*
    Name : insertJob
    Parameter : String
    Purpose : Inserts a TR1__Timesheet__c record and returns it accordingly.
    */
    public static TR1__Timesheet__c insertTimeSheet(String strJobId)
    {
        TR1__Timesheet__c objTimeSheet = new TR1__Timesheet__c(TR1__Job_Order__c = strJobId);
        insert objTimeSheet;
        return objTimeSheet;
    }
    
    /*
    Name : insertTimeSheetDetail
    Parameter : String
    Purpose : Inserts a TR1__Timesheet_Detail__c record and returns it accordingly.
    */
    public static TR1__Timesheet_Detail__c insertTimeSheetDetail(String strTimeSheetId)
    {
        TR1__Timesheet_Detail__c objTimeSheetDetail = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = strTimeSheetId);
        insert objTimeSheetDetail;
        return objTimeSheetDetail;
    }
    
    /*
    Name : returnCommunityUser
    Parameter : None
    Purpose : inserts and returns community User
    */ 
    public static User returnCommunityUser()
    {
        RC_UtilityClass objUtility = new RC_UtilityClass();
        
        Account objAcc = new Account (Name = 'newAcc1');   
        insert objAcc;
        
        Contact objContact = new Contact (AccountId = objAcc.id, LastName = 'portalTestUser', TR1__Candidate_Status__c = 'Placed', TR1__Client_Status__c = 'Active');
        insert objContact;
        
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
         
        
        //System.runAs ( thisUser ) 
        //{
            Profile objProfile = [select Id,name from Profile where name ='Recruitment Community User' limit 1];
            
            User newUser = new User(
                profileId = objProfile.id, 
                username = 'newUser@yahoo.com', 
                email = 'pb@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Chicago', 
                alias='nuser', 
                lastname='lastname', 
                contactId = objContact.id
            );
            insert newUser;
            //thisUser =  [ select Id,contactId from User where Id = :newUser.Id ] ;   
       // }
        return newUser; 
    }
    
    /*
    Name : returnExpenseReport
    Parameter : None
    Purpose : inserts and returns TR1__Expense_Report__c object.
    */ 
    public static TR1__Expense_Report__c returnExpenseReport()
    {
        Contact objContact = new Contact(Firstname = 'Test', Lastname = 'Conatct1');
        insert objContact;
        //Submitted
        //objExpense = new TR1__Expense_Report__c(TR1__Consultant__c = objContact.Id, TR1__Status__c = 'Approved');
        objExpense = new TR1__Expense_Report__c(TR1__Consultant__c = objContact.Id, TR1__Status__c = 'Submitted');
        insert objExpense; 
        
        return objExpense;
    }
    
    /*
    Name : returnExpenseReportDetail
    Parameter : None
    Purpose : inserts and returns TR1__Expense_Report_Detail__c object.
    */ 
    public static TR1__Expense_Report_Detail__c returnExpenseReportDetail() 
    {
        TR1__Expense_Report_Detail__c objExpReport = new TR1__Expense_Report_Detail__c();
        objExpReport.TR1__Expense_Report__c = objExpense.id;
        insert objExpReport; 
        return objExpReport; 
    }
    
    public static User returnCommunityContactTypeUser(String contactType) {
        return returnCommunityContactTypeUser(contactType, '');

    }

    public static User returnCommunityContactTypeUser(String contactType, String nameVariation) 
    {
        Account objAcc = new Account (Name = 'newAcc1'+ nameVariation);   
        insert objAcc;
        
        //Contact objContact = new Contact (AccountId = objAcc.id, LastName = 'portalTestUser', TR1__Candidate_Status__c = 'Consult Hot', TR1__Client_Status__c = 'Active');
        Contact objContact = new Contact (AccountId = objAcc.id, LastName = 'portalTestUser'+ nameVariation);
        if(contactType == 'c&c')
        {
            objContact.TR1__Candidate_Status__c = 'Consult Hot';
            objContact.TR1__Client_Status__c = 'Active';
        }   
        else if(contactType == 'client')
        {
            objContact.TR1__Candidate_Status__c = 'Prospect';
            objContact.TR1__Client_Status__c = 'Active';
        }
        else if(contactType == 'candidate')
        {
            objContact.TR1__Candidate_Status__c = 'Placed';
            objContact.TR1__Client_Status__c = 'Not Applicable';
        }
        insert objContact;
        
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        //System.runAs ( thisUser ) 
        //{
            Profile objProfile = [select Id,name from Profile where name ='Recruitment Community User' limit 1]; 
            
            User newUser = new User(
                profileId = objProfile.id, 
                username = 'newUser1'+ nameVariation +'@yahoo.com', 
                email = 'pb'+ nameVariation +'@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Chicago', 
                alias='nuser'+ nameVariation, 
                lastname='lastname'+ nameVariation, 
                contactId = objContact.id
                //TimeZoneSidKey = '(GMT-05:00) Central Daylight Time (America/Chicago)'
            );
            insert newUser;
            //thisUser =  [ select Id,contactId,accountId from User where Id = :newUser.Id ] ;   
            //System.debug('--- thisUser.accountId : '+thisUser.accountId);
        //}
        return newUser; 
        
    }
    
    public static User returnGuestUser() {
        List<Profile> guestProfiles = [Select Id From Profile Where UserLicense.Name LIKE 'Guest%'];
        Set<Id> profileIds = new Set<Id>();
        for(Profile currentProfile : guestProfiles) {
            profileIds.add(currentProfile.Id);
        }
        User guestUser = [Select Id From User Where ProfileId IN : profileIds Limit 1];
        return guestUser;
    }
    
    //TR1__Closing_Report__c objClosingReport = RC_UtilityClass.returnClosingReport();
    public static TR1__Closing_Report__c returnClosingReport(Boolean isInsert)
    {
        TR1__Closing_Report__c objClosingReport = new TR1__Closing_Report__c();
        objClosingReport.TR1__Job_Percentage__c = 20;
        objClosingReport.TR1__Candidate_Percentage__c  = 20;
        objClosingReport.TR1__Marketing_Percentage__c  = 20; 
        objClosingReport.TR1__Other_Percentage__c  = 20;
        objClosingReport.TR1__Other2_Percentage__c = 20; 
        objClosingReport.TR1__Job__c = insertJob().id; 

        
        if(isInsert){   
            insert objClosingReport; 
        }
        
        return objClosingReport;
    } 
    
    public static Id createAndGetContactId(String contactName)
    {
       Contact con = new Contact (LastName = contactName);
       insert con;
       return con.Id; 
    }
}
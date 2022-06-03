@isTest
public class TestJobTrigger {
    
    @testSetup
    static void testSetup () {
        insert new TriggerControl__c (Name = 'JobTrigger',IsActive__c = true);

        System.runAs(new User(Id = System.UserInfo.getUserId())) {
            insert new UserRole (Name = 'TestRole',DeveloperName = 'TestRole');

            ID recProfileId = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Recruiter%' LIMIT 1].Id;
            ID nonRecAMProfileId = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND (NOT Name LIKE '%Recruiter%') AND (NOT Name LIKE '%Account Manager%') LIMIT 1].Id;

            Database.insert(
                new List <User> {
                    new User (
                        Alias = 'RecGuy'
                        ,Email = 'RecGuy@noEmail.com.invalid'
                        ,EmailEncodingKey = 'UTF-8'
                        ,FirstName = 'Rec'
                        ,LastName = 'Guy'
                        ,LanguageLocaleKey = 'en_US'
                        ,LocaleSidKey = 'en_US'
                        ,ProfileId = recProfileId
                        ,IsActive = true
                        ,TimeZoneSidKey = 'America/Chicago'
                        ,Username = 'RecGuy@noEmail.com.invalid'
                    )
                    ,new User (
                        Alias = 'NonGuy'
                        ,Email = 'NonRecAMGuy@noEmail.com.invalid'
                        ,EmailEncodingKey = 'UTF-8'
                        ,FirstName = 'NonRecAM'
                        ,LastName = 'Guy'
                        ,LanguageLocaleKey = 'en_US'
                        ,LocaleSidKey = 'en_US'
                        ,ProfileId = nonRecAMProfileId
                        ,IsActive = true
                        ,TimeZoneSidKey = 'America/Chicago'
                        ,Username = 'NonRecAMGuy@noEmail.com.invalid'
                    )
                }
            );
        }
    }

    @isTest
    static void testValidation () {
        User recUser = [SELECT Id FROM User WHERE Username = 'RecGuy@noEmail.com.invalid' AND IsActive = TRUE LIMIT 1];
        User nonRecAMUser = [SELECT Id FROM User WHERE Username = 'NonRecAMGuy@noEmail.com.invalid' AND IsActive = TRUE LIMIT 1];

        TR1__Job__c job1 = new TR1__Job__c (Name = 'Job Test 1');
        TR1__Job__c job2 = new TR1__Job__c (Name = 'Job Test 2');
        insert job2;

        try {
            try {
                job1.TR1__Sourcing_Recruiter__c = nonRecAMUser.Id;
                insert job1;
            } catch (Exception e) {System.debug(':::::: TestJobTrigger + testValidation + insert Job1 with non-Recruiter/AM user + e : ' + e);}

            try {
                job1.TR1__Sourcing_Recruiter__c = recUser.Id;
                insert job1;
            } catch (Exception e) {System.debug(':::::: TestJobTrigger + testValidation + insert Job1 with Recruiter user + e : ' + e);}
            
            try {
                job2.TR1__Sourcing_Recruiter__c = recUser.Id;
                update job2;
            } catch (Exception e) {System.debug(':::::: TestJobTrigger + testValidation + update Job2 with Recruiter user + e : ' + e);}
            
            try {
                job2.TR1__Sourcing_Recruiter__c = nonRecAMUser.Id;
                update job2;
            } catch (Exception e) {System.debug(':::::: TestJobTrigger + testValidation + update Job2 with non-Recruiter/AM user + e : ' + e);}
            
            try {
                delete job2;
            } catch (Exception e) {System.debug(':::::: TestJobTrigger + testValidation + delete Job2 + e : ' + e);}
        } catch (Exception e) {System.debug(':::::: TestJobTrigger + testValidation + e : ' + e);}
    }

    @isTest
    static void testTitleCasing () {
        TR1__Job__c job1 = new TR1__Job__c (Name = 'Job Test 1');
        insert job1;

        try {
            try {
                job1.TR1__External_Job_Title__c = 'JOB TEST 1';
                update job1;
            } catch (Exception e) {System.debug(':::::: TestJobTrigger + testTitleCasing + update External Job Title + e : ' + e);}
            
            try {
                insert new TR1__Job__c (Name = 'Job Test 2',TR1__External_Job_Title__c = 'JOB TEST 2');
            } catch (Exception e) {System.debug(':::::: TestJobTrigger + testTitleCasing + insert with External Job Title + e : ' + e);}
        } catch (Exception e) {System.debug(':::::: TestJobTrigger + testTitleCasing + e : ' + e);}
    }

    @isTest
    static void testGetJob () {
        List <TR1__Job__c> returnedList = JobGateway.getJobs(new List <TR1__Job__c> {new TR1__Job__c (Name = 'Job Test 1')});
    }
}
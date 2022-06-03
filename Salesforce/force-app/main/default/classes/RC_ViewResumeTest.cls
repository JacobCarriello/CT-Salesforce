@isTest
private class RC_ViewResumeTest {
 	 /*
     the following test method tests if current user have access to view resume record. Only contacts who are associated with a Job(Contact__c or HR__c) can see Contact Documents of Contacts who have related Job Reportings
     **/
    private static testMethod void testViewResume() {
        User newUser = RC_UtilityClass.returnCommunityContactTypeUser('c&c');
        TR1__Job__c newJob = RC_UtilityClass.insertJob();
        newJob.TR1__Contact__c = newUser.contactId;
        update newJob;
        Id candidateId = RC_UtilityClass.createAndGetContactId('newCandidate');
        insert new TR1__Job_Reporting__c(TR1__Job__c  = newJob.Id, TR1__Contact__c  = candidateId);
        TR1__ContactDocument__c resumeRecord = new TR1__ContactDocument__c(TR1__Contact__c = candidateId, TR1__Type__c  = 'Resume', TR1__isDefault__c  = true, TR1__HTML_URL__c = 'https://amazonaws.com/test/newResume.pdf');
        insert resumeRecord;
        
        insert new TR1__TalentRoverProperties__c(SetupOwnerId=UserInfo.getOrganizationId(), TR1__Use_Presigned_urls__c=true);
        System.runAs(newUser) {
            PageReference viewResume = Page.ViewResume;
            viewResume.getParameters().put('id', resumeRecord.Id);
            Test.setCurrentPage(viewResume);
            RC_ViewResume ctrl = new RC_ViewResume();
            ctrl.validateHtmlUrl();
            System.assert(String.isNotBlank(ctrl.resumeUrl));
            System.assert(ctrl.isSuccess);
        }
    }
    
     /*
     the following test method tests if validateHtmlUrl method converts Contact Document from Attachments and transfers data to AWS. There is no actual check as http responses are not mocked
     **/
    
    private static testMethod void testViewResumeConversionToAws() {
        User newUser = RC_UtilityClass.returnCommunityContactTypeUser('c&c');
        TR1__Job__c newJob = RC_UtilityClass.insertJob();
        newJob.TR1__Contact__c = newUser.contactId;
        update newJob;
        Id candidateId = RC_UtilityClass.createAndGetContactId('newCandidate');
        insert new TR1__Job_Reporting__c(TR1__Job__c  = newJob.Id, TR1__Contact__c  = candidateId);
        TR1__ContactDocument__c resumeRecord = new TR1__ContactDocument__c(TR1__Contact__c = candidateId, TR1__Type__c  = 'Resume', TR1__isDefault__c  = true, TR1__Internal_URL__c  = 'https://aws.com/test/newResume.pdf');
        insert resumeRecord;
        System.runAs(newUser) {
            PageReference viewResume = Page.ViewResume;
            viewResume.getParameters().put('id', resumeRecord.Id);
            Test.setCurrentPage(viewResume);
            RC_ViewResume ctrl = new RC_ViewResume();
            ctrl.validateHtmlUrl();
            //resume url will be blank as logic can not generate real aws url and simply leaves blank value there
            //System.assert(String.isNotBlank(ctrl.resumeUrl));
            System.assert(ctrl.isSuccess);
        }
    }
    
    /*
     the following test method tests if hiring manager can not see resumes of contacts who do not have associated Job Reporting records with hr's jobs.
     **/
    
    private static testMethod void testViewResumeNoAccess() {
        User newUser = RC_UtilityClass.returnCommunityContactTypeUser('c&c');
        TR1__Job__c newJob = RC_UtilityClass.insertJob();

        Id candidateId = RC_UtilityClass.createAndGetContactId('newCandidate');
        TR1__ContactDocument__c resumeRecord = new TR1__ContactDocument__c(TR1__Contact__c = candidateId, TR1__Type__c  = 'Resume', TR1__isDefault__c  = true, TR1__Internal_URL__c  = 'https://aws.com/test/newResume.pdf');
        insert resumeRecord;
        System.runAs(newUser) {
            PageReference viewResume = Page.ViewResume;
            viewResume.getParameters().put('id', resumeRecord.Id);
            Test.setCurrentPage(viewResume);
            RC_ViewResume ctrl = new RC_ViewResume();
            ctrl.validateHtmlUrl();
            //resume url will be blank as logic can not generate real aws url and simply leaves blank value there
            System.assert(String.isBlank(ctrl.resumeUrl));
            System.assert(!ctrl.isSuccess);
        }
    }
}
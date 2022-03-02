@isTest
private class RC_JobListingTest 
{

	private static testMethod void test() 
	{ 
	    /* Checking page from non community user */
	    TR1__Job__c objJob = RC_UtilityClass.insertJob();
	    objJob.TR1__Post_Externally__c = true;
	    objJob.TR1__Status__c = 'Open';
	    objJob.TR1__Client_Description__c = 'Test';
	    objJob.TR1__Education_Requirements__c = 'Test';
	    objJob.TR1__Experience_Requirements__c = 'Test';
	    objJob.TR1__Responsibilities__c = 'Test';
	    objJob.TR1__External_Job_Title__c = 'Test';
	    update objJob;
	    RC_JobListing objJobListing = new RC_JobListing();
	    PageReference pgRedirect = objJobListing.redirectUnAuthenticatedUser();
	    System.assertEquals('/Signin', pgRedirect.getURL());
	    
	    /*loggin in as community user*/
        User u = RC_UtilityClass.returnCommunityContactTypeUser('c&c');   
	    System.runAs(u)
	    {
	        PageReference pg = Page.JobListing;
	        Test.setCurrentPage(pg);
	        objJobListing = new RC_JobListing(); 
	        pgRedirect = objJobListing.redirectUnAuthenticatedUser();
	        System.assertEquals(null, pgRedirect);
	        objJobListing.saveJobLead(); 
	        
	        objJobListing.idJobToBeApplied = (RC_AccessController.query('SELECT id FROM TR1__Job__c LIMIT 1')[0]).id;
	        objJobListing.applyToJob();
	        System.assertEquals(0,objJobListing.lstNotAppliedJobs.size());
	        System.assertEquals(1,objJobListing.lstAppliedJobs.size());
	    } 
	}
	


}
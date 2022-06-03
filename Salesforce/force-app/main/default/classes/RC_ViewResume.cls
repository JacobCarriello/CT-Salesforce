public with sharing class RC_ViewResume {
	private TR1__ContactDocument__c selectedDocument;
    public Boolean isSuccess { get; set; }
    public String resumeUrl {get; private set; }

    public RC_ViewResume(){
    	String id = ApexPages.currentPage().getParameters().get('id');
    	if(String.isNotEmpty(id)){
            Set<Id> availableContactIds = getAvailableContactIdsForCurrentUser();
            List<TR1__ContactDocument__c> documents = RC_AccessController.getContactDocumentByIdWithParticularContactAccess(id, availableContactIds);
            if(documents.size() > 0) {
                selectedDocument = documents[0];
            }
    	}
    }

    private Set<Id> getAvailableContactIdsForCurrentUser() {
        Set<Id> availableContactIds = new Set<Id>();
        String currentContactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId; 
        List<TR1__Job_Reporting__c> jobReportings = RC_AccessController.getAllJobReportingsForContactsJobs(currentContactId);
        for(TR1__Job_Reporting__c jobReporting: jobReportings) {
            availableContactIds.add(jobReporting.TR1__Contact__c);
        }
        return availableContactIds;
    }

    public void validateHtmlUrl() {
        isSuccess = true;
		if(selectedDocument == null) {
            isSuccess = false;
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'No resume is found for this contact.'));
            return;
        } else if(String.isEmpty(selectedDocument.TR1__HTML_URL__c)) {
            TR1.ResumeManager5Controller ctrl = new TR1.ResumeManager5Controller();
            TR1.ResumeManager5Controller.HTMLGenerateResponse response = ctrl.generateHtmlUrl(selectedDocument.Id, UserInfo.getSessionId());
            resumeUrl = response.HtmlURL;
            selectedDocument.TR1__HTML_URL__c = resumeUrl;
        } else {
            resumeUrl = selectedDocument.TR1__HTML_URL__c;
        }
		if(String.isNotBlank(selectedDocument.TR1__HTML_URL__c) && TR1__TalentRoverProperties__c.getOrgDefaults()!=null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__Use_Presigned_urls__c && selectedDocument.TR1__HTML_URL__c.contains('amazonaws.com')){
            TR1.Utility.PresignedUrlResponse response = TR1.Utility.getPresignedUrl(selectedDocument.TR1__HTML_URL__c);
			if(response.success != null && response.success) {
				resumeUrl = response.presigned_url;
			}
		}
    }
}
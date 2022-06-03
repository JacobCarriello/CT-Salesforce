global class sendEmailTimeSheetStatusBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id, Name, TR1__Closing_Report__r.TR1__Person_Placed__c FROM TR1__Timesheet__c WHERE TR1__Status__c = \'Unsubmitted\' AND TR1__Closing_Report__c != null AND TR1__Closing_Report__r.TR1__Person_Placed__r.Email != null';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<TR1__Timesheet__c> scope) {
   		List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
   		List<EmailTemplate> emailTempList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TimeSheet_Submit_Reminder'];
		if(!emailTempList.isEmpty()) {
			for (TR1__Timesheet__c timeSheet : scope) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            mail.setTargetObjectId(timeSheet.TR1__Closing_Report__r.TR1__Person_Placed__c);
	            mail.setTemplateId(emailTempList[0].id);
	            emailList.add(mail);
			}
			try {
	            Messaging.sendEmail(emailList);
	        } catch(Exception ex){
	        	system.debug('TimeSheet email transaction failed: ' + ex.getMessage());
	        }
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
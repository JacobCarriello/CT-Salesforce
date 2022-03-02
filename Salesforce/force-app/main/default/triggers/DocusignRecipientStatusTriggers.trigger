trigger DocusignRecipientStatusTriggers on dsfs__DocuSign_Recipient_Status__c (before insert, before update) {
 	
 	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
 		DocusignRecipientStatusTriggerHandler.beforeInsertUpdate(Trigger.new, Trigger.oldMap);
 	}   
}
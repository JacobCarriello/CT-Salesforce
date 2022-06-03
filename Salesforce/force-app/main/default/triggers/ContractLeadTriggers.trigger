trigger ContractLeadTriggers on TR1__Job_Leads__c (after insert, after update, before insert, before update) {
	
	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
		ContractLeadTriggerHandler.afterInserUpdate(Trigger.new, Trigger.oldMap);
	}    
}
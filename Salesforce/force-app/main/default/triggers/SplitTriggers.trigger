trigger SplitTriggers on Split__c (after insert, after update, before insert, before update) {
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
		SplitsTriggerHandler.afterInserUpdate(Trigger.new, Trigger.oldMap);
	} 
}
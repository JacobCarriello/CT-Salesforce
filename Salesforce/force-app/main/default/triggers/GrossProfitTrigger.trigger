trigger GrossProfitTrigger on TR1__Gross_Profit__c (after insert, after update){
	GrossProfitTriggerHandler grossDuplicateTrigger = new GrossProfitTriggerHandler(Trigger.new);
	grossDuplicateTrigger.deleteDuplicates();
}
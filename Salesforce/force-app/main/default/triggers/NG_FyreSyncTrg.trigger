trigger NG_FyreSyncTrg on FyreSync__Requisition__c (after insert, after update) 
{
    NG_TrgHndler_FyreSync handler = new NG_TrgHndler_FyreSync(Trigger.isExecuting, Trigger.size);
	
    /*After Insert*/
    if(Trigger.isInsert && Trigger.isAfter) 
    {
	    System.debug('NGDebug TriggerIsAfter, TriggerIsInsert RecSize='+Trigger.size); 
    	handler.onAfterInsert(Trigger.newMap);
	}
    
    /*After Update*/
    if(Trigger.isUpdate && Trigger.isAfter) 
    {
	    System.debug('NGDebug TriggerIsAfter, TriggerIsUpdate RecSize='+Trigger.size); 
    	handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}
}
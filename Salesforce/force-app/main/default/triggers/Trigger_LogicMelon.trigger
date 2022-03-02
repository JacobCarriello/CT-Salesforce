trigger Trigger_LogicMelon on TR1__Job__c (after update) {
    if(Trigger_LogicMenon.DELETE_LOGICMELON_JOBPOSTING)
    	Trigger_LogicMenon.LogicMenon_deleteJobPostings(trigger.newMap , trigger.oldMap);
}
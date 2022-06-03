trigger JobTrigger on TR1__Job__c (after delete, after insert, after update, before delete, before insert, before update) {
    if (TriggerControl__c.getValues('JobTrigger') != null) {
        Boolean tc = TriggerControl__c.getValues('JobTrigger').IsActive__c;
        if(tc == true) {
            CTTriggerFactory.createAndExecuteHandler(JobHandler.class);
        }
    }
}
trigger ClosingReportTrigger on TR1__Closing_Report__c (after delete, after insert, after update, before delete, before insert, before update) {
    if (TriggerControl__c.getValues('ClosingReportTrigger') != null) {
        Boolean tc = TriggerControl__c.getValues('ClosingReportTrigger').IsActive__c;
        if(tc == true) {
            CTTriggerFactory.createAndExecuteHandler(ClosingReportHandler.class);
        }
    }
}
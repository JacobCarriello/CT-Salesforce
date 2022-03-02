trigger ClosingReportBeforeInsertUpdateDelete on TR1__Closing_Report__c (before insert, before update, before delete, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isinsert || Trigger.isUpdate){
            ClosingReportTriggerHandler.beforeInsertUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isinsert || Trigger.isUpdate){
            ClosingReportTriggerHandler.afterInsertUpdate(Trigger.new, Trigger.oldMap);
         }
    }
}
public with sharing class ClosingReportHandler implements Itrigger {
    
    List <TR1__Gross_Profit__c> listUpdateGrossProfits = new List <TR1__Gross_Profit__c> ();

    public ClosingReportHandler () {}

    public void bulkBefore () {
        if (Trigger.isInsert) {
            // ClosingReportGateway.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            // ClosingReportGateway.onBeforeUpdate(Trigger.new,Trigger.old);
        }
    }

    public void bulkAfter () {
        if (Trigger.isInsert) {
            // ClosingReportGateway.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            // ClosingReportGateway.onAfterUpdate(Trigger.new,Trigger.old);
            listUpdateGrossProfits = ClosingReportGateway.checkUpdatesForGP(Trigger.new,Trigger.old);
        }
    }

    public void beforeInsert (SObject so) {}
 
    public void beforeUpdate (SObject oldSo,SObject so) {}
 
    public void beforeDelete (SObject so) {}

    public void afterInsert (SObject so) {}
 
    public void afterUpdate (SObject oldSo,SObject so) {}
 
    public void afterDelete (SObject so) {}

    public void andFinally () {
        if (!listUpdateGrossProfits.isEmpty()) {Database.update(listUpdateGrossProfits,false);}
    }
}
public with sharing class JobHandler implements Itrigger {
    public JobHandler() {}

    public void bulkBefore () {
        if (Trigger.isInsert) {
            JobGateway.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            JobGateway.onBeforeUpdate(Trigger.new,Trigger.old);
        }
        if (Trigger.isInsert || Trigger.isUpdate) {
            JobGateway.correctTitleCasing(Trigger.new,Trigger.old);
        }
    }

    public void bulkAfter () {
        if (Trigger.isInsert) {
            // JobGateway.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            // JobGateway.onAfterUpdate(Trigger.new,Trigger.old);
        }
    }

    public void beforeInsert (SObject so) {}
 
    public void beforeUpdate (SObject oldSo,SObject so) {}
 
    public void beforeDelete (SObject so) {}

    public void afterInsert (SObject so) {}
 
    public void afterUpdate (SObject oldSo,SObject so) {}
 
    public void afterDelete (SObject so) {}

    public void andFinally () {

    }
}
public with sharing class TR_ShiftWork_Helper 
    extends BaseTriggerHelper
{
    public TR_ShiftWork_Helper() {

    }

    public override void execute(SObject so) {
        system.debug('bw-trigger: TimesheetHelper::' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);

        if(Trigger.isAfter && Trigger.isDelete) {
            DeleteNGTimesheetEntrySlot((TR1__ShiftWork__c)so);
        }

    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw-trigger: TimesheetHelper::execute -> so = ' + so + ', oldSo = ' + oldSo);
    }

    private void DeleteNGTimesheetEntrySlot(TR1__ShiftWork__c tr1ShiftWork) {
        system.debug('bw-trigger: DeleteNGTimesheetEntrySlot -> fired');
        TimesheetEntrySlotGateway.deleteBySourceObjectId(tr1ShiftWork.Id);
    }
}
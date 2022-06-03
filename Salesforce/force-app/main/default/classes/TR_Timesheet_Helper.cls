public without sharing class TR_Timesheet_Helper 
    extends BaseTriggerHelper
{
    public TR_Timesheet_Helper() {

    }

    public override void execute(SObject so) {
        SObjectUnitOfWork uow = null;

        if(Trigger.isAfter && Trigger.isInsert) {
        	system.debug('bw-trigger: TR_Timesheet_Helper::AfterInsert Trigger: so = ' + so);
            uow = TimesheetGateway.create((TR1__Timesheet__c) so);
        }
        else if(Trigger.isAfter && Trigger.isDelete) {
            uow = TimesheetGateway.deleteBySourceObjectId(so.Id);
        }

        if(uow != null) {
            m_uowList.add(uow);
        }
    }

    public override void execute(SObject so, SObject oldSo){
        if(Trigger.isAfter && Trigger.isUpdate) {
            system.debug('bw-trigger: TR_Timesheet_Helper::AfterUpdate Trigger: so = ' + so + ', oldSo = ' + oldSo);
            List<SObjectUnitOfWork> uows = TimesheetGateway.synchronize((TR1__Timesheet__c) so);
            m_uowList.addAll(uows);
        }

    }
}
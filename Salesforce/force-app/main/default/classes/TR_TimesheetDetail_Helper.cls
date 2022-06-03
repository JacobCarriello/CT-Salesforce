public with sharing class TR_TimesheetDetail_Helper 
    extends BaseTriggerHelper
{
    public TR_TimesheetDetail_Helper() {

    }

    public override void execute(SObject so) {
        system.debug('bw-trigger: TR_TimesheetDetail_Helper::' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);

        SObjectUnitOfWork uow = null;

        if(Trigger.isAfter && Trigger.isInsert) {
            TR1__Timesheet_Detail__c detail = (TR1__Timesheet_Detail__c) so;
            if(detail.Shift_Status__c != 'Tentative' && detail.Shift_Status__c != 'Cancelled') {
                uow = CreateNGTimesheetEntry((TR1__Timesheet_Detail__c)so);
            }
        }
        else if(Trigger.isAfter && Trigger.isDelete) {
            uow = DeleteNGTimesheetEntry((TR1__Timesheet_Detail__c)so);
        }

        if(uow != null) {
            m_uowList.add(uow);
        }
    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw-trigger: TR_TimesheetDetail_Helper::execute -> so = ' + so + ', oldSo = ' + oldSo);
    }

    private SObjectUnitOfWork CreateNGTimesheetEntry(TR1__Timesheet_Detail__c timesheetDetail) {
        System.debug('bw: TR_TimesheetDetail_Helper.CreateNGTimesheetEntry fired');
        return TimesheetEntryGateway.create(timesheetDetail);
    }

    private SObjectUnitOfWork DeleteNGTimesheetEntry(TR1__Timesheet_Detail__c tr1TimesheetDetail) {
        system.debug('bw-trigger: DeleteNGTimesheet -> fired');
        return TimesheetEntryGateway.deleteBySourceObjectId(tr1TimesheetDetail.Id);
    }

}
public with sharing class TimesheetEntryHelper 
    extends BaseTriggerHelper
{
    public TimesheetEntryHelper() {

    }

    public override void execute(SObject so) {
        system.debug('bw-trigger: TimesheetEntryHelper::' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);

        NG_Timesheet_Entry__c te = (NG_Timesheet_Entry__c) so;
      
        if(Trigger.isBefore && Trigger.isInsert) {
            setRecordName(te);
        }

    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw-trigger: TimesheetEntryHelper::execute -> so = ' + so + ', oldSo = ' + oldSo);

        if(Trigger.isBefore && (Trigger.isUpdate)){
            synchronize((NG_Timesheet_Entry__c)so);
        } 
       
    }


    private void setRecordName(NG_Timesheet_Entry__c timesheetEntry) {
        System.debug('bw-trigger: TimesheetEntryHelper.setRecordName - > timesheetEntry = ' + timesheetEntry);

        if(timesheetEntry.Day__c != null && timesheetEntry.Date__c != null) {
            timesheetEntry.Name =  timesheetEntry.Day__c + ' - ' + (((datetime) timesheetEntry.Date__c)).addDays(1).format('MM/dd/yyyy');
        }
    }

    private void synchronize(NG_Timesheet_Entry__c timesheetEntry) {
        System.debug('bw-trigger: TimesheetEntryHelper.synchronize - > timesheetEntry = ' + timesheetEntry);

        if(String.valueOf(timesheetEntry.Name).startsWith(timesheetEntry.Id)){
            setRecordName(timesheetEntry);
        }
    }

}
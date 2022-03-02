public without sharing class TimesheetHelper 
    extends BaseTriggerHelper
{
    public TimesheetHelper() {

    }

    public override void execute(SObject so) {
        system.debug('bw-trigger: TimesheetHelper::execute -> TriggerType = ' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);

        NG_Timesheet__c ts = (NG_Timesheet__c) so;
        
        if(Trigger.isBefore && Trigger.isInsert) {
            setRecordName(ts);
        }

    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw-trigger: TimesheetHelper::execute -> so = ' + so + ', oldSo = ' + oldSo);
    }

    private void setRecordName(NG_Timesheet__c timesheet) {
        if(timesheet != null && timesheet.Week_End__c != null) {
            string acctName = TimesheetGateway.getAccountNameFromTimesheet(timesheet);

            if(acctName != null) {
                timesheet.Name =  (acctName.length() > 55 ? acctName.substring(0,55) : acctName) + 
                                ' - Week Ending ' + 
                                (((datetime) timesheet.Week_End__c))
                                    .addDays(1).format('MM/dd/yyyy');
            }
            else {
                timesheet.Name =  'Week Ending ' + 
                                (((datetime) timesheet.Week_End__c))
                                    .addDays(1).format('MM/dd/yyyy');                
            }
        }
    }

}
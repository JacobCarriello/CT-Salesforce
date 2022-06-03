/*
Acc-Product Team 1:10/3/2017: W-008217 - TR core - Timesheet generation based on week end from Closing Report: Scheduler class
*************************************************************************************************************/
global class ScheduleTimesheetCreationByWeekending implements Schedulable{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    public Boolean flag=false;
    public Date sow;
    public Date eow;
    public String recordId;
    global ScheduleTimesheetCreationByWeekending(){}
    global ScheduleTimesheetCreationByWeekending(String recordId){
        this.recordId = recordId;
    }
    global void execute(SchedulableContext sc) {  
        sow = Date.today().tostartofWeek() + 1;
        eow = sow.addDays(6);
        
        String sowstring = Datetime.newInstance(sow.year(), sow.month(), sow.day()).format('yyyy-MM-dd');
        String eowstring = Datetime.newInstance(eow.year(), eow.month(), eow.day()).format('yyyy-MM-dd');

        //Id crconsultingId = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get(label.Consulting).getRecordTypeId();
       /* String query = 'SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,'+
                    'TR1__Timesheet_Approver__c,TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c,TR1__Pay_Rate__c,'+ 
                    'TR1__Payroll_Type__c,TR1__Week_Ending__c,TR1__Week_Start__c, (SELECT Id, Name, TRSCHED__Work_Shift_Location_lkId__r.Timesheet_Approver__c, TRSCHED__WeekEndDate__c, TRSCHED__Schedule_Date__c FROM TRSCHED__ClosingReportSchedules__r) FROM TR1__Closing_Report__c WHERE ';
        if(String.isNotBlank(recordId))
            query += ' Id=\'' + recordId +'\' AND TR1__Generate_Timesheet__c = true AND TR1__Assignment_Ended__c = \'No\' AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';
        else
            query += ' TR1__Generate_Timesheet__c = true AND TR1__Assignment_Ended__c = \'No\' AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';
        */
        list<String>  recordTypeNames = String.isBlank(Label.CR_RecordTypes_for_Timesheets)?new list<String>(): String.valueOf(Label.CR_RecordTypes_for_Timesheets).split('; ');
       
        String query = 'SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,'+
                    'TR1__Timesheet_Approver__c,TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c,TR1__Pay_Rate__c,'+ 
                    'TR1__Payroll_Type__c,TR1__Week_Ending__c,TR1__Week_Start__c,'
                    +' (SELECT Id, Name, lastmodifieddate,TRSCHED__Work_Shift_Location_lkId__r.Timesheet_Approver__c, TRSCHED__WeekEndDate__c, TRSCHED__Schedule_Date__c '+
                       +' FROM TRSCHED__ClosingReportSchedules__r '+
                       +' WHERE TRSCHED__Schedule_Date__c >= ' + sowstring + ' and TRSCHED__Schedule_Date__c <= ' + eowstring +
                      +'  ) FROM TR1__Closing_Report__c WHERE ';
        
        if(recordTypeNames != null && recordTypeNames.size() > 0){
             Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName();
            String recordTypeIds = '';
             for(String rtName:recordTypeNames){
                 if(recordTypes.get(rtName).getRecordTypeId() != null){
                      recordTypeIds += '\''+recordTypes.get(rtName).getRecordTypeId()+ '\', ';
                 }                 
             }
             if(!String.isBlank(recordTypeIds)){ 
                recordTypeIds = recordTypeIds.removeEnd(', ');
                 query += ' RecordTypeId in ('+recordTypeIds+') and ';
             } 
               
        }
        
        query += ' TR1__Generate_Timesheet__c = true AND TR1__Assignment_Ended__c = \'No\' AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))';
        system.debug('*******query*************'+query);
        system.debug('bw: TR1__Generate_Timesheet__c = true AND TR1__Assignment_Ended__c = \'No\' AND ((TR1__Start_Date__c <= ' + sowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)) OR (TR1__Start_Date__c >= ' + sowstring + ' AND TR1__Start_Date__c <= ' + eowstring + ' AND (TR1__End_Date__c >= ' + sowstring + ' OR TR1__End_Date__c = null)))');
        ID batchprocessid = Database.executeBatch(new CreateTimeSheetsByWeekending(query),3);
    }
   
}
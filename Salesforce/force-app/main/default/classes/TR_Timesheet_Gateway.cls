public without sharing class TR_Timesheet_Gateway {
    public static TR1__Timesheet__c fetch(Id timesheetId) {
        List<TR1__Timesheet__c> timesheets = [SELECT Id, TR1__Consultant__c, 
                                              NG_Portal_Status__c, TR1__Week_Ending__c,
                                              Work_Shift_Location__c, TR1__Approver__c
                                       FROM TR1__Timesheet__c 
                                       WHERE Id = :timesheetId 
                                       LIMIT 1];

        if(timesheets.size()> 0) {
            return timesheets[0];
        }
        
        return null;
    }

    public static Id fetchWorkLocationId (Id timesheetId) {
        TR1__Timesheet__c timesheet = [SELECT Work_Shift_Location__c 
                                       FROM TR1__Timesheet__c 
                                       WHERE Id = :timesheetId 
                                       LIMIT 1];
        
        return timesheet.Work_Shift_Location__c;
    }

    public static TR1__Timesheet__c synchronize(NG_Timesheet__c ngTimesheet) {
        system.debug('bw: TR_Timesheet_Gateway.synchronize -> ngTimesheet = ' + ngTimesheet);
        TR1__Timesheet__c timesheet = [SELECT NG_Portal_Status__c, 
                                       		  TR1__Approver__c, 
                                       		  TR1__Approver_First_Name__c, 
                                       		  TR1__Timesheet_Approver_Email__c, 
                                       		  TR1__Approvers_Notes__c, 
                                       		  TR1__Consultant_Email__c,
                                       		  TR1__Consultant_Name__c, 
                                       		  NG_Consultant_Name__c, 
                                       		  Worksite_Location__c,
                                       		  TR1__Week_Ending__c,
                                              NG_Total_Weekly_Hours__c,
                                              NG_Total_Weekly_Overtime_Hours__c,
                                              Overtime_Threshold_Type__c
                                       FROM TR1__Timesheet__c 
                                       WHERE Id = :ngTimesheet.Source_Object_ID__c];
        
        if(timesheet != null) {
            timesheet.NG_Portal_Status__c = ngTimesheet.Status__c;
            timesheet.TR1__Approvers_Notes__c = ngTimesheet.Rejection_Reason__c;
            timesheet.NG_UUID__c = ngTimesheet.NG_UUID__c;
            timesheet.NG_Portal_Submitted__c = true;
            update timesheet;
            system.debug('bw: TR_Timesheet_Gateway.synchronize -> timesheet = ' + timesheet);
        }
        return timesheet;
    }
}
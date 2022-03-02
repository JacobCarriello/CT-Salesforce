public without sharing class TR_ShiftWork_Gateway {
    public static TR1__ShiftWork__c fetch(Id shiftWorkId) {
        return [SELECT Id, TR1__End_Time__c, TR1__EndDateTime__c, TR1__Rate__c,
                       TR1__Start_Time__c, TR1__StartDateTime__c, TR1__TimeType__c,
                       TR1__Timesheet__c, TR1__TimesheetDetail__c
                FROM TR1__ShiftWork__c
                WHERE Id = :shiftWorkId];
    }
    
    public static TR1__ShiftWork__c fetchShiftWorkForTimesheetDetailId(Id timesheetDetailId) {
        return [SELECT Id FROM TR1__ShiftWork__c WHERE TR1__TimesheetDetail__c = :timesheetDetailId];
    }

    public static void save(TR1__ShiftWork__c shiftWork) {
        update shiftWork;
    }

    public static Id save(Id sourceObjectId, Id timesheetId, Id timesheetDetailId, Id rateId, string oncallBeeper, string inTime, Date outDate, string outTime, Decimal hours) {
        system.debug('bw: TR_ShiftWork_Gateway.save(' + sourceObjectId + ', ' + timesheetId + ', ' + timesheetDetailId + ', ' + rateId + ', ' + inTime + ', ' + outTime + ', ' + hours + ')'); 
        TR1__ShiftWork__c shiftWork = new TR1__ShiftWork__c();

        if(sourceObjectId != null) {
            system.debug('bw: TR_ShiftWork_Gateway.save -> sourceObjectId is NOT null');
            shiftWork = [SELECT Id, 
                                NG_End_Date__c, TR1__End_Time__c, TR1__Start_Time__c,
                                TR1__TimesheetDetail__c, TR1__Timesheet__c,
                                NG_On_Call_Beeper__c,
                                TR1__TimeType__c, TR1__Rate__c, TR1__Hours__c
                         FROM TR1__ShiftWork__c 
                         WHERE Id = :sourceObjectId
                         LIMIT 1];
        }
        else {
            system.debug('bw: TR_ShiftWork_Gateway.save -> sourceObjectId IS null');
            shiftWork.TR1__TimesheetDetail__c = timesheetDetailId;
            shiftWork.TR1__Timesheet__c = timesheetId;
        }

        shiftWork.TR1__Start_Time__c = inTime;
        shiftWork.NG_End_Date__c = outDate;
        shiftWork.TR1__End_Time__c = outTime;
        shiftWork.TR1__Hours__c = hours;
        shiftWork.TR1__Rate__c = rateId;
        if(oncallBeeper != null) {
            shiftWork.NG_On_Call_Beeper__c = oncallBeeper;
        }

        system.debug('bw: TR_ShiftWork_Gateway.save -> upsert shiftWork = ' + shiftWork);
        try {
            upsert shiftWork;
        }
        catch(Exception e) {
            system.debug('bw: TR_ShiftWork_Gateway.save -> e = ' + e);
        }
        system.debug('bw: TR_ShiftWork_Gateway.save -> shiftWork.Id = ' + shiftWork.Id);
        return shiftWork.Id;
    }
}
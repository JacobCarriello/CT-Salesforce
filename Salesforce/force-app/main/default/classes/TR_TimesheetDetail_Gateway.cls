public without sharing class TR_TimesheetDetail_Gateway {
    public static TR1__Timesheet_Detail__c fetch(Id timesheetDetailId) {
        return [SELECT Id, TR1__Date__c, TR1__Day__c, TR1__Overtime_Hours__c,
                       TR1__Regular_Hours__c, TR1__Timesheet__c,
                       NG_Unpaid_Break_Time__c, NG_Shift_Notes__c,
                       NG_Is_Multi_Day__c, NG_Did_Not_Work__c
                FROM TR1__Timesheet_Detail__c
                WHERE Id = :timesheetDetailId];
    }

    public static List<TR1__Timesheet_Detail__c> fetchTimesheetDetailsForTimesheetId(Id timesheetId) {
        List<TR1__Timesheet_Detail__c> details = [SELECT Id, TR1__Date__c, TR1__Day__c, 
                                                         TR1__Overtime_Hours__c, TR1__Regular_Hours__c, TR1__Timesheet__c,
                                                         NG_Unpaid_Break_Time__c, NG_Shift_Notes__c,
                                                         NG_Is_Multi_Day__c
                FROM TR1__Timesheet_Detail__c
                WHERE TR1__Timesheet__c = :timesheetId
                 AND Shift_Status__c != 'Tentative'
                 AND Shift_Status__c != 'Cancelled'];

        if(details.size() > 0 ) {
            return details;
        }

        return null;
    }

    public static Id create(TR1__Timesheet_Detail__c timesheetDetail) {
        insert timesheetDetail;

        return timesheetDetail.Id;
    }

    public static void save(TR1__Timesheet_Detail__c timesheetDetail) {
        update timesheetDetail;
    }
}
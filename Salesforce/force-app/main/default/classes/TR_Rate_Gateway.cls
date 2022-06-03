public with sharing class TR_Rate_Gateway {
    /*
    public static Id fetchIdFromAccount(Id accountId, String timeSubType) {
        TR1__Rate__c rate = [SELECT Id 
                    FROM TR1__Rate__c 
                    WHERE TR1__Account__c = :accountId 
                        AND NG_Time_Sub_Type__c = :timeSubType
                    LIMIT 1];
        
        if(rate != null) {
            return rate.Id;
        }

        return null;
    }
    */

    public static Id fetchIdFromTimesheet(Id timesheetId, String timeSubType) {
        TR1__Rate__c rate = [SELECT Id 
                    FROM TR1__Rate__c 
                    WHERE TR1__Timesheet__c = :timesheetId 
                        AND NG_Time_Sub_Type__c = :timeSubType
                    LIMIT 1];
        
        if(rate != null) {
            return rate.Id;
        }

        return null;
    }
}
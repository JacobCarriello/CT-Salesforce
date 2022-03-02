public without sharing class TimesheetDetailsController {
    public Id TR_Timesheet_ID {get;set;}

    public List<TimesheetDetail> getDetails() {
        system.debug('bw: TR_Timesheet_ID = ' + TR_Timesheet_ID);

        List<NG_Timesheet_Entry__c> entries = [SELECT Id, Total_Callback_Hours__c,
                                                      Default_Slot__r.Source_Object_ID__c,
                                                      Default_Slot__r.In_Date__c, Default_Slot__r.In_Time__c,
                                                      Default_Slot__r.Out_Date__c, Default_Slot__r.Out_Time__c,
                                                      Default_Slot__r.Custom_On_Call_Beeper__c, Default_Slot__r.Is_Multi_Day__c,
                                                      Default_Slot__r.Unpaid_Break_Time__c, Default_Slot__r.Note__c
                                               FROM NG_Timesheet_Entry__c
                                               WHERE Timesheet__r.Source_Object_ID__c = :TR_Timesheet_ID];
        system.debug('bw: entries = ' + entries);

        Map<Id,TimesheetDetail> dts = new Map<Id,TimesheetDetail>();
        for(NG_Timesheet_Entry__c entry : entries) {
            TimesheetDetail d = new TimesheetDetail();
            if(isEntryValid(entry)) {
                d.inDate = Date.valueOf(entry.Default_Slot__r.In_Date__c).format();
                d.inTime = to12Hour(entry.Default_Slot__r.In_Time__c);
                d.outDate = Date.valueOf(entry.Default_Slot__r.Out_Date__c).format();
                d.outTime = to12Hour(entry.Default_Slot__r.Out_Time__c);
                d.unpaidBreakHours = entry.Default_Slot__r.Unpaid_Break_Time__c;
                d.totalCBHours = entry.Total_Callback_Hours__c;
                d.note = entry.Default_Slot__r.Note__c;
                d.onCall = entry.Default_Slot__r.Custom_On_Call_Beeper__c;
                d.isMultiDay = (entry.Default_Slot__r.Is_Multi_Day__c ? 'Yes' : 'No');
                dts.put(entry.Default_Slot__r.Source_Object_ID__c, d);
            }
        }
        system.debug('bw: dts = ' + dts);

        List<TR1__ShiftWork__c> trss = [SELECT Id, NG_Regular_Hours__c, NG_Total_Shift_Work_OT__c
                                        FROM TR1__ShiftWork__c
                                        WHERE Id in :dts.keySet()];
        system.debug('bw: trss = ' + trss);
        
        for(TR1__ShiftWork__c sw : trss) {
            TimesheetDetail d = dts.get(sw.Id);
            d.totalRegHours = sw.NG_Regular_Hours__c;
            d.totalOTHours = sw.NG_Total_Shift_Work_OT__c;
        }

        system.debug('bw: returning -> ' + dts.values());
        return dts.values();
    }

    private boolean isEntryValid(NG_Timesheet_Entry__c entry) {
        return (entry.Default_Slot__r.In_Date__c != null) &&
               (entry.Default_Slot__r.In_Time__c != null) &&
               (entry.Default_Slot__r.Out_Date__c != null) &&
               (entry.Default_Slot__r.Out_Time__c != null);
    }
    
    private string to12Hour(string time24) {
        List<string> slots = time24.split(':');
        string hour = slots[0];
        integer hourInt = integer.valueOf(hour);
        string minute = slots[1];
        string ampm = 'AM';

        if (hourInt >= 12){
            ampm = 'PM';
        }

        if(hourInt>12) {
            hourInt -= 12;
        }

        return string.valueOf(hourInt) + ':' + minute + ' ' + ampm;
    }

    public class TimesheetDetail {
        public string inDate {get;set;}
        public string inTime {get;set;}
        public string outDate {get;set;}
        public string outTime {get;set;}
        public decimal unpaidBreakHours {get;set;}
        public decimal totalRegHours {get;set;}
        public decimal totalOTHours {get;set;}
        public decimal totalCBHours {get;set;}
        public string note {get;set;}
        public string onCall {get;set;}
        public string isMultiDay {get;set;}
    }
}
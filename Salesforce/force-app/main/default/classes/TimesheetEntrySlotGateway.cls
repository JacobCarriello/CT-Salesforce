public without sharing class TimesheetEntrySlotGateway {
    public static NG_Timesheet_Entry_Slot__c fetch(Id slotId) {
        system.debug('bw: TimesheetEntrySlotGateway.fetch -> slotId = ' + slotId);
         List<NG_Timesheet_Entry_Slot__c> slots = [SELECT Id, Timesheet_Entry__r.Date__c, Timesheet_Entry__r.Day__c, 
                                                         Timesheet_Entry_Source_Object_ID__c,
                                                         Timesheet_Source_Object_ID__c,
                                                         In_Time__c, In_Date__c,
                                                         Out_Time__c, Out_Date__c,
                                                         Hours__c, Unpaid_Break_Time__c,
                                                         Note__c, Custom_On_Call_Beeper__c,
                                                         Custom_Callback_Hours__c, Custom_Callback_In_Time__c,
                                                         Custom_Callback_In_Date__c, Custom_Callback_Out_Time__c,
                                                         Custom_Callback_Out_Date__c, Status__c,
                                                         Shift__c, Is_Multi_Day__c, Source_Object_ID__c
                                            FROM NG_Timesheet_Entry_Slot__c
                                            WHERE Id = :slotId 
                                            LIMIT 1];
        
        if(slots.size()>0){
            if(slots[0].Timesheet_Entry__r.Date__c != null) {
                setDate(slots[0].In_Date__c, slots[0].Timesheet_Entry__r.Date__c.format());
                setDate(slots[0].Out_Date__c, slots[0].Timesheet_Entry__r.Date__c.format());
                setDate(slots[0].Custom_Callback_In_Date__c, slots[0].Timesheet_Entry__r.Date__c.format());
                setDate(slots[0].Custom_Callback_Out_Date__c, slots[0].Timesheet_Entry__r.Date__c.format());
            }

            return slots[0];
        }

        return null;  
    }

    public static List<NG_Timesheet_Entry_Slot__c> fetchTimesheetEntrySlotsForEntry(Id entryId) {
        List<NG_Timesheet_Entry_Slot__c> slots = [SELECT Id, Timesheet_Entry__r.Date__c, Timesheet_Entry__r.Day__c, 
                                                         Timesheet_Entry_Source_Object_ID__c,
                                                         Timesheet_Source_Object_ID__c,
                                                         Hours__c, In_Time__c, In_Date__c, 
                                                         Out_Time__c, Out_Date__c,
                                                         Unpaid_Break_Time__c, Note__c, Custom_On_Call_Beeper__c,
                                                         Custom_Callback_Hours__c, Custom_Callback_In_Time__c,
                                                         Custom_Callback_In_Date__c, Custom_Callback_Out_Time__c,
                                                         Custom_Callback_Out_Date__c, Status__c,
                                                         Shift__c, Is_Multi_Day__c, Source_Object_ID__c
                                                  FROM NG_Timesheet_Entry_Slot__c
                                                  WHERE Timesheet_Entry__c = :entryId];

        return slots;
    }

    public static NG_Timesheet_Entry_Slot__c create(NG_Timesheet_Entry__c entry, Boolean isMultiDay) {
        NG_Timesheet_Entry_Slot__c slot = new NG_Timesheet_Entry_Slot__c();
        slot.Timesheet_Entry__c =  entry.Id;
        slot.Is_Multi_Day__c = isMultiDay;
        insert slot;

        return slot;
    }
    public static NG_Timesheet_Entry_Slot__c create(NG_Timesheet_Entry__c entry){
        return create(entry, false);
    }

    public static void save(NG_Timesheet_Entry_Slot__c slot) {
        system.debug('bw: TimesheetEntrySlotGateway.save -> slot = ' + slot);
        update slot;

        NG_Timesheet_Entry__c entry = TimesheetEntryGateway.fetch(slot.Timesheet_Entry__c);
        if(slot.Date__c != null && slot.Day__c != null) {
            entry.Name = slot.Day__c + ' - ' + slot.Date__c.format();
            entry.Day__c = slot.Day__c;
            entry.Date__c = slot.Date__c;
            TimesheetEntryGateway.save(entry);
        }
    }

    private static void setDate(string dateProperty, string dateValue){
        if(dateProperty == null || dateProperty == ''){
            dateProperty = dateValue;
        }
    }

    public static void deleteBySourceObjectId(Id sourceObjectId) {
        try {
            NG_Timesheet_Entry_Slot__c timesheetEntrySlot = [SELECT Id FROM NG_Timesheet_Entry_Slot__c WHERE Source_Object_ID__c = :sourceObjectId];
            delete timesheetEntrySlot;
        }
        catch(Exception e) {
            system.debug('bw: deleteBySourceObjectId -> e = ' + e);
        }
    }
}
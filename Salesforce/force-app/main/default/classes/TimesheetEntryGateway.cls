public without sharing class TimesheetEntryGateway {
    public static NG_Timesheet_Entry__c fetch(Id entryId) {
        List<NG_Timesheet_Entry__c> entries = [SELECT Id, Name, Date__c, Day__c, Total_Slots__c,
                                                      Default_Slot__c, Default_Slot__r.Is_Multi_Day__c,
                                                      Max_Date__c, Status__c, Source_Object_ID__c,
                                                      Total_Hours__c, Total_Callback_Hours__c
                                               FROM NG_Timesheet_Entry__c
                                               WHERE Id = :entryId 
                                               LIMIT 1];
        
        if(entries.size()>0) {
            setDefaultSlot(entries);
            return entries[0];
        }

        return null;
    }

    public static NG_Timesheet_Entry__c fetchForSourceObjectId(String sourceObjectId) {
         List<NG_Timesheet_Entry__c> entries = [SELECT Id, Name, Date__c, Day__c, Total_Slots__c,
                                                      Default_Slot__c, Default_Slot__r.Is_Multi_Day__c,
                                                      Max_Date__c, Status__c,
                                                      Total_Hours__c, Total_Callback_Hours__c
                                               FROM NG_Timesheet_Entry__c
                                               WHERE Source_Object_ID__c = :sourceObjectId 
                                               LIMIT 1];
        
        system.debug('bw:  fetchForSourceObjectId -> entries = ' + entries);

        if(entries.size()>0) {
            setDefaultSlot(entries);
            return entries[0];
        }

        return null;       
    }

    public static List<NG_Timesheet_Entry__c> fetchTimesheetEntriesForTimesheet(Id timesheetId) {
        List<NG_Timesheet_Entry__c> entries = [SELECT Id, Name, Date__c, Day__c, Total_Slots__c,
                                                      Default_Slot__c, Default_Slot__r.Is_Multi_Day__c,
                                                      Default_Slot__r.Did_Not_Work__c, Default_Slot__r.Hours__c,
                                                      Default_Slot__r.In_Time__c, Default_Slot__r.In_Date__c,
                                                      Default_Slot__r.Out_Time__c, Default_Slot__r.Out_Date__c,
                                                      Default_Slot__r.Unpaid_Break_Time__c, Default_Slot__r.Custom_On_Call_Beeper__c,
                                                      Default_Slot__r.Custom_Callback_In_Time__c, Default_Slot__r.Custom_Callback_In_Date__c,
                                                      Default_Slot__r.Custom_Callback_Out_Time__c, Default_Slot__r.Custom_Callback_Out_Date__c,
                                                      Default_Slot__r.Custom_Callback_Hours__c, Default_Slot__r.Note__c,
                                                      Total_Hours__c, Total_Callback_Hours__c, Status__c,
                                                      Source_Object_ID__c
                                               FROM NG_Timesheet_Entry__c
                                               WHERE Timesheet__c = :timesheetId
                                               ORDER BY Date__c];
        
        setDefaultSlot(entries);
        return entries;
    }

    public static SObjectUnitOfWork create(TR1__Timesheet_Detail__c timesheetDetail) {
		List<Schema.SObjectType> MY_SOBJECTS = 
			new Schema.SObjectType[] {
				NG_Timesheet__c.SObjectType,
                NG_Timesheet_Entry__c.SObjectType,
                NG_Timesheet_Entry_Slot__c.SObjectType
			};
		SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);

        NG_Timesheet_Entry__c entry = new NG_Timesheet_Entry__c();
        entry.Date__c = timesheetDetail.TR1__Date__c;
        entry.Day__c = timesheetDetail.TR1__Day__c;
        entry.Source_Object_ID__c = timesheetDetail.Id;
        NG_Timesheet__c timesheet = TimesheetGateway.getTimesheetFromSourceObjectId(timesheetDetail.TR1__Timesheet__c);
        if(timesheet == null) {
            //no NG timesheet exists for this timesheet, create one to sync with
            TR1__Timesheet__c t = TR_Timesheet_Gateway.fetch(timesheetDetail.TR1__Timesheet__c);
            timesheet = new NG_Timesheet__c();
            timesheet.Employee__c = t.TR1__Consultant__c;
            timesheet.Timesheet_Approver__c = t.TR1__Approver__c;
            timesheet.Status__c = t.NG_Portal_Status__c;
            timesheet.Week_End__c = t.TR1__Week_Ending__c;
            timesheet.Work_Location__c = t.Work_Shift_Location__c;
            timesheet.Source_Object_ID__c = t.Id;
            uow.registerNew(timesheet);
        }
        uow.registerNew(entry, NG_Timesheet_Entry__c.Timesheet__c, timesheet);

        NG_Timesheet_Entry_Slot__c slot = new NG_Timesheet_Entry_Slot__c();
        slot.Is_Multi_Day__c = timesheetDetail.NG_Is_Multi_Day__c;
        uow.registerNew(slot, NG_Timesheet_Entry_Slot__c.Timesheet_Entry__c, entry);

        uow.registerRelationship(entry, NG_Timesheet_Entry__c.Default_Slot__c, slot);

        system.debug('bw: TimesheetEntryGateway.create -> entry = ' + entry);
        system.debug('bw: TimesheetEntryGateway.create -> uow = ' + uow);

        return uow;
    }

    public static void save(NG_Timesheet_Entry__c entry) {
        update entry;
    }

    public static SObjectUnitOfWork deleteBySourceObjectId(Id sourceObjectId) {
		List<Schema.SObjectType> MY_SOBJECTS = 
			new Schema.SObjectType[] {
				NG_Timesheet_Entry__c.SObjectType
			};
		SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
    
        NG_Timesheet_Entry__c timesheetEntry = [SELECT Id FROM NG_Timesheet_Entry__c WHERE Source_Object_ID__c = :sourceObjectId];
        uow.registerDeleted(timesheetEntry);

        return uow;
    }

    public static void synchronize(NG_Timesheet__c ngt, TR1__Timesheet__c tr1t) {
        List<NG_Timesheet_Entry__c> entries  = TimesheetEntryGateway.fetchTimesheetEntriesForTimesheet(ngt.Id);
        if(entries.size() == 0) {
            //entries are out of sync, sync them.
            List<TR1__Timesheet_Detail__c> details = TR_TimesheetDetail_Gateway.fetchTimesheetDetailsForTimesheetId(tr1t.Id);
            if(details != null && details.size() > 0) {
                for(TR1__Timesheet_Detail__c detail : details) {
                    create(detail);
                }
            }
        }

    }

    private static void setDefaultSlot(List<NG_Timesheet_Entry__c> entries){
        boolean updateRecords = false;

        for(NG_Timesheet_Entry__c entry : entries) {
            if(entry.Default_Slot__c == null && entry.Total_Slots__c == 1) {
                List<NG_Timesheet_Entry_Slot__c> slots = [SELECT Id FROM NG_Timesheet_Entry_Slot__c where Timesheet_Entry__c = :entry.Id];
                entry.Default_Slot__c = slots[0].Id;
                updateRecords = true;
            }
        }

        if(updateRecords)
            update entries;
    }
}
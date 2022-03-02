public without sharing class TimesheetGateway {
    public static NG_Timesheet__c fetch(Id timesheetId) {
        NG_Timesheet__c timesheet = [SELECT Id, Work_Location__c, Work_Location__r.Name,
                                            Status__c, Week_Start__c, Week_End__c,
                                            Source_Object_ID__c, Rejection_Reason__c,
                                     		Employee__c, Employee__r.Name,NG_UUID__c, 
                                     		Timesheet_Approver__r.FirstName,Timesheet_Approver__r.Email,
                                     		(SELECT ID, Name, Day__c, Date__c, Did_Not_Work__c, Total_Hours__c FROM Timesheet_Entries__r),
                                            (SELECT Id, Hours__c, Unpaid_Break_Time__c, Timesheet__c, Timesheet_Entry__c,
                                                    Date__c, Day__c, Shift__c, In_Time__c, In_Date__c, Is_Multi_Day__c,
                                                    Out_Time__c, Out_Date__c, Note__c
                                            FROM Timesheet_Entry_Slots__r
                                            ORDER BY Id)
                                     FROM NG_Timesheet__c
                                     WHERE Id = :timesheetId];
        
        return timesheet;
    }

    public static NG_Timesheet__c fetchTimesheetForTRID(Id trTimesheetId) {
        NG_Timesheet__c timesheet = [SELECT Id, Work_Location__c, Work_Location__r.Name,
                                            Status__c, Week_Start__c, Week_End__c,
                                            Source_Object_ID__c, Rejection_Reason__c,
                                     		Employee__c, Employee__r.Name,NG_UUID__c, 
                                     		Timesheet_Approver__r.FirstName,Timesheet_Approver__r.Email,
                                     		(SELECT ID, Name, Day__c, Date__c, Did_Not_Work__c, Total_Hours__c, Total_Callback_Hours__c,
                                                    Default_Slot__r.In_Time__c, Default_Slot__r.Out_Time__c, Default_Slot__r.Is_Multi_Day__c, 
                                                    Default_Slot__r.In_Date__c, Default_Slot__r.Out_Date__c,Default_Slot__r.Custom_On_Call_Beeper__c,
                                                    Default_Slot__r.Unpaid_Break_Time__c, Default_Slot__r.Note__c 
                                             FROM Timesheet_Entries__r),
                                            (SELECT Id, Hours__c, Unpaid_Break_Time__c, Timesheet__c, Timesheet_Entry__c,
                                                    Date__c, Day__c, Shift__c, In_Time__c, In_Date__c, Is_Multi_Day__c,
                                                    Out_Time__c, Out_Date__c, Note__c
                                            FROM Timesheet_Entry_Slots__r
                                            ORDER BY Id)
                                     FROM NG_Timesheet__c
                                     WHERE Source_Object_ID__c = :trTimesheetId];
        
        return timesheet;        
    }

    public static nuTimesheet fetchTimesheet(Id timesheetId) { 
        system.debug('bw: TimesheetGateway.fetchTimesheet called');
        system.debug('bw: timesheetId = ' + timesheetId);

        nuTimesheet timesheet;
        NG_Timesheet__c timesheetRec;

        timesheetRec = fetchTimesheetForTRID(timesheetId);

        timesheet = convertTimesheetRecordToDTO(timesheetRec);

        system.debug('bw: call repo.fetchTimesheet and return results');
        return timesheet;        
    }

    public static List<nuTimesheet> fetchTimesheetsForApprover(Id approverId, string statusFilter) {
        system.debug('bw: TimesheetGateway::fetchTimesheetsForApprover called');
        List<nuTimesheet> timesheets = new List<nuTimesheet>();
        List<NG_Timesheet__c> ts = new List<NG_Timesheet__c>();
        
        if(statusFilter != null && statusFilter != '' && statusFilter != 'All') {
            ts = [SELECT Id, Work_Location__c, Work_Location__r.Name,
                         Status__c, Week_Start__c, Week_End__c,
                         Source_Object_ID__c, Rejection_Reason__c,
                         Employee__c, Employee__r.Name,NG_UUID__c, 
                         Timesheet_Approver__r.FirstName,Timesheet_Approver__r.Email,
                         (SELECT ID, Name, Day__c, Date__c, Did_Not_Work__c, Total_Hours__c, Total_Callback_Hours__c,
                                 Default_Slot__r.In_Time__c, Default_Slot__r.Out_Time__c, Default_Slot__r.Is_Multi_Day__c, 
                                 Default_Slot__r.In_Date__c, Default_Slot__r.Out_Date__c,Default_Slot__r.Custom_On_Call_Beeper__c,
                                 Default_Slot__r.Unpaid_Break_Time__c, Default_Slot__r.Note__c 
                         FROM Timesheet_Entries__r ORDER BY ID),
                         (SELECT Id, Hours__c, Unpaid_Break_Time__c, Timesheet__c, Timesheet_Entry__c,
                                 Date__c, Day__c, Shift__c, In_Time__c, In_Date__c, Is_Multi_Day__c,
                                 Out_Time__c, Out_Date__c, Note__c
                         FROM Timesheet_Entry_Slots__r
                         ORDER BY Id)
                 FROM NG_Timesheet__c
                 WHERE Timesheet_Approver__c = :approverId
                     AND Status__c = :statusFilter
                 ORDER BY Week_End__c ASC];
        }
        else {
            ts = [SELECT Id, Work_Location__c, Work_Location__r.Name,
                         Status__c, Week_Start__c, Week_End__c,
                         Source_Object_ID__c, Rejection_Reason__c,
                         Employee__c, Employee__r.Name,NG_UUID__c, 
                         Timesheet_Approver__r.FirstName,Timesheet_Approver__r.Email,
                         (SELECT ID, Name, Day__c, Date__c, Did_Not_Work__c, Total_Hours__c, Total_Callback_Hours__c,
                                 Default_Slot__r.In_Time__c, Default_Slot__r.Out_Time__c, Default_Slot__r.Is_Multi_Day__c, 
                                 Default_Slot__r.In_Date__c, Default_Slot__r.Out_Date__c,Default_Slot__r.Custom_On_Call_Beeper__c,
                                 Default_Slot__r.Unpaid_Break_Time__c, Default_Slot__r.Note__c 
                          FROM Timesheet_Entries__r ORDER BY ID),
                         (SELECT Id, Hours__c, Unpaid_Break_Time__c, Timesheet__c, Timesheet_Entry__c,
                                 Date__c, Day__c, Shift__c, In_Time__c, In_Date__c, Is_Multi_Day__c,
                                 Out_Time__c, Out_Date__c, Note__c
                         FROM Timesheet_Entry_Slots__r
                         ORDER BY Id)
                FROM NG_Timesheet__c
                WHERE Timesheet_Approver__c = :approverId
                    AND Status__c IN ('Submitted', 'Approved', 'Rejected')
                ORDER BY Week_End__c];
        }  

        if(ts.size() > 0) {
            for(NG_Timesheet__c t:ts) {
                nuTimesheet timesheet = convertTimesheetRecordToDTO(t);
                timesheets.add(timesheet);
            }
        }
        
        return timesheets;
    }
    
    public static List<NG_Timesheet__c> fetchTimesheetsForContact(Id contactId, String statusFilter) {
        List<NG_Timesheet__c> timesheets;
        
        if(statusFilter != null && statusFilter != '' && statusFilter != 'All') {
            timesheets = [SELECT Id, Work_Location__c, Work_Location__r.Name,
                                                    Status__c, Week_Start__c, Week_End__c,
                                                    Source_Object_ID__c, Rejection_Reason__c, NG_UUID__c
                                                FROM NG_Timesheet__c
                                                WHERE Employee__c = :contactId
                                                    AND Status__c = :statusFilter
                          							AND id in (SELECT Timesheet__c
     														   FROM NG_Timesheet_Entry__c 
     														   WHERE Timesheet__r.Employee__c = :contactId)
                                                ORDER BY Week_End__c ASC];
        }
        else {
            timesheets = [SELECT Id, Work_Location__c, Work_Location__r.Name,
                                                    Status__c, Week_Start__c, Week_End__c,
                                                    Source_Object_ID__c, Rejection_Reason__c, NG_UUID__c
                                                FROM NG_Timesheet__c
                                                WHERE Employee__c = :contactId
                          							AND id in (SELECT Timesheet__c
     														   FROM NG_Timesheet_Entry__c 
     														   WHERE Timesheet__r.Employee__c = :contactId)
                         						ORDER BY Week_End__c];
        }

        system.debug('bw: fetchTimehseetsForContact -> timesheets = ' + timesheets);
        return timesheets;
    }

    public static void save(NG_Timesheet__c timesheet) {
        system.debug('bw: TimesheetGateway.save -> timesheet = ' + timesheet);
        update timesheet;
        TR1__Timesheet__c tr1TimeSheet = TR_Timesheet_Gateway.synchronize(timesheet);
    }

    public static nuServiceResult approveTimesheet(Id timesheetId, String usersName, String email) {
        nuServiceResult result = new nuServiceResult();

        NG_Timesheet__c timesheet = fetch(timesheetId);

        if(timesheet != null) {
            timesheet.Status__c = 'Approved';
            //timesheet.Approved_By__c = usersName;
            //timesheet.Approved_By_Email__c = email;
            //timesheet.Approved_On__c = datetime.now();
            timesheet.Rejection_Reason__c = '';
            Database.SaveResult dbResult = Database.update(timesheet);
            if(dbResult.isSuccess()) {
                TR1__Timesheet__c tr1TimeSheet = TR_Timesheet_Gateway.synchronize(timesheet);
                Map<string,object> resultParameters = new Map<string,object>();
                resultParameters.put('success', true);
                result.data = resultParameters;
            }
            else {
                System.debug('bw: errors = ' + dbResult.getErrors());
                result.error = dbResult.getErrors();
            }
        }

        return result;
    }

    public static nuServiceResult rejectTimesheet(Id timesheetId, String usersName, String email, String rejectReason) {
        nuServiceResult result = new nuServiceResult();

        NG_Timesheet__c timesheet = fetch(timesheetId);

        if(timesheet != null) {
            timesheet.Status__c = 'Rejected';
            //timesheet.Approved_By__c = usersName;
            //timesheet.Approved_By_Email__c = email;
            //timesheet.Approved_On__c = datetime.now();
            timesheet.Rejection_Reason__c = rejectReason;
            Database.SaveResult dbResult = Database.update(timesheet);
            if(dbResult.isSuccess()) {
                TR1__Timesheet__c tr1TimeSheet = TR_Timesheet_Gateway.synchronize(timesheet);
                Map<string,object> resultParameters = new Map<string,object>();
                resultParameters.put('success', true);
                result.data = resultParameters;
            }
            else {
                System.debug('bw: errors = ' + dbResult.getErrors());
                result.error = dbResult.getErrors();
            }
        }

        return result;
    }

    public static nuServiceResult validateApprovalToken(Id timesheetId, String token) {
        NG_Timesheet__c timesheet = fetchApprovalToken(timesheetId);

        nuServiceResult result = new nuServiceResult();
        Map<string,object> resultParameters = new Map<string,object>();
        resultParameters.put('tokenValid', (timesheet.NG_UUID__c == token));
        result.data = resultParameters;

        return result;
    }

    public static String getAccountNameFromTimesheet(NG_Timesheet__c timesheet) {
        return AccountGateway.getName(timesheet.Work_Location__c);
    }

    public static NG_Timesheet__c getTimesheetFromTR_Timesheet(TR1__Timesheet__c tr1Timesheet) {
        NG_Timesheet__c retVal = null;

        List<NG_Timesheet__c> timesheets = [SELECT Id, Employee__c,Status__c,Week_End__c,
                       Work_Location__c,Source_Object_ID__c 
                FROM NG_Timesheet__c 
                WHERE Source_Object_ID__c = :tr1Timesheet.Id];
        
        if(timesheets.size()!=0) {
            retVal = timesheets[0];
        }

        return retVal;
    }

    public static NG_Timesheet__c getTimesheetFromSourceObjectId(Id sourceObjectId) {
         NG_Timesheet__c retVal = null;

        List<NG_Timesheet__c> timesheets = [SELECT Id, Employee__c,Status__c,Week_End__c,
                       Work_Location__c,Source_Object_ID__c 
                FROM NG_Timesheet__c 
                WHERE Source_Object_ID__c = :sourceObjectId];
        
        if(timesheets.size()!=0) {
            retVal = timesheets[0];
        }

        return retVal;       
    }

    public static SObjectUnitOfWork deleteBySourceObjectId(Id sourceObjectId) {
		List<Schema.SObjectType> MY_SOBJECTS = 
			new Schema.SObjectType[] {
				NG_Timesheet__c.SObjectType
			};
		SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);

        try {
            NG_Timesheet__c timesheet = [SELECT Id FROM NG_Timesheet__c WHERE Source_Object_ID__c = :sourceObjectId];
            uow.registerDeleted(timesheet);

            return uow;
        }
        catch(Exception e) {
            system.debug('bw: deleteBySourceObjectId -> error = ' + e);
        }

        return null;
    }

    public static NG_Timesheet__c createDirect(TR1__Timesheet__c tr1Timesheet) {
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        timesheet.Employee__c = tr1Timesheet.TR1__Consultant__c;
        timesheet.Timesheet_Approver__c = tr1Timesheet.TR1__Approver__c;
        timesheet.Status__c = tr1Timesheet.NG_Portal_Status__c;
        timesheet.Week_End__c = tr1Timesheet.TR1__Week_Ending__c;
        timesheet.Work_Location__c = tr1Timesheet.Work_Shift_Location__c;
        timesheet.Source_Object_ID__c = tr1Timesheet.Id;
        insert timesheet;

        return timesheet;
    }

    public static SObjectUnitOfWork create (TR1__Timesheet__c tr1Timesheet) {
		List<Schema.SObjectType> MY_SOBJECTS = 
			new Schema.SObjectType[] {
				NG_Timesheet__c.SObjectType
			};
		SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);

        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        timesheet.Employee__c = tr1Timesheet.TR1__Consultant__c;
        timesheet.Timesheet_Approver__c = tr1Timesheet.TR1__Approver__c;
        timesheet.Status__c = tr1Timesheet.NG_Portal_Status__c;
        timesheet.Week_End__c = tr1Timesheet.TR1__Week_Ending__c;
        timesheet.Work_Location__c = tr1Timesheet.Work_Shift_Location__c;
        timesheet.Source_Object_ID__c = tr1Timesheet.Id;
        uow.registerNew(timesheet);

        return uow;
    }

    public static List<SObjectUnitOfWork> synchronize(TR1__Timesheet__c tr1Timesheet) {
        return synchronize(tr1Timesheet, false);
    }

    public static List<SObjectUnitOfWork> synchronize(TR1__Timesheet__c tr1Timesheet,Boolean isMultiDay) {
        List<SObjectUnitOfWork> uows = new List<SObjectUnitOfWork>();
        
		List<Schema.SObjectType> MY_SOBJECTS = 
			new Schema.SObjectType[] {
				NG_Timesheet__c.SObjectType,
				NG_Timesheet_Entry__c.SObjectType,
				NG_Timesheet_Entry_Slot__c.SObjectType
			};
		SObjectUnitOfWork uow = new SObjectUnitOfWork(MY_SOBJECTS);
        SObjectUnitOfWork uow2 = new SObjectUnitOfWork(MY_SOBJECTS);

        NG_Timesheet__c timesheet = getTimesheetFromTR_Timesheet(tr1Timesheet);
        if(timesheet == null) {
            timesheet = createDirect(tr1Timesheet);
        }

        timesheet.Employee__c = tr1Timesheet.TR1__Consultant__c;
        timesheet.Status__c = tr1Timesheet.NG_Portal_Status__c;
        timesheet.Week_End__c = tr1Timesheet.TR1__Week_Ending__c;
        timesheet.Work_Location__c = tr1Timesheet.Work_Shift_Location__c;

        uow.registerDirty(timesheet);

        List<NG_Timesheet_Entry__c> entries  = TimesheetEntryGateway.fetchTimesheetEntriesForTimesheet(timesheet.Id);
        if(entries.size() == 0) {
            System.debug('bw: TimesheetGateway.synchronize -> create entries');
            //entries are out of sync, sync them.
            List<TR1__Timesheet_Detail__c> details = TR_TimesheetDetail_Gateway.fetchTimesheetDetailsForTimesheetId(tr1Timesheet.Id);
            if(details != null && details.size() > 0) {
                System.debug('bw: TimesheetGateway.synchronzie -> details = ' + details);
                for(TR1__Timesheet_Detail__c detail : details) {

                    NG_Timesheet_Entry__c entry = new NG_Timesheet_Entry__c();
                    entry.Date__c = detail.TR1__Date__c;
                    entry.Day__c = detail.TR1__Day__c;
                    entry.Source_Object_ID__c = detail.Id;
                    uow.registerNew(entry, NG_Timesheet_Entry__c.Timesheet__c, timesheet);

                    NG_Timesheet_Entry_Slot__c slot = new NG_Timesheet_Entry_Slot__c();
                    slot.Is_Multi_Day__c = isMultiDay;
                    uow.registerNew(slot, NG_Timesheet_Entry_Slot__c.Timesheet_Entry__c, entry);

                    uow2.registerRelationship(entry, NG_Timesheet_Entry__c.Default_Slot__c, slot);
                }
            }
        }

        uows.add(uow);
        uows.add(uow2);
        
        return uows;
    }

    public static String generateRandomNumber(){
        Integer len = 4;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
        return randomNumber;
    }

    private static nuTimesheet convertTimesheetRecordToDTO(NG_Timesheet__c record) {
        nuTimesheet timesheet = new nuTimesheet();
        List<nuTimesheetEntry> entries = new List<nuTimesheetEntry>();
        List<nuTimesheetSlot> slots = new List<nuTimesheetSlot>();

        DateTime updatedDate = DateTime.now();

        timesheet.employeeId = record.Employee__c;
        timesheet.employee = record.Employee__r.Name;
        //timesheet.placementId = record.Placement__c;
        timesheet.timesheetId = record.Id;
        timesheet.status = record.Status__c;
        timesheet.location = record.Work_Location__r.Name;
        timesheet.label =  record.Work_Location__r.Name + ' (' + record.Status__c + ')';
        if(record.Status__c == 'Approved') {
            timesheet.readonly = true;
        }
        timesheet.weekStart = record.Week_Start__c;
        timesheet.weekEnd = record.Week_End__c;
        //if(record.Guaranteed_Hours__c != null)
        //    timesheet.guaranteedHours = record.Guaranteed_Hours__c;
        //timesheet.position = record.Job_Function__c;
        //timesheet.totalHours = record.Total_Hours__c;
        //timesheet.totalWorkedHours = record.Total_Worked_Hours__c;
        //timesheet.totalDoubleTimeHours = record.Total_Double_Time_Hours__c;
        //timesheet.totalHolidayHours = record.Total_Holiday_Hours__c;
        //timesheet.totalOvertimeHours = record.Total_Overtime_Hours__c;
        //timesheet.totalPTOHours = record.Total_PTO_Hours__c; 
        //timesheet.totalSickHours = record.Total_Sick_Hours__c; 
        //timesheet.totalWeekendHours = record.Total_Weekend_Hours__c; 
        //timesheet.totalRegularHours = record.Total_Regular_Hours__c;

        for(NG_Timesheet_Entry__c e:record.Timesheet_Entries__r) {
            nuTimesheetEntry entry = new nuTimesheetEntry();
            entry.entryId = e.Id;
            entry.employeeId = record.Employee__c;
            //entry.placementId = record.Placement__c;
            entry.timesheetId = record.Id;
            entry.entryName = e.Name;
            entry.entryDay = e.Day__c;
            if(e.Date__c != null)
                entry.entryDate = string.valueOf(e.Date__c);
            entry.totalHours = e.Total_Hours__c;

            entry.callbackHours = e.Total_Callback_Hours__c;
            entry.onCall = e.Default_Slot__r.Custom_On_Call_Beeper__c;
            entry.inTime = e.Default_Slot__r.In_Time__c;
            entry.outTime = e.Default_Slot__r.Out_Time__c;
            entry.isMultiDay = e.Default_Slot__r.Is_Multi_Day__c;
            entry.inDate = e.Default_Slot__r.In_Date__c;
            entry.outDate = e.Default_Slot__r.Out_Date__c;
            entry.unpaidBreak = e.Default_Slot__r.Unpaid_Break_Time__c;
            entry.note = e.Default_Slot__r.Note__c;

            entry.allowSlotAdd = (e.Total_Hours__c > 0 ? true : false);
            entry.readonly = timesheet.readonly;

            for(NG_Timesheet_Entry_Slot__c s:record.Timesheet_Entry_Slots__r) {
                if(s.Timesheet_Entry__c == e.Id) {
                    nuTimesheetSlot slot = new nuTimesheetSlot();
                    slot.slotId = s.Id;
                    slot.timesheetId = record.Id;
                    slot.employeeId = record.Employee__c;
                    //slot.placementId = record.Placement__c;
                    slot.entryId = e.Id;
                    slot.slotName = s.Shift__c;
                    slot.slotDay = s.Day__c;
                    if(s.Date__c != null)
                        slot.slotDate = string.valueOf(s.Date__c);
                    slot.shift = s.Shift__c;
                    slot.inTime = s.In_Time__c;
                    slot.outTime = s.Out_Time__c;
                    slot.inDate = s.In_Date__c;
                    slot.outDate = s.Out_Date__c;
                    //slot.multiDay = s.Is_Multi_Day__c;
                    slot.hours = s.Hours__c;
                    slot.clockInClockOut = true;
                    slot.unpaidBreak = s.Unpaid_Break_Time__c;
                    slot.note = s.Note__c;
                    //slot.computeAutoBreak = s.Auto_Calculate_Break__c;
                    slot.readonly = timesheet.readonly;
                    slot.allowDelete = true; //(s.Id == e.Default_Slot__c ? false : true);

                    slots.add(slot);
                } 
            }

            entry.timeSlots = slots;
            slots = new List<nuTimesheetSlot>();

            entries.add(entry); 
        }

        timesheet.entries = entries;

        return timesheet;
    }

    private static NG_Timesheet__c fetchApprovalToken(Id timesheetId) {
        return [select id,NG_UUID__c from NG_Timesheet__c where id = : timesheetId];
    }
}
public without sharing class TimesheetService {

    @AuraEnabled(cacheable=true)
    public static nuTimesheet fetchTimesheet(Id timesheetId) {
        system.debug('bw: TimesheetService.fetchTimesheet called');
        system.debug('bw: timesheetId = ' + timesheetId);
        return TimesheetGateway.fetchTimesheet(timesheetId);        
    }

    @AuraEnabled(cacheable=true)
    public static List<nuTimesheet> fetchTimesheetsForApprover(Id approverId, String statusFilter) {
        system.debug('bw: TimesheetService::fetchTimesheetsForApprover called');
        return TimesheetGateway.fetchTimesheetsForApprover(approverId, statusFilter);
    }


    @AuraEnabled(cacheable=true)
    public static List<NG_Timesheet__c> fetchTimesheetsForEmployee(Id contactId, String statusFilter) {
        return TimesheetGateway.fetchTimesheetsForContact(contactId, statusFilter);
    }

    @AuraEnabled(cacheable=true)
    public static List<NG_Timesheet_Entry__c> fetchTimesheetEntriesForTimesheet(Id timesheetId) {
        return TimesheetEntryGateway.fetchTimesheetEntriesForTimesheet(timesheetId);
    }   

    @AuraEnabled(cacheable=true)
    public static NG_Timesheet_Entry__c fetchTimesheetEntry(Id entryId) {
        return TimesheetEntryGateway.fetch(entryId);
    }  

    @AuraEnabled(cacheable=true)
    public static List<NG_Timesheet_Entry_Slot__c> fetchTimesheetEntrySlotsForEntry(Id entryId) {
        return TimesheetEntrySlotGateway.fetchTimesheetEntrySlotsForEntry(entryId);
    } 


    @AuraEnabled(cacheable=true)
    public static NG_Timesheet_Entry_Slot__c fetchTimesheetEntrySlot(Id slotId){
        return TimesheetEntrySlotGateway.fetch(slotId);
    }

    @AuraEnabled
    public static NG_Timesheet_Entry__c addTimesheetEntry(Id timesheetId) {
        NG_Timesheet__c timesheet = TimesheetGateway.fetch(timesheetId);
        
        TR1__Timesheet_Detail__c tr1TimesheetDetail = new TR1__Timesheet_Detail__c();
        tr1TimesheetDetail.TR1__Timesheet__c = timesheet.Source_Object_ID__c;
        system.debug('bw-service: timesheet.Source_Object_ID__c = ' + timesheet.Source_Object_ID__c);

        Id tr1TDId = TR_TimesheetDetail_Gateway.create(tr1TimesheetDetail);
        system.debug('bw-service: tr1TdId = ' + tr1TDId);

        NG_Timesheet_Entry__c entry = TimesheetEntryGateway.fetchForSourceObjectId(tr1TDId);
        system.debug('bw-service: entry = ' + entry);
        return entry;
    }
    
    @AuraEnabled
    public static void submitTimesheet(Id timesheetId){
        system.debug('bw-service: TimesheetService.submitTimesheet -> timesheetId = ' + timesheetId);
        NG_Timesheet__c timesheet = TimesheetGateway.fetch(timesheetId);
        List<NG_Timesheet_Entry__c> entries = timesheet.Timesheet_Entries__r;

        for(NG_Timesheet_Entry__c entry : entries) {
            if(!entry.Did_Not_Work__c && entry.Total_Hours__c <= 0) {
                throw new AuraHandledException('Please review your shift entries it looks like you ' +
                                               'forgot to add hours to one or more shifts. If this shift ' +
                                               'was canceled please contact your account manager.');
            }
        }

        if(timesheet != null && timesheet.Status__c == 'Unsubmitted') {
            timesheet.Status__c = 'Submitted';
            timesheet.NG_UUID__c = TimesheetGateway.generateRandomNumber();
            TimesheetGateway.save(timesheet);
        }
    } 

    @AuraEnabled
    public static nuServiceResult approveTimesheet(Id timesheetId, String usersName, String email) {
        system.debug('bw: TimesheetService.approveTimesheet called');
        system.debug('bw: timesheetId  = ' + timesheetId);
        system.debug('bw: usersName = ' + usersName);
        system.debug('bw: email = ' + email);
        return TimesheetGateway.approveTimesheet(timesheetId, usersName, email);
    }

    @AuraEnabled
    public static nuServiceResult rejectTimesheet(Id timesheetId, String usersName, String email, String rejectReason) {
        system.debug('bw: TimesheetService.approveTimesheet called');
        system.debug('bw: timesheetId  = ' + timesheetId);
        system.debug('bw: usersName = ' + usersName);
        system.debug('bw: email = ' + email);
        system.debug('bw: rejectReason = ' + rejectReason);
        return TimesheetGateway.rejectTimesheet(timesheetId, usersName, email, rejectReason);
    }

    @AuraEnabled
    public static nuServiceResult validateApprovalToken(Id timesheetId, String token){
        system.debug('bw: TimesheetService.validateApprovalToken called');
        system.debug('bw: timesheetId  = ' + timesheetId);
        system.debug('bw: token = ' + token);
        return TimesheetGateway.validateApprovalToken(timesheetId, token);
    }
}
public without sharing class nuTimesheetEntry {
    @AuraEnabled
    public string entryId {get; set;}

    @AuraEnabled
    public string placementId {get; set;}

    @AuraEnabled
    public string timesheetId {get; set;}

    @AuraEnabled
    public string employeeId {get; set;}

    @AuraEnabled
    public string entryName {get; set;}

    @AuraEnabled
    public string entryDay {get; set;}

    @AuraEnabled
    public string entryDate {get; set;}

    @AuraEnabled
    public decimal totalHours {get; set;}

    @AuraEnabled
    public decimal totalWorkedHours {get; set;}

    @AuraEnabled
    public decimal totalPTOHours {get; set;}

    @AuraEnabled
    public decimal totalSickHours {get; set;}

    @AuraEnabled
    public decimal totalHolidayHours {get; set;}

    @AuraEnabled
    public boolean allowSlotAdd {get; set;}

    @AuraEnabled
    public boolean readonly {get; set;}

    @AuraEnabled
    public List<nuTimesheetSlot> timeSlots {get; set;}

    @AuraEnabled
    public decimal callbackHours {get; set;}

    @AuraEnabled 
    public string onCall {get; set;}

    @AuraEnabled
    public string inTime {get; set;}

    @AuraEnabled
    public string outTime {get; set;}

    @AuraEnabled
    public boolean isMultiDay {get; set;}

    @AuraEnabled
    public string inDate {get; set;}

    @AuraEnabled
    public string outDate {get; set;}

    @AuraEnabled
    public decimal unpaidBreak {get; set;}

    @AuraEnabled
    public string note {get; set;}
}
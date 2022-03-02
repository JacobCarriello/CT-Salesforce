public without sharing class nuTimesheet {
    @AuraEnabled
    public string timesheetId {get; set;}

    @AuraEnabled
    public string placementId {get; set;}

    @AuraEnabled
    public string employeeId {get; set;}

    @AuraEnabled
    public string employee {get; set;}

    @AuraEnabled
    public string status {get; set;}
    
    @AuraEnabled
    public string label {get; set;}

    @AuraEnabled
    public date weekStart {get; set;}

    @AuraEnabled
    public date weekEnd {get; set;}

    @AuraEnabled
    public decimal guaranteedHours {get; set;}

    @AuraEnabled
    public string position {get; set;}

    @AuraEnabled
    public string location {get; set;}

    @AuraEnabled
    public boolean readonly {get; set;}

    @AuraEnabled
    public decimal totalHours {get; set;}

    @AuraEnabled
    public decimal totalWorkedHours {get; set;}

    @AuraEnabled
    public decimal totalRegularHours {get; set;}

    @AuraEnabled
    public decimal totalWeekendHours {get; set;}

    @AuraEnabled
    public decimal totalPTOHours {get; set;}

    @AuraEnabled
    public decimal totalSickHours {get; set;}

    @AuraEnabled
    public decimal totalHolidayHours {get; set;}

    @AuraEnabled
    public decimal totalOvertimeHours {get; set;}

    @AuraEnabled
    public decimal totalDoubleTimeHours {get; set;}

    @AuraEnabled
    public List<nuCustomProperty> customProperties {get; set;}

    @AuraEnabled
    public List<nuTimesheetEntry> entries {get; set;}

}
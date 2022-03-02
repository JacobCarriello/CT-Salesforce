public without sharing class nuTimesheetSlot {

    @AuraEnabled
    public string slotId {get; set;}

    @AuraEnabled
    public string employeeId {get; set;}

    @AuraEnabled
    public string placementId {get; set;}
    
    @AuraEnabled
    public string timesheetId {get; set;}

    @AuraEnabled
    public string entryId {get; set;}

    @AuraEnabled
    public string slotName {get; set;}

    @AuraEnabled
    public string slotDay {get; set;}

    @AuraEnabled
    public string slotDate {get; set;}

    @AuraEnabled
    public string shift {get; set;}

    @AuraEnabled
    public string inTime {get; set;}

    @AuraEnabled
    public string outTime {get; set;}

    @AuraEnabled
    public string inDate {get; set;}

    @AuraEnabled
    public string outDate {get; set;}

    @AuraEnabled
    public boolean multiDay {get; set;} 

    @AuraEnabled
    public boolean clockInClockOut {get; set;}

    @AuraEnabled
    public decimal unpaidBreak {get; set;}

    @AuraEnabled
    public decimal hours {get; set;}

    @AuraEnabled
    public string note {get; set;}

    @AuraEnabled
    public boolean computeAutoBreak {get; set;}

    @AuraEnabled
    public boolean readonly {get; set;}

    @AuraEnabled
    public boolean allowDelete {get; set;}
}
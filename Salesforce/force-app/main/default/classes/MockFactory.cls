public without sharing class MockFactory {
    public static TR1__Timesheet_Detail__c TimesheetDetail { get; private set; }
    
    public static Contact createContact() {
        Contact c = new Contact();
        c.LastName = 'Contact';
        c.FirstName = 'Mock';
        c.Email = 'bill.woodson@thenuagegroup.com';
        insert c;

        return c;
    }

    public static Account createAccount() {
        Account a = new Account();
        a.Name = 'Mock';
        insert a;

        return a;
    }

    public static TR1__Timesheet__c createTRTimesheet(Id contactId) {
        TR1__Timesheet__c t = new TR1__Timesheet__c();
        TR1__Job__c j = createTRJob();

        t.TR1__Consultant__c = contactId;
        t.TR1__Approver__c = contactId;
        t.TR1__Job_Order__c = j.Id;
        t.TR1__Week_Ending__c = Date.today().addDays(7);
        t.Work_Shift_Location__c = createAccount().Id;
        t.NG_Approval_Reminder_Sent__c = false;
        t.NG_Portal_Status__c = 'Unsubmitted';
 
        insert t;

        createTRRate(t.Id, 'Regular');
        createTRRate(t.Id, 'Callback');
        createTRTimesheetDetail(t.Id);

        return t;
    }

    public static TR1__Timesheet_Detail__c createTRTimesheetDetail(Id timesheetId) {
        TR1__Timesheet_Detail__c d = new TR1__Timesheet_Detail__c();
        
        d.TR1__Timesheet__c = timesheetId;
        d.TR1__Date__c = Date.today().addDays(-1);
        
        insert d;

        TimesheetDetail = d;

        return d;
    }
    
    public static NG_Timesheet__c createTimesheet(Id trTimesheetId) {
        NG_Timesheet__c t = new NG_Timesheet__c();
        t.Source_Object_ID__c = trTimesheetId;
        insert t;
        
        createTimesheetEntry(t.Id);
        
        return t;
    }
    
    public static NG_Timesheet_Entry__c createTimesheetEntry(Id timesheetId) {
        NG_Timesheet_Entry__c entry = new NG_Timesheet_Entry__c();
        entry.Timesheet__c = timesheetId;
        insert entry;
        
        NG_Timesheet_Entry_Slot__c slot = new NG_Timesheet_Entry_Slot__c();
        slot.In_Date__c = date.today().year() + '-' + date.today().month() + '-' + date.today().day();
        slot.Out_Date__c = date.today().year() + '-' + date.today().month() + '-' + date.today().day();
        slot.In_Time__c = '07:00';
        slot.Out_Time__c = '16:00';
        slot.Timesheet_Entry__c = entry.Id;
    insert slot;
        
        entry.Default_Slot__c = slot.Id;
        update entry;
        
        return entry;
    }

    public static TR1__Rate__c createTRRate() {
        return createTRRate(null, 'Regular');
    }

    public static TR1__Rate__c createTRRate(string timesheetId, string subType) {
        TR1__Rate__c r = new TR1__Rate__c();
        r.Name = 'Testing';
        TR1__TimeType__c ttype = createTRTimeType(subType);
        r.TR1__TimeType__c = ttype.Id;
        if(timesheetId != null) {
            r.TR1__Timesheet__c = timesheetId;
        }
        insert r;

        return r;
    }

    private static TR1__TimeType__c createTRTimeType(string subType) {
        TR1__TimeType__c t = new TR1__TimeType__c();
        t.Name = subType + ' Hours';
        t.NG_Time_Sub_Type__c = subType;
        insert t;

        return t;
    }

    private static TR1__Job__c createTRJob() {
        TR1__Job__c j = new TR1__Job__c();
        insert j;

        return j;
    }
}
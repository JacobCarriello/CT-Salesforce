@isTest 
public class TimesheetService_Test {
    @isTest
    public static void testFetchTimesheetsForEmployee() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);

        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        System.assertEquals(1, timesheets.size());
        System.assertEquals(t.Id, timesheets[0].Source_Object_ID__c);

    }

    @isTest
    public static void testFetchTimesheetEntriesForTimesheet() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);   
        System.assertEquals(1, entries.size());
        System.assertEquals(MockFactory.TimesheetDetail.Id, entries[0].Source_Object_ID__c);

    }

    @isTest
    public static void testFetchTimesheetEntry() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         
    
        NG_Timesheet_Entry__c entry = TimesheetService.fetchTimesheetEntry(entries[0].Id);
        System.assertEquals(entries[0].Id, entry.Id);
    }

    @isTest
    public static void testFetchTimesheetEntrySlotsForEntry() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         

        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        System.assertEquals(1, slots.size());
        System.assertEquals(slots[0].Id, entries[0].Default_Slot__c);
        System.assertEquals(Date.today().addDays(-1), slots[0].Timesheet_Entry__r.Date__c);
        System.assertEquals(entries[0].Source_Object_ID__c, slots[0].Timesheet_Entry_Source_Object_ID__c);
        System.assertEquals(timesheets[0].Source_Object_ID__c, slots[0].Timesheet_Source_Object_ID__c);
    }

    @isTest
    public static void testFetchTimesheetEntrySlot() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);         
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);

        NG_Timesheet_Entry_Slot__c slot = TimesheetService.fetchTimesheetEntrySlot(slots[0].Id);
        System.assertEquals(slots[0].Id, slot.Id);

    }

    @isTest
    public static void testAddTimesheetEntry() {
        TestHelper.setupTriggerHelpers();

        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');

        NG_Timesheet_Entry__c entry = TimesheetService.addTimesheetEntry(timesheets[0].Id);
        System.assert(entry != null);
    }

    @isTest
    public static void testSubmitTimesheet() {
        TestHelper.setupTriggerHelpers();
        
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
		
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        slots[0].In_Date__c = '2019-10-07';
        slots[0].In_Time__c = '9:00';
        slots[0].Out_Date__c = '2019-10-07';
        slots[0].Out_Time__c = '18:00';
        slots[0].Custom_On_Call_Beeper__c = 'No';
        update slots[0];
        
        TimesheetService.submitTimesheet(timesheets[0].Id);
        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
        System.assertEquals(0, timesheets.size());

        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Submitted');
        System.assertEquals(1, timesheets.size());
    }

    @isTest
    public static void approveTimesheet_Test() {
        TestHelper.setupTriggerHelpers();
        
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
		
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        slots[0].In_Date__c = '2019-10-07';
        slots[0].In_Time__c = '9:00';
        slots[0].Out_Date__c = '2019-10-07';
        slots[0].Out_Time__c = '18:00';
        slots[0].Custom_On_Call_Beeper__c = 'No';
        update slots[0];
        
        TimesheetService.submitTimesheet(timesheets[0].Id);

        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Submitted');

        nuServiceResult result;

        Test.startTest();
        result = TimesheetService.approveTimesheet(timesheets[0].Id, 'Mock User', 'mockUser@test.com');
        Test.stopTest();

        Map<string, object> payload = (Map<string, object>) result.data;
        System.assert((boolean)payload.get('success'));
    }

    @isTest
    public static void rejectTimesheet_Test() {
        TestHelper.setupTriggerHelpers();
        
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
		
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        slots[0].In_Date__c = '2019-10-07';
        slots[0].In_Time__c = '9:00';
        slots[0].Out_Date__c = '2019-10-07';
        slots[0].Out_Time__c = '18:00';
        slots[0].Custom_On_Call_Beeper__c = 'No';
        update slots[0];
        
        TimesheetService.submitTimesheet(timesheets[0].Id);

        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Submitted');

        nuServiceResult result;

        Test.startTest();
        result = TimesheetService.rejectTimesheet(timesheets[0].Id, 'Mock User', 'mockUser@test.com','rejected');
        Test.stopTest();

        Map<string, object> payload = (Map<string, object>) result.data;
        System.assert((boolean)payload.get('success'));
    }

    @isTest
    public static void validateApprovalToken_Test() {
        TestHelper.setupTriggerHelpers();
        
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
		
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        slots[0].In_Date__c = '2019-10-07';
        slots[0].In_Time__c = '9:00';
        slots[0].Out_Date__c = '2019-10-07';
        slots[0].Out_Time__c = '18:00';
        slots[0].Custom_On_Call_Beeper__c = 'No';
        update slots[0];
        
        TimesheetService.submitTimesheet(timesheets[0].Id);

        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Submitted');

        nuServiceResult result;

        Test.startTest();
        result = TimesheetService.validateApprovalToken(timesheets[0].Id, timesheets[0].NG_UUID__c);
        Test.stopTest();

        Map<string, object> payload = (Map<string, object>) result.data;
        System.assert((boolean)payload.get('tokenValid'));
    }

    @isTest
    public static void fetchTimesheet_Test() {
        TestHelper.setupTriggerHelpers();
        
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        List<NG_Timesheet__c> timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Unsubmitted');
		
        List<NG_Timesheet_Entry__c> entries = TimesheetService.fetchTimesheetEntriesForTimesheet(timesheets[0].Id);
        List<NG_Timesheet_Entry_Slot__c> slots = TimesheetService.fetchTimesheetEntrySlotsForEntry(entries[0].Id);
        slots[0].In_Date__c = '2019-10-07';
        slots[0].In_Time__c = '9:00';
        slots[0].Out_Date__c = '2019-10-07';
        slots[0].Out_Time__c = '18:00';
        slots[0].Custom_On_Call_Beeper__c = 'No';
        update slots[0];
        
        TimesheetService.submitTimesheet(timesheets[0].Id);

        timesheets = TimesheetService.fetchTimesheetsForEmployee(c.Id, 'Submitted');
        
        Test.startTest();
        nuTimesheet ts = TimesheetService.fetchTimesheet(timesheets[0].Source_Object_ID__c);
        Test.stopTest();
        
        System.assert(ts != null);

        //Exercise dto objects for code coverage
        nuCustomProperty cp = new nuCustomProperty();
        cp.propertyName = 'test';
        cp.propertyValue = 'value';

        nuServiceResult sr = new nuServiceResult();
        sr.data = true;
        sr.error = 'error';

        nuTimesheet nuts = new nuTimesheet();
        nuts.customProperties = new List<nuCustomProperty>();
        nuts.employeeId = '123';
        nuts.entries = new List<nuTimesheetEntry>();
        nuts.guaranteedHours = 36;
        nuts.label = 'test';
        nuts.placementId = '123';
        nuts.position = 'test';
        nuts.readonly = false;
        nuts.status = 'Unsubmitted';
        nuts.timesheetId = '123';
        nuts.totalDoubleTimeHours = 0;
        nuts.totalHolidayHours = 0;
        nuts.totalHours = 0;
        nuts.totalOvertimeHours = 0;
        nuts.totalPTOHours = 0;
        nuts.totalRegularHours = 0;
        nuts.totalSickHours = 0;
        nuts.totalWeekendHours = 0;
        nuts.totalWorkedHours = 0;
        nuts.weekEnd = Date.today();
        nuts.weekStart = Date.today();

        nuTimesheetEntry nute = new nuTimesheetEntry();
        nute.allowSlotAdd = false;
        nute.employeeId = '123';
        nute.entryDate = '';
        nute.entryDay = 'Monday';
        nute.entryId = '123';
        nute.entryName = 'blah';
        nute.placementId = '123';
        nute.readonly = false;
        nute.timesheetId = '123';
        nute.timeSlots = new List<nuTimesheetSlot>();
        nute.totalHolidayHours = 0;
        nute.totalHours = 0;
        nute.totalPTOHours = 0;
        nute.totalSickHours = 0;
        nute.totalWorkedHours = 0;

        nuTimesheetSlot nutes = new nuTimesheetSlot();
        nutes.allowDelete = false;
        nutes.clockInClockOut = true;
        nutes.computeAutoBreak = true;
        nutes.employeeId = '123';
        nutes.entryId = '123';
        nutes.hours = 0;
        nutes.inDate = '2022-02-02';
        nutes.inTime = '07:00';
        nutes.multiDay = false;
        nutes.note = 'note';
        nutes.outDate = '2022-02-02';
        nutes.outTime = '20:00';
        nutes.placementId = '123';
        nutes.readonly = false;
        nutes.shift = 'Regular';
        nutes.slotDate = '2022-02-02';
        nutes.slotDay = 'Wednesday';
        nutes.slotId = '123';
        nutes.slotName = 'test';
        nutes.timesheetId = '123';
        nutes.unpaidBreak = 0.5;

    }
}
@isTest
public class TimesheetEntrySlotTrigger_Test {
    @isTest
    public static void testTimesheetEntrySlotTrigger() {
        NG_Timesheet__c timesheet = new NG_Timesheet__c();
        insert timesheet;

        NG_Timesheet_Entry__c entry = new NG_Timesheet_Entry__c();
        entry.Timesheet__c = timesheet.Id;
        insert entry;

        NG_Timesheet_Entry_Slot__c slot = new NG_Timesheet_Entry_Slot__c();
        slot.Timesheet_Entry__c = entry.Id;
        insert slot;

        update slot;

        delete slot;
    }
}
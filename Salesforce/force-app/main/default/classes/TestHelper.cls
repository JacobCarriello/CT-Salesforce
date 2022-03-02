@TestVisible
public class TestHelper {
    private static final string TR_TIMESHEET_HELPER_ID = 'TR1__Timesheet__c'; //'01I41000001N5fI';
    private static final string TR_TIMESHEETDETAIL_HELPER_ID = 'TR1__Timesheet_Detail__c'; //'01I41000001N5ff';
    private static final string TR_SHIFTWORK_HELPER_ID = 'TR1__ShiftWork__c'; //'01I41000002TMNt';
    private static final string TIMESHEET_HELPER_ID =  'NG_Timesheet__c'; // /*'01I2M000002U5vN'; //*/'01IS0000000Y5H9';
    private static final string TIMESHEET_ENTRY_HELPER_ID = 'NG_Timesheet_Entry__c'; // /*'01I2M000002U5vM'; //*/'01IS0000000Y5H4';
    private static final string TIMESHEET_ENTRY_SLOT_HELPER_ID = 'NG_Timesheet_Entry_Slot__c'; // /*'01I2M000002U5vL'; //*/'01IS0000000Y5F8';

    public static void setupTriggerHelpers() {     
        List<Trigger_Helper__mdt> helpers = new List<Trigger_Helper__mdt>();
        
        helpers.addAll(setupAccountTriggerHelpers());
        helpers.addAll(setupTimesheetTriggerHelpers());
        helpers.addAll(setupTimesheetEntryTriggerHelpers());
        helpers.addAll(setupTimesheetEntrySlotTriggerHelpers());

        string serializedHelpers = JSON.serialize(helpers);
        System.debug('bw: TestHelper.setupTriggerHelpers -> serializedHelpers = ' + serializedHelpers);
        
        TriggerHelperGateway.triggerHelpers = (List<Trigger_Helper__mdt>) JSON.deserialize(serializedHelpers, List<Trigger_Helper__mdt>.class );
        
    }

    public static Trigger_Helper__mdt createHelper(string apexClassName, string objectName, string triggerType) {
        Trigger_Helper__mdt h = new Trigger_Helper__mdt();
        h.Apex_Class_Name__c = apexClassName;
        h.Object__c = objectName;
        h.Trigger_Type__c = triggerType;
        h.Order__c = 1;
        return h;
    }

    private static List<Trigger_Helper__mdt> setupAccountTriggerHelpers() {
        List<Trigger_Helper__mdt> helpers = new List<Trigger_Helper__mdt>();

        Trigger_Helper__mdt beforeInsertHelper = createHelper('DefaultAccountHelper',
                                                  'Account',
                                                  'beforeInsert');

        helpers.add(beforeInsertHelper);

        Trigger_Helper__mdt beforeUpdateHelper = createHelper('DefaultAccountHelper',
                                                  'Account',
                                                  'beforeUpdate');

        helpers.add(beforeUpdateHelper);

        Trigger_Helper__mdt beforeDeleteHelper = createHelper('DefaultAccountHelper',
                                                  'Account',
                                                  'beforeDelete');

        helpers.add(beforeDeleteHelper);

        Trigger_Helper__mdt afterInsertHelper = createHelper('DefaultAccountHelper',
                                                  'Account',
                                                  'afterInsert');

        helpers.add(afterInsertHelper);

        Trigger_Helper__mdt afterUpdateHelper = createHelper('DefaultAccountHelper',
                                                  'Account',
                                                  'afterUpdate');

        helpers.add(afterUpdateHelper);

        Trigger_Helper__mdt afterDeleteHelper = createHelper('DefaultAccountHelper',
                                                  'Account',
                                                  'afterDelete');

        helpers.add(afterDeleteHelper);

        return helpers;
    }

    private static List<Trigger_Helper__mdt> setupTimesheetTriggerHelpers() {
        List<Trigger_Helper__mdt> helpers = new List<Trigger_Helper__mdt>();

        Trigger_Helper__mdt beforeInsertHelper = createHelper('TimesheetHelper',
                                                  TIMESHEET_HELPER_ID,
                                                  'beforeInsert');
        helpers.add(beforeInsertHelper);

        Trigger_Helper__mdt beforeUpdateHelper = createHelper('TimesheetHelper',
                                                  TIMESHEET_HELPER_ID,
                                                  'beforeUpdate');
        helpers.add(beforeUpdateHelper);

        Trigger_Helper__mdt beforeDeleteHelper = createHelper('TimesheetHelper',
                                                  TIMESHEET_HELPER_ID,
                                                  'beforeDelete');
        helpers.add(beforeDeleteHelper);

        Trigger_Helper__mdt afterInsertHelper = createHelper('TimesheetHelper',
                                                  TIMESHEET_HELPER_ID,
                                                  'afterInsert');
        helpers.add(afterInsertHelper);

        Trigger_Helper__mdt afterUpdateHelper = createHelper('TimesheetHelper',
                                                  TIMESHEET_HELPER_ID,
                                                  'afterUpdate');
        helpers.add(afterUpdateHelper);

        Trigger_Helper__mdt afterDeleteHelper = createHelper('TimesheetHelper',
                                                  TIMESHEET_HELPER_ID,
                                                  'afterDelete');
        helpers.add(afterDeleteHelper);

        Trigger_Helper__mdt afterTRTimesheetInsert = createHelper('TR_Timesheet_Helper', 
                                                                  TR_TIMESHEET_HELPER_ID, 
                                                                  'afterInsert' );
        helpers.add(afterTRTimesheetInsert);

        Trigger_Helper__mdt afterTRTimesheetUpdate = createHelper('TR_Timesheet_Helper', 
                                                                  TR_TIMESHEET_HELPER_ID, 
                                                                  'afterUpdate' );
        helpers.add(afterTRTimesheetUpdate);

        Trigger_Helper__mdt afterTRTimesheetDetailInsert = createHelper('TR_TimesheetDetail_Helper', 
                                                                        TR_TIMESHEETDETAIL_HELPER_ID, 
                                                                        'afterInsert' );
        helpers.add(afterTRTimesheetDetailInsert);

        Trigger_Helper__mdt afterTRTimesheetDetailUpdate = createHelper('TR_TimesheetDetail_Helper', 
                                                                        TR_TIMESHEETDETAIL_HELPER_ID, 
                                                                        'afterUpdate' );
        helpers.add(afterTRTimesheetDetailUpdate);

        return helpers;
    }

    private static List<Trigger_Helper__mdt> setupTimesheetEntryTriggerHelpers() {
        List<Trigger_Helper__mdt> helpers = new List<Trigger_Helper__mdt>();

        Trigger_Helper__mdt beforeInsertHelper = createHelper('TimesheetEntryHelper',
                                                  TIMESHEET_ENTRY_HELPER_ID,
                                                  'beforeInsert');
        helpers.add(beforeInsertHelper);

        Trigger_Helper__mdt beforeUpdateHelper = createHelper('TimesheetEntryHelper',
                                                  TIMESHEET_ENTRY_HELPER_ID,
                                                  'beforeUpdate');
        helpers.add(beforeUpdateHelper);

        Trigger_Helper__mdt beforeDeleteHelper = createHelper('TimesheetEntryHelper',
                                                  TIMESHEET_ENTRY_HELPER_ID,
                                                  'beforeDelete');
        helpers.add(beforeDeleteHelper);

        Trigger_Helper__mdt afterInsertHelper = createHelper('TimesheetEntryHelper',
                                                  TIMESHEET_ENTRY_HELPER_ID,
                                                  'afterInsert');
        helpers.add(afterInsertHelper);

        Trigger_Helper__mdt afterUpdateHelper = createHelper('TimesheetEntryHelper',
                                                  TIMESHEET_ENTRY_HELPER_ID,
                                                  'afterUpdate');
        helpers.add(afterUpdateHelper);

        Trigger_Helper__mdt afterDeleteHelper = createHelper('TimesheetEntryHelper',
                                                  TIMESHEET_ENTRY_HELPER_ID,
                                                  'afterDelete');
        helpers.add(afterDeleteHelper);

        return helpers;
    }

    private static List<Trigger_Helper__mdt> setupTimesheetEntrySlotTriggerHelpers() {
        List<Trigger_Helper__mdt> helpers = new List<Trigger_Helper__mdt>();

        Trigger_Helper__mdt beforeInsertHelper = createHelper('TimesheetEntrySlotHelper',
                                                  TIMESHEET_ENTRY_SLOT_HELPER_ID,
                                                  'beforeInsert');
        helpers.add(beforeInsertHelper);

        Trigger_Helper__mdt beforeUpdateHelper = createHelper('TimesheetEntrySlotHelper',
                                                  TIMESHEET_ENTRY_SLOT_HELPER_ID,
                                                  'beforeUpdate');
        helpers.add(beforeUpdateHelper);

        Trigger_Helper__mdt beforeDeleteHelper = createHelper('TimesheetEntrySlotHelper',
                                                  TIMESHEET_ENTRY_SLOT_HELPER_ID,
                                                  'beforeDelete');
        helpers.add(beforeDeleteHelper);

        Trigger_Helper__mdt afterInsertHelper = createHelper('TimesheetEntrySlotHelper',
                                                  TIMESHEET_ENTRY_SLOT_HELPER_ID,
                                                  'afterInsert');
        helpers.add(afterInsertHelper);

        Trigger_Helper__mdt afterUpdateHelper = createHelper('TimesheetEntrySlotHelper',
                                                  TIMESHEET_ENTRY_SLOT_HELPER_ID,
                                                  'afterUpdate');
        helpers.add(afterUpdateHelper);

        Trigger_Helper__mdt afterDeleteHelper = createHelper('TimesheetEntrySlotHelper',
                                                  TIMESHEET_ENTRY_SLOT_HELPER_ID,
                                                  'afterDelete');
        helpers.add(afterDeleteHelper);

        Trigger_Helper__mdt afterSHDeleteHelper = createHelper('TR_ShiftWork_Helper',
                                                  TR_SHIFTWORK_HELPER_ID,
                                                  'afterDelete');
        helpers.add(afterSHDeleteHelper);

        return helpers;
    }
}
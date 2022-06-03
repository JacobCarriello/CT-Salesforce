@isTest
public class TR_TimesheetDetail_Helper_Test {
    @isTest
    public static void testTR_TimesheetDetail_Helper() {
        setupTriggerHelpers();

        //exercise triggers
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        TR1__Timesheet_Detail__c d = MockFactory.TimesheetDetail;

        d.TR1__Date__c = date.today();
        update d;

        delete d;
    }

    private static void setupTriggerHelpers() {
        List<Trigger_Helper__mdt> helpers = new List<Trigger_Helper__mdt>();

        Trigger_Helper__mdt afterTRTimesheetInsert = createHelper('TR_Timesheet_Helper', '01I41000001N5fI', 'afterInsert' );
        helpers.add(afterTRTimesheetInsert);

        Trigger_Helper__mdt afterTRTimesheetUpdate = createHelper('TR_Timesheet_Helper', '01I41000001N5fI', 'afterUpdate' );
        helpers.add(afterTRTimesheetUpdate);

        Trigger_Helper__mdt beforeTRTimesheetDetailInsert = createHelper('TR_TimesheetDetail_Helper', '01I41000001N5ff', 'beforeInsert' );
        helpers.add(beforeTRTimesheetDetailInsert);

        Trigger_Helper__mdt beforeTRTimesheetDetailUpdate = createHelper('TR_TimesheetDetail_Helper', '01I41000001N5ff', 'beforeUpdate' );
        helpers.add(beforeTRTimesheetDetailUpdate);

        Trigger_Helper__mdt beforeTRTimesheetDetailDelete = createHelper('TR_TimesheetDetail_Helper', '01I41000001N5ff', 'beforeDelete' );
        helpers.add(beforeTRTimesheetDetailDelete);

        Trigger_Helper__mdt afterTRTimesheetDetailInsert = createHelper('TR_TimesheetDetail_Helper', '01I41000001N5ff', 'afterInsert' );
        helpers.add(afterTRTimesheetDetailInsert);

        Trigger_Helper__mdt afterTRTimesheetDetailUpdate = createHelper('TR_TimesheetDetail_Helper', '01I41000001N5ff', 'afterUpdate' );
        helpers.add(afterTRTimesheetDetailUpdate);

        Trigger_Helper__mdt afterTRTimesheetDetailDelete = createHelper('TR_TimesheetDetail_Helper', '01I41000001N5ff', 'afterDelete' );
        helpers.add(afterTRTimesheetDetailDelete);

        string serializedHelpers = JSON.serialize(helpers);
        TriggerHelperGateway.triggerHelpers = (List<Trigger_Helper__mdt>) JSON.deserialize(serializedHelpers, List<Trigger_Helper__mdt>.class );
        
    }

    private static Trigger_Helper__mdt createHelper(string apexClassName, string objectName, string triggerType) {
        Trigger_Helper__mdt h = new Trigger_Helper__mdt();
        h.Apex_Class_Name__c = apexClassName;
        h.Object__c = objectName;
        h.Trigger_Type__c = triggerType;
        h.Order__c = 1;
        return h;
    }
}
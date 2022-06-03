@isTest
public class TriggerHelperGateway_Test {
    @isTest
    public static void testFetchTriggerHelpers() {
        //exercise triggers

        Account a = new Account();
        a.Name = 'Testing';
        insert a;

        a.Name = 'Testing update';
        update a;

        delete a;
    }

    private static void setupTriggerHelpers() {
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
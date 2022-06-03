public without sharing class TriggerHelperGateway {
    @testVisible
    public static List<Trigger_Helper__mdt> triggerHelpers{
        get {
            if(triggerHelpers == null) {
                triggerHelpers = [SELECT Apex_Class_Name__c, Object__c, Object__r.QualifiedApiName, Trigger_Type__c 
                                                   FROM Trigger_Helper__mdt
                                                   WHERE Active__c = true
                                                   ORDER BY Order__c];
            }
            return triggerHelpers;
        } set;
    }

    public static List<ITriggerHelper> fetchTriggerHelpers(String obj, String triggerType) {
        System.debug('bw-trgframe: TriggerHelperGateway.fetchTriggerHelpers(' + obj + ', ' + triggerType + ')');
        
        for(Trigger_Helper__mdt helper : triggerHelpers) {
            system.debug('bw-trgframe: allHelpers = ' + helper);
        }

        List<ITriggerHelper> helpers = new List<ITriggerHelper>();
        string ident;
        for(Trigger_Helper__mdt helper: triggerHelpers) {
            ident = (helper.Object__r.QualifiedApiName != null ? helper.Object__r.QualifiedApiName : helper.Object__c);
            System.debug('bw-trgframe: TriggerHelperGateway.fetchTriggerHelpers -> ident = ' + ident);
            System.debug('bw-trgframe: TriggerHelperGateway.fetchTriggerHelpers -> obj = ' + obj);
            if(ident == obj && helper.Trigger_Type__c == triggerType) {
                System.debug('bw-trgframe: fetchTriggerHelpers -> helper = ' + helper);
                System.debug('bw-trgframe: fetchTriggerHelpers -> Apex_Class_Name__c = ' + helper.Apex_Class_Name__c);
                Type customType = Type.forName(helper.Apex_Class_Name__c);
                ITriggerHelper instance = (ITriggerHelper)customType.newInstance();
                helpers.add(instance);
            }
        }

        return helpers;
    }

	public static void fireHelpers(List<ITriggerHelper> helpers, SObject so) {
		fireHelpers(helpers, so, null);
	}

	public static void fireHelpers(List<ITriggerHelper> helpers, SObject so, SObject oldSo) {
        system.debug('bw-trgframe: fireHelpers -> Trigger.isUpdate = ' + Trigger.isUpdate);
        system.debug('bw-trgframe: fireHelpers -> Trigger.isBefore = ' + Trigger.isBefore);
        system.debug('bw-trgframe: fireHelpers -> helpers = ' + helpers);

		if(Trigger.isUpdate || (Trigger.isBefore && Trigger.isDelete)) {
			for(ITriggerHelper helper : helpers) {
                system.debug('bw-trgframe: TriggerHelperGateway.execute -> call helper.execute isUpdate || (isBefore && isDelete)');
				helper.execute(so, oldSo);
			}
		}
		else {
			for(ITriggerHelper helper : helpers) {
                system.debug('bw-trgframe: TriggerHelperGateway.execute -> call helper.execute isInsert || (isAfter && isDelete)');
				helper.execute(so);
			}
		}
	}

	public static List<ITriggerHelper> handleHelpers(String objectName, SObject so, String triggerType) {
		return handleHelpers(objectName, so, null, triggerType);
	}

	public static List<ITriggerHelper> handleHelpers(String objectName, SObject so, SObject oldSo, String triggerType) {
		List<ITriggerHelper> helpers =  TriggerHelperGateway.fetchTriggerHelpers(objectName, triggerType);
		if(oldSo == null){
			TriggerHelperGateway.fireHelpers(helpers, so);
		}
		else {
			TriggerHelperGateway.fireHelpers(helpers, so, oldSo);
		}

        return helpers;
	}
}
trigger JobOrderTriggerCust on TR1__Job__c (after insert) {

if(Trigger.isInsert && Trigger.isAfter){
       
      
       if(TR1__TalentRoverProperties__c.getOrgDefaults()!=null &&
                       TR1__TalentRoverProperties__c.getOrgDefaults().Use_Rate_Card_Module_Cust__c){
         system.debug('true==>'+TR1__TalentRoverProperties__c.getOrgDefaults().Use_Rate_Card_Module_Cust__c);              
         RateCreationHandlerCtrl.getRateFromAccount(trigger.new);
       }
       }

}
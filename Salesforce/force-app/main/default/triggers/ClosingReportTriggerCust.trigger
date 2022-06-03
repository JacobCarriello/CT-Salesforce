trigger ClosingReportTriggerCust on TR1__Closing_Report__c (after insert) {

if(Trigger.isInsert && Trigger.isAfter){
   
    if(TR1__TalentRoverProperties__c.getOrgDefaults()!=null && 
                       TR1__TalentRoverProperties__c.getOrgDefaults().Use_Rate_Card_Module_Cust__c){
         RateCreationHandlerCtrl.getRateFromJob(trigger.new); 
       }  
    }

}
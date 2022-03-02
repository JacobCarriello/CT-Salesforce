trigger TimeSheetTriggerCust on TR1__Timesheet__c (after insert) {

//fix for MP code defect: writing custom code here ESE 31511
if(Trigger.isInsert && Trigger.isAfter){
        
        if(TR1__TalentRoverProperties__c.getOrgDefaults()!=null && 
                           TR1__TalentRoverProperties__c.getOrgDefaults().Use_Rate_Card_Module_Cust__c){
           RateCreationHandlerCtrl.getRateFromCR(trigger.new);
        }     
    }


}
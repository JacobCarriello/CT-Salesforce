public with sharing class SplitsTriggerHandler {
    
    public static void afterInserUpdate(List<Split__c> newSplits, Map<Id, Split__c> oldMap){
        boolean isInsert = oldMap == null;
        if(isInsert){
           //insertSplitCreditRecords(newSplits);
        }
    }
    /*
    private static void insertSplitCreditRecords(List<Split__c> newSplits){
        Set<String> setJobLeads = new Set<String>();
        for(Split__c split : newSplits){
            if(split.Job_Lead__c != null){
                setJobLeads.add(split.Job_Lead__c);
            }
        }
        
        //now fetch all the Job Leads
        Map<String, TR1__Job_Leads__c> mapJobLeads = new Map<String, TR1__Job_Leads__c>([Select Id, Contract_In_Timestamp__c, 
                                        of_Months__c, Non_Physician_of_Months__c, Retainer_Amount__c 
                                        from TR1__Job_Leads__c where id in : setJobLeads AND 
                                        Contract_In_Timestamp__c != null AND 
                                        (of_Months__c != null OR Non_Physician_of_Months__c != null)]);
        
        //creating the  Split Credit records
        List<Splits_Credit__c> splitCreditsToInsert = new List<Splits_Credit__c>();
        for(Split__c split : [Select Job_Lead__c, Job_Lead__r.Retainer_Amount__c, Job_Lead__r.of_Months__c, 
                                Job_Lead__r.Non_Physician_of_Months__c   
                                from Split__c where id in : newSplits]){
            if(mapJobLeads.containsKey(split.Job_Lead__c)){
                TR1__Job_Leads__c lead = mapJobLeads.get(split.Job_Lead__c);
                Date contractDate = Date.valueOf(lead.Contract_In_Timestamp__c);
                if(lead.of_Months__c != null && lead.of_Months__c > 0){
                    Date firstDayOfMonth = contractDate.toStartOfMonth();
                    for(Integer i = 0; i < lead.of_Months__c ; i++){
                        splitCreditsToInsert.add(ContractLeadTriggerHandler.prepareSplitCreditRecords(split, firstDayOfMonth, 'Physician'));
                        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                        firstDayOfMonth = lastDayOfMonth.addDays(1);
                    }
                }
                
                if(lead.Non_Physician_of_Months__c != null && lead.Non_Physician_of_Months__c > 0){
                    Date firstDayOfMonth = contractDate.toStartOfMonth();
                    for(Integer i = 0; i < lead.Non_Physician_of_Months__c ; i++){
                        splitCreditsToInsert.add(ContractLeadTriggerHandler.prepareSplitCreditRecords(split, firstDayOfMonth, 'Non-Physician'));
                        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                        firstDayOfMonth = lastDayOfMonth.addDays(1);
                    }
                }
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            if(splitCreditsToInsert.size() > 0){
                insert splitCreditsToInsert;
            }
        }catch(Exception ex){
            Database.rollback( sp );
            system.debug('Exception ex ======== ' + ex.getMessage() + '  at line number ' + ex.getLineNumber());
        }
    }*/
}
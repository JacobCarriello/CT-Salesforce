public with sharing class ContractLeadTriggerHandler {
    
    public static void afterInserUpdate(List<TR1__Job_Leads__c> newLeads, Map<Id, TR1__Job_Leads__c> oldMap){
        insertSplitCreditRecords(newLeads, oldMap);
    }
    
    private static void insertSplitCreditRecords(List<TR1__Job_Leads__c> newLeads, Map<Id, TR1__Job_Leads__c> oldMap){
        boolean isInsert = oldMap == null;
        Set<String> contractLeadIds = new Set<String>();
        for(TR1__Job_Leads__c  lead : newLeads){
            if(lead.Contract_In_Timestamp__c != null && (isInsert || 
                                                        lead.Contract_In_Timestamp__c != oldMap.get(lead.id).Contract_In_Timestamp__c || 
                                                        lead.of_Months__c != oldMap.get(lead.id).of_Months__c ||
                                                        lead.Non_Physician_of_Months__c != oldMap.get(lead.id).Non_Physician_of_Months__c )){
                contractLeadIds.add(lead.id);
            }
        }
        
        //fetch the Split Users
        Map<String, List<Split__c>> mapContractLeadSplitUsers = new Map<String, List<Split__c>>();
        for(Split__c split : [Select Closing_Report__c, Job_Lead__c, Split_Percentage__c, User__c, Job_Lead__r.Retainer_Amount__c,
                                Job_Lead__r.of_Months__c, Job_Lead__r.Non_Physician_of_Months__c   
                                from Split__c where Job_Lead__c in : contractLeadIds]){
            if(!mapContractLeadSplitUsers.containsKey(split.Job_Lead__c)){
                mapContractLeadSplitUsers.put(split.Job_Lead__c, new List<Split__c>());
            }
            mapContractLeadSplitUsers.get(split.Job_Lead__c).add(split);                        
        }
        
        //create list of Fee Split records
        List<Splits_Credit__c> splitCreditsToInsert = new List<Splits_Credit__c>();
        Map<String, Split__c> mapSplitsToUpdate = new Map<String, Split__c>();
        for(TR1__Job_Leads__c  lead : newLeads){
            if(contractLeadIds.contains(lead.id) && mapContractLeadSplitUsers.containsKey(lead.id)){
                Date contractDate = Date.valueOf(lead.Contract_In_Timestamp__c);
                if(lead.of_Months__c != null && lead.of_Months__c > 0){
                    for(Split__c split : mapContractLeadSplitUsers.get(lead.id)){
                        Date firstDayOfMonth = contractDate.toStartOfMonth();
                        mapSplitsToUpdate.put(split.id, new Split__c(id = split.id, First_Month_Date__c = firstDayOfMonth));
                        for(Integer i = 0; i < lead.of_Months__c ; i++){
                            splitCreditsToInsert.add(prepareSplitCreditRecords(split, firstDayOfMonth, 'Physician'));
                            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                            firstDayOfMonth = lastDayOfMonth.addDays(1);
                        }
                    }
                }
                if(lead.Non_Physician_of_Months__c != null && lead.Non_Physician_of_Months__c > 0){
                    for(Split__c split : mapContractLeadSplitUsers.get(lead.id)){
                        Date firstDayOfMonth = contractDate.toStartOfMonth();
                        mapSplitsToUpdate.put(split.id, new Split__c(id = split.id, First_Month_Date__c = firstDayOfMonth));
                        for(Integer i = 0; i < lead.Non_Physician_of_Months__c ; i++){
                            splitCreditsToInsert.add(prepareSplitCreditRecords(split, firstDayOfMonth, 'Non-Physician'));
                            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                            firstDayOfMonth = lastDayOfMonth.addDays(1);
                        }
                    }   
                }
            }
        }
        Savepoint sp = Database.setSavepoint();
        try{
            if(mapSplitsToUpdate.keySet().size()  > 0){
                //delete the old Split Credit records
                if(!isInsert){
                    delete [Select Id from Splits_Credit__c where Split__r.Job_Lead__c in : contractLeadIds];
                }
                update mapSplitsToUpdate.values();
                if(splitCreditsToInsert.size() > 0){
                    insert splitCreditsToInsert;
                }
            }
        }catch(Exception ex){
            Database.rollback( sp );
            //System.assert(false, 'Exception ex ======== ' + ex.getMessage() + '  at line number ' + ex.getLineNumber());
            system.debug('Exception ex ======== ' + ex.getMessage() + '  at line number ' + ex.getLineNumber());
        }
    }
    
    //common method to prepare teh Fee Split records
    public static Splits_Credit__c prepareSplitCreditRecords(Split__c split, Date creditDate, String creditType){
        Splits_Credit__c credit =  new Splits_Credit__c();
        credit.Split__c = split.id;
        credit.Split_Credit_Date__c = creditDate; 
        credit.Type__c = creditType;
        /*
        //system.assert(False, split.Job_Lead__r + '===' + split.Job_Lead__r.Retainer_Amount__c + '====' + split.Job_Lead__r.of_Months__c + '==' +split.Job_Lead__r.Non_Physician_of_Months__c);
        if(split.Job_Lead__r != null && split.Job_Lead__r.Retainer_Amount__c != null){
            if(creditType == 'Physician' && split.Job_Lead__r.of_Months__c != null && split.Job_Lead__r.of_Months__c != 0){
                credit.Split_Credit__c = split.Job_Lead__r.Retainer_Amount__c / split.Job_Lead__r.of_Months__c;
            }else if(creditType == 'Non-Physician' && split.Job_Lead__r.Non_Physician_of_Months__c != null && split.Job_Lead__r.Non_Physician_of_Months__c != 0){
                credit.Split_Credit__c = split.Job_Lead__r.Retainer_Amount__c / split.Job_Lead__r.Non_Physician_of_Months__c;
            }
            
        }
        //system.assert(false, credit);
        */
        return credit;
    }
}
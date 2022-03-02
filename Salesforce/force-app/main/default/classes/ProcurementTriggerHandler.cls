public class ProcurementTriggerHandler{
    
    //Method called in case of before insert update
    public static void beforeInsertUpdate(List<Procurement__c> newList, Map<Id, Procurement__c> oldMap){
        boolean isInsert = oldMap == null;
        if(isInsert){
            assignProcurementFields(newList);
        }
    }
    
    //Method called in case of after Insert Update
    public static void afterInsertUpdate(List<Procurement__c> newList, Map<Id, Procurement__c> oldMap){
        createSplitRecords(newList, oldMap);
    }
    
    private static void assignProcurementFields(List<Procurement__c> newList){
        Map<String, Procurement_Split_Users_Config__mdt> mapProcurements = fetchProcurementCustomMetadata();
        for(Procurement__c procurement : newList){
            String isClinicalValuePresent = procurement.Clinic_Caller__c != null ? 'YES' : 'NO';
            if(procurement.Search_Type__c == 'Repeat'){
                isClinicalValuePresent = 'NO';
            }
            String uniqueKEY = procurement.Package_Type__c + '--' + procurement.Search_Type__c + '--' + isClinicalValuePresent;
            if(mapProcurements.containsKey(uniqueKEY) && 
                                procurement.Price_per_unit__c == null && 
                                mapProcurements.get(uniqueKEY).Price_per_unit__c != null){
                procurement.Price_per_unit__c = mapProcurements.get(uniqueKEY).Price_per_unit__c;
            }
        }
    }
    
    //creating Split User records
    private static void createSplitRecords(List<Procurement__c> newList, Map<Id, Procurement__c> oldMap){
        List<Split__c> listSplitsToInsert = new List<Split__c>();
        Set<String> setUpdatedProcurements = new Set<String>();
        Boolean isInsert = oldMap == null;
        
        Map<String, Procurement_Split_Users_Config__mdt> mapProcurements = fetchProcurementCustomMetadata();
        String procurementRecordTypeId = CallListGenerationController.getRecordTypeIdbyName('Split__c', 'Procurement');
        
        for(Procurement__c procurement : newList){
            if(procurement.Status__c == 'Won' && (isInsert || procurement.Package_Type__c != oldMap.get(procurement.id).Package_Type__c 
                                                           || procurement.Search_Type__c != oldMap.get(procurement.id).Search_Type__c
                                                           || procurement.Status__c != oldMap.get(procurement.id).Status__c
                                                           || procurement.Clinic_Caller__c != oldMap.get(procurement.id).Clinic_Caller__c
                                                           || procurement.Recruiter__c != oldMap.get(procurement.id).Recruiter__c
                                                           || procurement.Marketer__c != oldMap.get(procurement.id).Marketer__c)){
            
                String isClinicalValuePresent = procurement.Clinic_Caller__c != null ? 'YES' : 'NO';
                if(procurement.Search_Type__c == 'Repeat'){
                    isClinicalValuePresent = 'NO';
                }
                String uniqueKEY = procurement.Package_Type__c + '--' + procurement.Search_Type__c + '--' + isClinicalValuePresent;
                if(mapProcurements.containsKey(uniqueKEY)){
                    Procurement_Split_Users_Config__mdt tempMDT = mapProcurements.get(uniqueKEY);
                    if(procurement.Marketer__c != null){
                        listSplitsToInsert.add(new Split__c(    Procurement__c = procurement.id,
                                                                Split_Percentage__c = tempMDT.Marketer__c,
                                                                User__c = procurement.Marketer__c,
                                                                Role__c = Label.Marketer_Role,
                                                                RecordTypeId = procurementRecordTypeId));

                    }
                    
                    if(procurement.Recruiter__c != null){
                       listSplitsToInsert.add(new Split__c(     Procurement__c = procurement.id,
                                                                Split_Percentage__c = tempMDT.Recruiter__c,
                                                                User__c = procurement.Recruiter__c,
                                                                Role__c = Label.Recruiter_Role,
                                                                RecordTypeId = procurementRecordTypeId));
                    }
                    
                    if(procurement.Clinic_Caller__c != null && procurement.Search_Type__c == 'New'){
                       listSplitsToInsert.add(new Split__c(     Procurement__c = procurement.id,
                                                                Split_Percentage__c = tempMDT.Clinic_Caller__c,
                                                                User__c = procurement.Clinic_Caller__c,
                                                                Role__c = Label.Clinic_Caller_Role,
                                                                RecordTypeId = procurementRecordTypeId));
                    }
                    setUpdatedProcurements.add(procurement.id);
                }
            }
        }
        //System.assert(false, listSplitsToInsert + '===' + procurementRecordTypeId);
        Savepoint sp = Database.setSavepoint();
        try{
            // We need to delete the previous Split Records
            if(setUpdatedProcurements.size() > 0){
                delete [Select Id from Split__c where Procurement__c In : setUpdatedProcurements];
            }
            if(listSplitsToInsert.size() > 0){
                insert listSplitsToInsert;
                insertSplitCreditRecords(listSplitsToInsert);
            }
        }catch(Exception ex){
            Database.rollback( sp );
            system.debug('Exception ex ======== ' + ex.getMessage() + '  at line number ' + ex.getLineNumber());
            //System.assert(false, 'Exception ex ======== ' + ex.getMessage() + '  at line number ' + ex.getLineNumber());
        }
    }
    
    //inserting 1 split credit record for every Split record. 
    private static void insertSplitCreditRecords(List<Split__c> listSplitsToInsert){
        List<Splits_Credit__c> splitCreditsToInsert = new List<Splits_Credit__c>();
        
        for(Split__c split : listSplitsToInsert){
            Splits_Credit__c credit =  new Splits_Credit__c();
            credit.Split__c = split.id;
            credit.Split_Credit_Date__c = Date.today(); 
            //credit.Type__c = creditType;
            splitCreditsToInsert.add(credit);
        }
        insert splitCreditsToInsert;
    }
    
    
    //method to fetch all the Procurement Custom Setting data
    private static Map<String, Procurement_Split_Users_Config__mdt> fetchProcurementCustomMetadata(){
        Map<String, Procurement_Split_Users_Config__mdt> mapProcurements = new Map<String, Procurement_Split_Users_Config__mdt>();
        for(Procurement_Split_Users_Config__mdt procurementMDT : [Select DeveloperName, MasterLabel, Clinic_Caller__c, 
                                                                    Marketer__c, Package_Type__c, Price_per_unit__c, 
                                                                    Recruiter__c, Search_Type__c
                                                                    from Procurement_Split_Users_Config__mdt]){
            
            String isClinicalValuePresent = procurementMDT.Clinic_Caller__c != null ? 'YES' : 'NO';
            mapProcurements.put(procurementMDT.Package_Type__c + '--' + procurementMDT.Search_Type__c + '--' + isClinicalValuePresent, procurementMDT);
        }
        return mapProcurements;
    }
}
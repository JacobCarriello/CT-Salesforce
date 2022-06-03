global class Batch_CandidateStatusUpdate implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Inside Start Method');
          String query = 'Select Id, Assignment_Status__c From Contact Where RecordType.Name = \'Candidate\' OR RecordType.Name = \'Third Party - Govt\'';
        return Database.getQueryLocator(query);
    }

// If contains Doximity doesn’t work, might need to use RecordType.Name LIKE %\'Doximity\''%;

    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('Inside Execute Method');
        Set<Id> conIds = new Set<Id>();
        system.debug('scope : '+scope);
        for(sobject s : scope){
            conIds.add(s.Id);
        }
        system.debug('Scope: ConIds : '+conIds);        
        Map<Id, TRSCHED__Closing_Report_Schedule__c> mapConCRS = new Map<Id, TRSCHED__Closing_Report_Schedule__c>();
        Map<Id, TRSCHED__Closing_Report_Schedule__c> mapConCRS2 = new Map<Id, TRSCHED__Closing_Report_Schedule__c>();

        for(TRSCHED__Closing_Report_Schedule__c crs : [Select TRSCHED__Schedule_Date__c, TRSCHED__Closing_Report__r.TR1__Person_Placed__c, Tentative_or_Confirmed__c
                                                       From TRSCHED__Closing_Report_Schedule__c Where TRSCHED__Closing_Report__r.TR1__Person_Placed__c = :conIds
                                                       //and Tentative_or_Confirmed__c != 'Cancelled'
                                                       Order By TRSCHED__Schedule_Date__c DESC]){
                                                           
            if(!mapConCRS.containsKey(crs.TRSCHED__Closing_Report__r.TR1__Person_Placed__c)){
                mapConCRS.put(crs.TRSCHED__Closing_Report__r.TR1__Person_Placed__c, crs);
            }
        }  

// Map of any CRSs where the schedule date is greater than today, and it is Tentative or Confirmed

 for(TRSCHED__Closing_Report_Schedule__c crs2 : [Select TRSCHED__Schedule_Date__c, TRSCHED__Closing_Report__r.TR1__Person_Placed__c, Tentative_or_Confirmed__c
                                                       From TRSCHED__Closing_Report_Schedule__c Where TRSCHED__Closing_Report__r.TR1__Person_Placed__c = :conIds
                                                       and Tentative_or_Confirmed__c != 'Cancelled' and TRSCHED__Schedule_Date__c > TODAY  
                                                       Order By TRSCHED__Schedule_Date__c DESC]){
                                                           
            if(!mapConCRS2.containsKey(crs2.TRSCHED__Closing_Report__r.TR1__Person_Placed__c)){
                mapConCRS2.put(crs2.TRSCHED__Closing_Report__r.TR1__Person_Placed__c, crs2);
            }
        }  


        system.debug('mapConCRS : '+mapConCRS.keySet());
        system.debug('MapConCRS Set: '+mapConCRS);
        for(sobject s : scope){
                 if(!mapConCRS.containsKey(s.Id)){
               // s.put('Assignment_Status__c','New Provider');
            }
            else{
                if(mapConCRS.get(s.Id).TRSCHED__Schedule_Date__c > System.today() && (mapConCRS.get(s.Id).Tentative_or_Confirmed__c == 'Confirmed' || mapConCRS.get(s.Id).Tentative_or_Confirmed__c == 'Tentative' ||  mapConCRS2.containsKey(s.Id))){
                    s.put('Assignment_Status__c','Upcoming'); 
                }
                else if(mapConCRS.get(s.Id).TRSCHED__Schedule_Date__c == System.today() && mapConCRS.get(s.Id).Tentative_or_Confirmed__c == 'Confirmed'){
                    s.put('Assignment_Status__c','On Assignment');
                }
                else if(mapConCRS.get(s.Id).TRSCHED__Schedule_Date__c < System.today()){
                    s.put('Assignment_Status__c','Assignment Complete');
                }
 else if(mapConCRS.get(s.Id).TRSCHED__Schedule_Date__c > System.today() && mapConCRS.get(s.Id).Tentative_or_Confirmed__c == 'Cancelled'  && !mapConCRS2.containsKey(s.Id)) {
                    s.put('Assignment_Status__c','Assignment Complete');
                }

            }
        }
        System.debug('Final Scope before updating assignment status to db : '+scope);
        List<Database.SaveResult> results = Database.update(scope, false);
        for (Database.SaveResult result : results) {
          if (!result.isSuccess()){
            for (Database.Error err : result.getErrors()){
              System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
            }
            }
        }
        System.debug('Final : Updated successfully ');
        //Database.update(scope,true);
     }
    
    global void finish(Database.BatchableContext BC){
    }
}
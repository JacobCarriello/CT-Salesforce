public class SendOutTriggerHandler{
    public static Set<String> closingReportRecordTypes;
    
    static{
        closingReportRecordTypes = new Set<String>();
        closingReportRecordTypes.add('Allied Staffing');
        closingReportRecordTypes.add('CVConnection');
        closingReportRecordTypes.add('Fidelis');
        closingReportRecordTypes.add('TES');
    }
    
    public static void afterInsertUpdate(List<TR1__Send_Out__c> newList, Map<Id, TR1__Send_Out__c> oldMap){
        createSplitRecords(newList, oldMap);
    }
    
     //creating Split User records
    private static void createSplitRecords(List<TR1__Send_Out__c> newList, Map<Id, TR1__Send_Out__c> oldMap){
        Boolean isInsert = oldMap == null;
        Set<String> sendOutIds = new Set<String>();
        Set<String> splitsToDelete = new Set<String>();        
        List<Split__c> listSplitsToInsert = new List<Split__c>();
        String closingReportRecordTypeId = CallListGenerationController.getRecordTypeIdbyName('Split__c', 'Closing Report');
        
        for(TR1__Send_Out__c sendOut : newList){
            if(isInsert || sendOut.Split_Recruiter_lookup__c != oldMap.get(sendOut.id).Split_Recruiter_lookup__c){
                sendOutIds.add(sendOut.id);
            }
        }
        
        for(TR1__Job_Reporting__c jobReporting : [Select Id, TR1__Send_Out__c, TR1__Send_Out__r.Split_Recruiter_lookup__c, 
                                                   (Select Id, RecordTypeId, TR1__Candidate_Credit__c, TR1__Other2_Credit__c,
                                                   TR1__Job_Credit__c, TR1__Marketing_Credit__c, TR1__Job_Reporting__c, 
                                                   ECB_Amount__c, RecordType.Name from TR1__Closing_Reports__r  
                                                   where RecordType.Name IN: closingReportRecordTypes) 
                                                   from TR1__Job_Reporting__c 
                                                   where TR1__Send_Out__c in : sendOutIds]){
            
            for(TR1__Closing_Report__c cr : jobReporting.TR1__Closing_Reports__r){
                if(cr.TR1__Candidate_Credit__c != null){
                    listSplitsToInsert.add(ClosingReportTriggerHandler.prepareSplitRecord(cr.id, 0, cr.TR1__Candidate_Credit__c, closingReportRecordTypeId, splitsToDelete));
                }
                if(cr.TR1__Job_Credit__c != null){
                    listSplitsToInsert.add(ClosingReportTriggerHandler.prepareSplitRecord(cr.id, 0, cr.TR1__Job_Credit__c, closingReportRecordTypeId, splitsToDelete));
                }
                if(cr.TR1__Marketing_Credit__c != null){
                    listSplitsToInsert.add(ClosingReportTriggerHandler.prepareSplitRecord(cr.id, 0, cr.TR1__Marketing_Credit__c, closingReportRecordTypeId, splitsToDelete));
                }
                if(cr.TR1__Other2_Credit__c != null){
                    listSplitsToInsert.add(ClosingReportTriggerHandler.prepareSplitRecord(cr.id, 0, cr.TR1__Other2_Credit__c, closingReportRecordTypeId, splitsToDelete));
                }
                if(jobReporting.TR1__Send_Out__r.Split_Recruiter_lookup__c != null){
                    listSplitsToInsert.add(ClosingReportTriggerHandler.prepareSplitRecord(cr.id, 0, jobReporting.TR1__Send_Out__r.Split_Recruiter_lookup__c, closingReportRecordTypeId, splitsToDelete));
                }    
            }
            
            ClosingReportTriggerHandler.insertSplitAndSplitCreditRecords(listSplitsToInsert, splitsToDelete);
        }
    }    
}
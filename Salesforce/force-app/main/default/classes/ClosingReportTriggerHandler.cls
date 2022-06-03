public class ClosingReportTriggerHandler{

    public static void beforeInsertUpdate(List<TR1__Closing_Report__c> newList, Map<Id, TR1__Closing_Report__c> oldMap){
        boolean isInsert = oldMap == null;
        if(isInsert){
            assignContactFields(newList);
        }
    }
    
    public static void afterInsertUpdate(List<TR1__Closing_Report__c> newList, Map<Id, TR1__Closing_Report__c> oldMap){
        createSplitRecords(newList, oldMap);
    }
    
    //creating Split User records
    private static void createSplitRecords(List<TR1__Closing_Report__c> newList, Map<Id, TR1__Closing_Report__c> oldMap){
        
        Boolean isInsert = oldMap == null;
        List<Split__c> listSplitsToInsert = new List<Split__c>();
        Set<String> splitsToDelete = new Set<String>();
        Set<String> setJobReportingIds = new Set<String>();
        Map<String, TR1__Job_Reporting__c> mapJobReporting = new   Map<String, TR1__Job_Reporting__c>();      
        String closingReportRecordTypeId = CallListGenerationController.getRecordTypeIdbyName('Split__c', 'Closing Report');
        
        for(TR1__Closing_Report__c cr : newList){
            if(cr.RecordTypeId != null &&  
                (getRecordTypeNameById('TR1__Closing_Report__c', cr.RecordTypeId) == 'Allied Staffing' || 
                getRecordTypeNameById('TR1__Closing_Report__c', cr.RecordTypeId) == 'CVConnection' ||
                getRecordTypeNameById('TR1__Closing_Report__c', cr.RecordTypeId) == 'Fidelis' ||
                getRecordTypeNameById('TR1__Closing_Report__c', cr.RecordTypeId) == 'TES') && 
                (isInsert || cr.TR1__Candidate_Credit__c != oldMap.get(cr.Id).TR1__Candidate_Credit__c || 
                cr.TR1__Other2_Credit__c != oldMap.get(cr.Id).TR1__Other2_Credit__c || 
                cr.TR1__Job_Credit__c != oldMap.get(cr.Id).TR1__Job_Credit__c ||
                cr.TR1__Marketing_Credit__c != oldMap.get(cr.Id).TR1__Marketing_Credit__c ||
                cr.TR1__Job_Reporting__c != oldMap.get(cr.Id).TR1__Job_Reporting__c || 
                cr.RecordTypeId != oldMap.get(cr.Id).RecordTypeId)){
                    
                    if(cr.TR1__Candidate_Credit__c != null){
                        listSplitsToInsert.add(prepareSplitRecord(cr.id, 0, cr.TR1__Candidate_Credit__c, closingReportRecordTypeId, splitsToDelete));
                    }
                    if(cr.TR1__Job_Credit__c != null){
                        listSplitsToInsert.add(prepareSplitRecord(cr.id, 0, cr.TR1__Job_Credit__c, closingReportRecordTypeId, splitsToDelete));
                    }
                    if(cr.TR1__Marketing_Credit__c != null){
                        listSplitsToInsert.add(prepareSplitRecord(cr.id, 0, cr.TR1__Marketing_Credit__c, closingReportRecordTypeId, splitsToDelete));
                    }
                    if(cr.TR1__Other2_Credit__c != null){
                        listSplitsToInsert.add(prepareSplitRecord(cr.id, 0, cr.TR1__Other2_Credit__c, closingReportRecordTypeId, splitsToDelete));
                    }
                    if(cr.TR1__Job_Reporting__c != null){
                        setJobReportingIds.add(cr.TR1__Job_Reporting__c);
                    }
                    /*
                    if(cr.TR1__Candidate_Credit__c == null){
                        if(cr.ECB_Amount__c == null){
                            if(cr.TR1__Job_Credit__c != null){
                                listSplitsToInsert.add(prepareSplitRecord(cr.id, 100, cr.TR1__Job_Credit__c, closingReportRecordTypeId, splitsToDelete));
                            }
                        }else{
                            if(cr.TR1__Job_Credit__c != null){
                                listSplitsToInsert.add(prepareSplitRecord(cr.id, 50, cr.TR1__Job_Credit__c, closingReportRecordTypeId, splitsToDelete));
                            }
                            if(cr.TR1__Marketing_Credit__c != null){
                                listSplitsToInsert.add(prepareSplitRecord(cr.id, 50, cr.TR1__Marketing_Credit__c, closingReportRecordTypeId, splitsToDelete));
                            }
                        }
                    }else {
                        if(cr.ECB_Amount__c == null){
                            if(cr.TR1__Job_Credit__c != null){
                                listSplitsToInsert.add(prepareSplitRecord(cr.id, 50, cr.TR1__Job_Credit__c, closingReportRecordTypeId, splitsToDelete));
                            }
                            listSplitsToInsert.add(prepareSplitRecord(cr.id, 50, cr.TR1__Candidate_Credit__c, closingReportRecordTypeId, splitsToDelete));
                        }else{
                            listSplitsToInsert.add(prepareSplitRecord(cr.id, 50, cr.TR1__Candidate_Credit__c, closingReportRecordTypeId, splitsToDelete));
                            if(cr.TR1__Job_Credit__c != null){
                                listSplitsToInsert.add(prepareSplitRecord(cr.id, 50, cr.TR1__Job_Credit__c, closingReportRecordTypeId, splitsToDelete));
                            }
                            if(cr.TR1__Marketing_Credit__c != null){
                                listSplitsToInsert.add(prepareSplitRecord(cr.id, 50, cr.TR1__Marketing_Credit__c, closingReportRecordTypeId, splitsToDelete));
                            }     
                        }
                    }*/
                }
        }
        
        //querying the Split Recruiter
        for(TR1__Job_Reporting__c jobReporting : [Select Id, TR1__Send_Out__r.Split_Recruiter__c , TR1__Send_Out__r.Split_Recruiter_lookup__c
                                                    from TR1__Job_Reporting__c 
                                                    where Id in : setJobReportingIds AND 
                                                    TR1__Send_Out__r.Split_Recruiter_lookup__c != null]){
            mapJobReporting.put(jobReporting.id, jobReporting);
        }
        
        for(TR1__Closing_Report__c cr : newList){
            if(mapJobReporting.containsKey(cr.TR1__Job_Reporting__c)){
                listSplitsToInsert.add(prepareSplitRecord(cr.id, 0, mapJobReporting.get(cr.TR1__Job_Reporting__c).TR1__Send_Out__r.Split_Recruiter_lookup__c, closingReportRecordTypeId, splitsToDelete));
            }
        }
        insertSplitAndSplitCreditRecords(listSplitsToInsert, splitsToDelete);
    }
    
    public static void insertSplitAndSplitCreditRecords(List<Split__c> listSplitsToInsert, Set<String> splitsToDelete){
        Savepoint sp = Database.setSavepoint();
        try{
            if(listSplitsToInsert.size() > 0){
                //deleting the existing ones
                if(splitsToDelete.size() > 0){
                    delete [Select Id from Split__c where Closing_Report__c IN : splitsToDelete];
                }
                
                //Inserting the new ones
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
    //TODO : Add the type
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
    
    public static Split__c prepareSplitRecord(String closingReportId, 
                                                Decimal splitPercentage, 
                                                String userId, 
                                                String closingReportRecordTypeId,
                                                Set<String> splitsToDelete){
        splitsToDelete.add(closingReportId);
        return new Split__c(Closing_Report__c = closingReportId, 
                                    Split_Percentage__c = splitPercentage,
                                    User__c = userId,
                                    Role__c = Label.Recruiter_Role, 
                                    RecordTypeId = closingReportRecordTypeId);
    }
    
    private static void assignContactFields(List<TR1__Closing_Report__c> newList){
        Set<String> jobs = new Set<String>();
        Set<String> contacts = new Set<String>();        
        for(TR1__Closing_Report__c cr : newList){
            if(cr.TR1__Job__c != null){
                jobs.add(cr.TR1__Job__c);
            }
            if(cr.TR1__Person_Placed__c != null){
                contacts.add(cr.TR1__Person_Placed__c);
            }            
        }
        
        Map<String, TR1__Send_Out_Schedule__c> mapSendoutSchedules = new Map<String, TR1__Send_Out_Schedule__c>();
        //searching for Interview Schedules
        for(TR1__Send_Out_Schedule__c sch : [Select Id, Split_Recruiter__c, TR1__Send_Out__r.TR1__Job__c, TR1__Interviewee__c  
                                             from TR1__Send_Out_Schedule__c 
                                             WHERE TR1__Send_Out__r.TR1__Job__c in : jobs 
                                             AND TR1__Interviewee__c in : contacts]){
            mapSendoutSchedules.put(sch.TR1__Interviewee__c + '====' + sch.TR1__Send_Out__r.TR1__Job__c, sch);
        }
        
        //assigning the split recruiter
        for(TR1__Closing_Report__c cr : newList){
            if(mapSendoutSchedules.containsKey(cr.TR1__Person_Placed__c + '====' + cr.TR1__Job__c) ){
                cr.TR1__Candidate_Credit__c = mapSendoutSchedules.get(cr.TR1__Person_Placed__c + '====' + cr.TR1__Job__c).Split_Recruiter__c;
            }
        }
    }
    
    //common  method to fetch the record Type Name by Id
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId){
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSobjectResult objTypeDesc = objType.getDescribe();
        Map<Id, Schema.RecordTypeInfo> recTypeMap = objTypeDesc.getRecordTypeInfosById();
        Schema.RecordTypeInfo rtById =  recTypeMap.get(strRecordTypeId);
        if(rtById != null){
            return  rtById.getName();
        }else{ return null;}
    }

}
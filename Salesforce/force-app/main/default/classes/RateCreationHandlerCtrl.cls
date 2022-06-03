/*
 Author : Veda Arvind Kaja.
 Date : 24 july 2017.
 Description : This class Contains below three methods.
               1. getRateFromAccount : While creating a job "Rates From Account?" is 'Yes',
                   then It will fetch the rates related to the selected account if exists.
               2. getRateFromJob : While creating a Closing Report "Rates From Job?" is 'Yes',
                   then It will fetch the rates related to the selected job if exists.
               3. getRateFromCR : While creating a Timesheet It will fetch the rates related to the
                   selected Closing Report if exists with out any condition.
Last Modified By : Veda Arvind Kaja.Modified for the work Item W-014829.
Last Modified Date : 28 may 2018. 
*/
Public class RateCreationHandlerCtrl{
   public static final String ACCOUNT_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Account Rate').getRecordTypeId();
   public static final String JOB_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Job Rate').getRecordTypeId();
   public static final String CLOSINGREPORT_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Closing Report Rate').getRecordTypeId();
   public static final String TIMETYPE_RECORDTYPE_RATE = Schema.SObjectType.TR1__TimeType__c.getRecordTypeInfosByName().get('Timesheet Time Type').getRecordTypeId();
   public static final String TIMESHEET_RECORDTYPE_RATE = Schema.SObjectType.TR1__Rate__c.getRecordTypeInfosByName().get('Timesheet Rate').getRecordTypeId();
   Public static void getRateFromAccount(List <TR1__Job__c> recordNewList){
      set<Id> accids = new set<Id>();
      Map <Id,list<TR1__Rate__c>> rateListAccMap = new Map <Id,list<TR1__Rate__c>>();
      list<TR1__Rate__c> jobratelistInsert = new list<TR1__Rate__c>();
      for(TR1__Job__c job : recordNewList){
        If(job.TR1__Account__c != null && job.TR1__Rates_From_Account__c == 'Yes' ){
         accids.add(job.TR1__Account__c);
        }
       }
       if(!accids.IsEmpty()){
          string queryFields = getQuery() ;
          queryFields +=  ' where TR1__Account__c in:accids and recordtype.id=: ACCOUNT_RECORDTYPE_RATE and TR1__Active__c != false ' ;  
          for( TR1__Rate__c rates: Database.query( queryFields ) )
           {
              if(!rateListAccMap.containsKey(rates.TR1__Account__c)){
                  rateListAccMap.put(rates.TR1__Account__c,new List <TR1__Rate__c> {rates});
               }
              else{
                  rateListAccMap.get(rates.TR1__Account__c).add(rates);
               }
           }
         }

         if(rateListAccMap != null){
            for (TR1__Job__c job : recordNewList) {
                if(job.TR1__Account__c != null){
                    if(rateListAccMap.containskey(job.TR1__Account__c)){
                        for(TR1__Rate__c rates : rateListAccMap.get(job.TR1__Account__c)){
                          TR1__Rate__c clonerate = rates.clone();
                          clonerate.TR1__Job__c = job.id ;
                          clonerate.TR1__Account__c = null ;
                          clonerate.RecordTypeId =  JOB_RECORDTYPE_RATE ;
                          jobratelistInsert.add(clonerate);
                        }
                    }
                }
            }
         }

         if(jobratelistInsert.size()>0){
           insert jobratelistInsert;
         }

      }

      Public static void getRateFromJob(List <TR1__Closing_Report__c> recordNewList){
        set<id> jobIds = new set<id>();
        list<TR1__Rate__c> closingRepratelist = new list<TR1__Rate__c>();
        Map <Id,list<TR1__Rate__c>> rateListJobMap = new Map <Id,list<TR1__Rate__c>>();
        for(TR1__Closing_Report__c cr : recordNewList){
          if(cr.TR1__Rates_From_Job__c == 'Yes' && cr.TR1__Job__c != null){
            jobIds.add(cr.TR1__Job__c);
          }
        }

        if(!jobids.isEmpty()){
          string queryFields = getQuery() ;
          queryFields +=  ' where  TR1__Job__c in:jobids and recordtype.id =: JOB_RECORDTYPE_RATE and TR1__Active__c != false ' ;
          for(TR1__Rate__c rates:  Database.query( queryFields ) )
            {
              if (!rateListJobMap.containsKey(rates.TR1__Job__c)){
                  rateListJobMap.put(rates.TR1__Job__c,new List <TR1__Rate__c> {rates});
               }
              else{
                  rateListJobMap.get(rates.TR1__Job__c).add(rates);
               }
            }
         }

         if(rateListJobMap != null){
            for (TR1__Closing_Report__c cr : recordNewList) {
                if(cr.TR1__Job__c!=null){
                    if(rateListJobMap.containskey(cr.TR1__Job__c)){
                        for(TR1__Rate__c rates:rateListJobMap.get(cr.TR1__Job__c)){
                          TR1__Rate__c clonerate = rates.clone();
                          clonerate.TR1__Job__c = null ;
                          clonerate.TR1__ClosingReport__c = cr.id;
                          clonerate.RecordTypeId =  CLOSINGREPORT_RECORDTYPE_RATE ;
                          closingRepratelist.add(clonerate);

                        }
                    }
                }
            }
        }

      if(closingRepratelist.size() > 0){
        insert closingRepratelist ;
       }
    }

    Public static void getRateFromCR(List <TR1__Timesheet__c> recordNewList){
       Set < Id > closingReportIds = new Set < Id > ();
       for(TR1__Timesheet__c ts : recordNewList){
          closingReportIds.add(ts.TR1__Closing_Report__c);
        }
        Map <Id,list<TR1__Rate__c>> rateListMap = new Map <Id,list<TR1__Rate__c>>();
        List<TR1__Rate__c> rateListUpdate = new List<TR1__Rate__c>();
         if(!closingReportIds.IsEmpty()){
           string queryFields = getQuery() ;
           queryFields +=  ' where TR1__ClosingReport__c  in: closingReportIds  and  recordtype.id  =: CLOSINGREPORT_RECORDTYPE_RATE  and TR1__TimeType__r.RecordType.id  =:  TIMETYPE_RECORDTYPE_RATE  and  TR1__Active__c != false ' ;
           system.debug('queryFields===>'+queryFields);
           for(TR1__Rate__c rates: Database.query( queryFields )  )
             {
                if (!rateListMap.containsKey(rates.TR1__ClosingReport__c)){
                    rateListMap.put(rates.TR1__ClosingReport__c,new List <TR1__Rate__c> {rates});
                 }
                else{
                    rateListMap.get(rates.TR1__ClosingReport__c).add(rates);
                 }
             }
          }

         if(rateListMap != null){
            for (TR1__Timesheet__c timesheets: recordNewList) {
                if(timesheets.TR1__Closing_Report__c!=null){
                    if(rateListMap.containskey(timesheets.TR1__Closing_Report__c)){
                        for(TR1__Rate__c rates:rateListMap.get(timesheets.TR1__Closing_Report__c)){
                          TR1__Rate__c clonerate = rates.clone();
                          clonerate.TR1__Timesheet__c = timesheets.id ;
                          clonerate.TR1__ClosingReport__c = null;
                          clonerate.RecordTypeId = TIMESHEET_RECORDTYPE_RATE ;
                          rateListUpdate.add(clonerate);

                        }
                    }
                }
            }
        }

       if(rateListUpdate.size()>0){
         insert rateListUpdate;
       }

    }

   // Modified for the work item W-014829.
   private static string getQuery(){
       
    /* DescribeSObjectResult describeResult = TR1__Rate__c.getSObjectType().getDescribe();
    List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
    String query =
      ' SELECT ' +
          String.join( fieldNames, ',' ) +
      ' FROM ' +
          describeResult.getName()
    ;
    List<SObject> records = Database.query( query ); */
    Set<String> sQueryfields = new Set<String>();
    String sQuery='SELECT ';
    for(Schema.FieldSetMember f : SObjectType.TR1__Rate__c.FieldSets.SyncRate_Data.getFields()) {
        sQueryfields.add(f.getFieldPath());         
    }  
    for(String fs : sQueryfields){
        sQuery += fs + ',';
    }
    sQuery = sQuery.removeEnd(',') ;
    sQuery += ' FROM TR1__Rate__c';
    return sQuery ; 
    
  }


}
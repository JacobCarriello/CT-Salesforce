/************************************************************************************************************
Acc-Product Team 1:10/3/2017: W-008217 - TR core - Timesheet generation based on week end from Closing Report
*************************************************************************************************************/
global with sharing class CreateTimeSheetsByWeekending implements Database.Batchable<sObject>{
    global final String query;
    global final Date runDate;
    global boolean weekStartflag=false;
    global CreateTimeSheetsByWeekending (String q){         
        this.query = q;
        this.runDate = Date.today().tostartofWeek() + 1;
        Datetime runDateTime = datetime.newInstance(runDate.year(), runDate.month(),runDate.day());
        //if(runDateTime.format('EEEE').equalsIgnoreCase('Monday')){
        //    runDate = runDate.addDays(-1);
        //}        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('Current scope size:'+scope);
        if (scope.size()>0){
        
            List<TR1__Timesheet__c> timesheets = new List<TR1__Timesheet__c>(); // to remove namespace
            Set<Id> cridset = new Set<Id>();        
            Set<Id> defcridset = new Set<Id>();        
            Date weekenddate;
            Date defaultweekenddate;
            integer AddDaysForMondayOffset = 0;
            Date StartOfWeek;
            Date EndOfWeek;
        
            //step 1 - Initialise timesheet type
            String timesheetType = label.Weekly; 
            if(TR1__TalentRoverProperties__c.getOrgDefaults() != null &&  
                TR1__TalentRoverProperties__c.getOrgDefaults().TR1__TimesheetType__c!=null) 
                timesheetType = TR1__TalentRoverProperties__c.getOrgDefaults().TR1__TimesheetType__c; 
        
            //step 2 - calculate weekend date based on timesheet type
            if(TimesheetType == label.Weekly) {
                weekenddate = runDate.addDays(6);
            }
            else if(TimesheetType == label.Bi_Weekly) 
                weekenddate = runDate.addDays(13);
            else if(TimesheetType == label.Semi_Monthly){
                if(runDate.day() >= 16)
                    weekenddate = runDate.toStartOfMonth().addDays(date.daysInMonth(runDate.year(),runDate.month())-1);
                else
                    weekenddate = runDate.toStartOfMonth().addDays(13);
            }
            else if(TimesheetType == label.Monthly)
                weekenddate = runDate.toStartOfMonth().addDays(date.daysInMonth(runDate.year(),runDate.month())-1);
            
            defaultweekenddate = TR1.Utility.calculateEndDateBasedOnTimesheetType(runDate, timesheetType);
            system.debug('weekend date:'+weekenddate);
            system.debug('def weekend date:'+defaultweekenddate);  
            
            /**Changed this logic as part of TR-2129**/
            TR1__Closing_Report__c cReport;
            Map<Id,Map<Id,list<TRSCHED__Closing_Report_Schedule__c>>> mapCRIdVSMapWIDVSCRSList = new Map<Id,Map<Id,list<TRSCHED__Closing_Report_Schedule__c>>>();
            Map<Id,list<TRSCHED__Closing_Report_Schedule__c>> mapWIDVSCRSList;
            Map<Id,TR1__Closing_Report__c> mapCRIdVsCR = new Map<Id,TR1__Closing_Report__c>();
            set<Id> worksiteIds = new set<Id>();
            
           // Creating a map which holds all the CRSs of CR based on Work site location
            for(Sobject cR:scope){
                 cReport = (TR1__Closing_Report__c)cR;
                 mapWIDVSCRSList = new Map<Id,list<TRSCHED__Closing_Report_Schedule__c>>();
                 for(TRSCHED__Closing_Report_Schedule__c cReportSchedule:cReport.TRSCHED__ClosingReportSchedules__r){
                     if(mapWIDVSCRSList.containskey(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c)){
                         mapWIDVSCRSList.get(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c).add(cReportSchedule);
                     }else{
                         mapWIDVSCRSList.put(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c, new list<TRSCHED__Closing_Report_Schedule__c>{cReportSchedule});
                     }
                     worksiteIds.add(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c);               
                 }
                 if(mapWIDVSCRSList != null && mapWIDVSCRSList.size() > 0){
                     mapCRIdVSMapWIDVSCRSList.put(cReport.Id,mapWIDVSCRSList);
                     mapCRIdVsCR.put(cReport.Id,cReport); 
                 }               
            }
            
            Map<Id,Account> worsiteLocations = new map<Id,Account>([select id, Name,Timesheet_Approver__c from Account
                                                    where id in :worksiteIds]);
            
            list<TR1__Timesheet__c> timesheetList = [SELECT TR1__Closing_Report__c,TR1__Week_Ending__c,Work_Shift_Location__c
                                                        , (SELECT Id, Name, TR1__Date__c,TRSCHED__Closing_Report_Schedule__c,TR1__Timesheet__r.Work_Shift_Location__c FROM TR1__Timecards__r )
                                                        FROM TR1__Timesheet__c
                                                        WHERE TR1__Closing_Report__c IN :mapCRIdVsCR.keyset() 
                                                        AND (TR1__Week_Ending__c = :weekenddate OR TR1__Week_Ending__c = :defaultweekenddate)];
                     
            Map<Id,Map<Id,TR1__Timesheet__c>> mapCRVSWSIdVSTimesheet = new Map<Id,Map<Id,TR1__Timesheet__c>>();
            map<Id,list<TR1__Timesheet_Detail__c>> mapCRSIdVsTimesheetDetails = new map<Id,list<TR1__Timesheet_Detail__c>>();
            
            // Creating a map which holds all the Timesheet of CR based on Work site location
            for(TR1__Timesheet__c timesheet:timesheetList){
                if(mapCRVSWSIdVSTimesheet.containskey(timesheet.TR1__Closing_Report__c)){
                    mapCRVSWSIdVSTimesheet.get(timesheet.TR1__Closing_Report__c).put(timesheet.Work_Shift_Location__c,timesheet);
                }else{
                   mapCRVSWSIdVSTimesheet.put(timesheet.TR1__Closing_Report__c, new map<Id,TR1__Timesheet__c>{timesheet.Work_Shift_Location__c =>timesheet}); 
                }
                for(TR1__Timesheet_Detail__c tDetail:timesheet.TR1__Timecards__r ){
                    if(mapCRSIdVsTimesheetDetails.containskey(tDetail.TRSCHED__Closing_Report_Schedule__c)){
                        mapCRSIdVsTimesheetDetails.get(tDetail.TRSCHED__Closing_Report_Schedule__c).add(tDetail);
                    }else{
                        mapCRSIdVsTimesheetDetails.put(tDetail.TRSCHED__Closing_Report_Schedule__c, new list<TR1__Timesheet_Detail__c>{tDetail});
                    }
                }
            }
            
            system.debug('*************Timesheet******'+mapCRVSWSIdVSTimesheet);
            list<TR1__Timesheet__c> newtimesheetList = new list<TR1__Timesheet__c>();
            TR1__Timesheet__c timesheet;
            
            // Creating a timesheet if the corresponding worksite location not present
            for(Id cReportId:mapCRIdVsCR.keyset()){
                cReport  = mapCRIdVsCR.get(cReportId);
                for(Id worksiteId:mapCRIdVSMapWIDVSCRSList.get(cReportId).keyset()){
                   
                    if(mapCRVSWSIdVSTimesheet != null && mapCRVSWSIdVSTimesheet.containskey(cReportId)
                        && mapCRVSWSIdVSTimesheet.get(cReportId).containsKey(worksiteId)){
                    }else{
                        timesheet = new TR1__Timesheet__c();
                        timesheet.TR1__Status__c='Unsubmitted';
                        timesheet.TR1__Closing_Report__c =cReport.Id;
                        timesheet.TR1__Consultant__c=cReport.TR1__Person_Placed__c;
                        timesheet.TR1__Job_Order__c = cReport.TR1__Job__c;
                       if(worsiteLocations != null && worsiteLocations.containskey(worksiteId) && worsiteLocations.get(worksiteId).Timesheet_Approver__c != null){
                            timesheet.TR1__Approver__c= worsiteLocations.get(worksiteId).Timesheet_Approver__c;
                        }else{
                            timesheet.TR1__Approver__c= cReport.TR1__Timesheet_Approver__c;
                        }                        
                        timesheet.TR1__Timesheet_Second_Approver__c = cReport.TR1__Timesheet_Second_Approver__c;
                        timesheet.TR1__Client__c= cReport.TR1__Account__c;
                       /* if (cReport.TR1__Week_Ending__c != '' && cReport.TR1__Week_Ending__c != null){
                            timesheet.TR1__Week_Ending__c = weekenddate;
                            timesheet.TR1__Pay_Week_Ending__c = weekenddate;   
                        }   
                        else{
                            timesheet.TR1__Week_Ending__c = weekenddate; 
                            timesheet.TR1__Pay_Week_Ending__c = defaultweekenddate; 
                        } */
                        timesheet.TR1__Week_Ending__c = weekenddate; 
                        timesheet.TR1__Pay_Week_Ending__c = weekenddate; 
                        timesheet.Work_Shift_Location__c = worksiteId;
                        newtimesheetList.add(timesheet); 
                    }
                }
            }
            //system.debug('****newtimesheetList**********'+newtimesheetList);
            Database.insert(newtimesheetList,false);
            for(TR1__Timesheet__c tsheet:newtimesheetList){
                if(mapCRVSWSIdVSTimesheet.containskey(tsheet.TR1__Closing_Report__c)){
                    mapCRVSWSIdVSTimesheet.get(tsheet.TR1__Closing_Report__c).put(tsheet.Work_Shift_Location__c,tsheet);
                }else{
                   mapCRVSWSIdVSTimesheet.put(tsheet.TR1__Closing_Report__c, new map<Id,TR1__Timesheet__c>{tsheet.Work_Shift_Location__c =>tsheet}); 
                }
            }
           // system.debug('****mapCRVSWSIdVSTimesheet**********'+mapCRVSWSIdVSTimesheet);
            //system.debug('*******mapCRIdVSMapWIDVSCRSList****'+mapCRIdVSMapWIDVSCRSList);
            TR1__Timesheet_Detail__c tDetail;
            list<TR1__Timesheet_Detail__c> tDetailList = new list<TR1__Timesheet_Detail__c>();
            set<Id> timesheetIds = new set<Id>();
            
            // Creating/updating timesheets based on work site location
            for(Id cReportId:mapCRIdVsCR.keyset()){
                cReport  = mapCRIdVsCR.get(cReportId);
                for(Id worksiteId:mapCRIdVSMapWIDVSCRSList.get(cReportId).keyset()){
                    for(TRSCHED__Closing_Report_Schedule__c cRSchedule:mapCRIdVSMapWIDVSCRSList.get(cReportId).get(worksiteId)){
                        if(!mapCRSIdVsTimesheetDetails.containskey(cRSchedule.Id)){
                            // system.debug('****cReportId**********'+cReportId);
                           // system.debug('*******worksiteId****'+worksiteId);
                           // system.debug('**********mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId)**'+mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId));
                            tDetail = new TR1__Timesheet_Detail__c(TR1__Timesheet__c = mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId).id, 
                                                                TR1__Date__c = cRSchedule.TRSCHED__Schedule_Date__c ,
                                                                 TR1__Day__c = TR1.Utility.dayOfDate(cRSchedule.TRSCHED__Schedule_Date__c),
                                                                 TRSCHED__Closing_Report_Schedule__c = cRSchedule.Id);
                           tDetailList.add(tDetail);
                        }else{
                            for(TR1__Timesheet_Detail__c tDet:mapCRSIdVsTimesheetDetails.get(cRSchedule.Id)){
                                if(tDet.TR1__Date__c != cRSchedule.TRSCHED__Schedule_Date__c || 
                                    tDet.TR1__Timesheet__r.Work_Shift_Location__c != cRSchedule.TRSCHED__Work_Shift_Location_lkId__c){
                                     if(tDet.TR1__Date__c != cRSchedule.TRSCHED__Schedule_Date__c ){
                                        tDet.TR1__Date__c = cRSchedule.TRSCHED__Schedule_Date__c ;
                                     }
                                     if(tDet.TR1__Timesheet__r.Work_Shift_Location__c != cRSchedule.TRSCHED__Work_Shift_Location_lkId__c){
                                         tDet.TR1__Timesheet__c = mapCRVSWSIdVSTimesheet.get(cReportId).get(worksiteId).id;
                                     }
                                     tDetailList.add(tDet);
                                }
                            }
                        }
                    }
                    
                }
            }
            system.debug('***tDetailList*******'+tDetailList);
            Database.upsert(tDetailList, false);
            //Delete the Timesheets if there are no timesheet details present
            list<TR1__Timesheet__c> deleteTList = new list<TR1__Timesheet__c>();
            timesheetList = [SELECT Id, Name,(SELECT Id, Name FROM TR1__Timecards__r ) FROM TR1__Timesheet__c 
                                                        WHERE TR1__Closing_Report__c IN :mapCRIdVsCR.keyset() 
                                                        AND (TR1__Week_Ending__c = :weekenddate OR TR1__Week_Ending__c = :defaultweekenddate) ];
            for(TR1__Timesheet__c  tSh: timesheetList){
                if(tSh.TR1__Timecards__r == null || tSh.TR1__Timecards__r.size() == 0){
                    deleteTList.add(tSh);
                }
            }
            if(deleteTList != null && deleteTList.size() > 0){
                Database.delete(deleteTList,false);
            }
       }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];    
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Timesheet Creation Batch program ' + a.Status);
            mail.setPlainTextBody
            ('The batch Apex job'+'('+ BC.getJobId()+')processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){}
    }
}
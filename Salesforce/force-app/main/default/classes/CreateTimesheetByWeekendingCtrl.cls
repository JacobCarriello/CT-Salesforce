public with sharing class CreateTimesheetByWeekendingCtrl{
    public String crid { get; set; }
    public String msg { get; set;}
    public TR1__Closing_Report__c cr {get;set;}
    public Date SelectedDate {set;get;}
    public Date StartOfWeek {set;get;}
    public Date EndOfWeek {set;get;}
    public TR1__Timesheet__c tempTimesheet{set;get;}
    public String timesheetType {set;get;}
    Date defaultEndOfWeek;    
    public   List<TR1__Closing_Report__c> crlist {get;set;}
    public CreateTimesheetByWeekendingCtrl(ApexPages.StandardController controller) { 
        crlist = new List<TR1__Closing_Report__c>();
        tempTimesheet = new TR1__Timesheet__c();
        tempTimesheet.TR1__Week_Ending__c = Date.Today();
        this.crid = ApexPages.currentPage().getParameters().get('crid');
        this.SelectedDate = tempTimesheet.TR1__Week_Ending__c;
        if(TR1__TalentRoverProperties__c.getOrgDefaults() != null && TR1__TalentRoverProperties__c.getOrgDefaults().TR1__TimesheetType__c!=null)
            this.timesheetType = TR1__TalentRoverProperties__c.getOrgDefaults().TR1__TimesheetType__c;
        else
            this.timesheetType = label.Weekly; //Default
        
        	//this.StartOfWeek = TR1.Utility.calculateStartDateBasedOnTimesheetType(selectedDate, timesheetType);
        	//this.EndOfWeek = TR1.Utility.calculateEndDateBasedOnTimesheetType(selectedDate, timesheetType); 
        	this.StartOfWeek = calculateStartDate(selectedDate);
        	this.EndOfWeek = calculateEndDate(selectedDate);
        
        System.debug('StartOfWeek....'+StartOfWeek +'EndOfWeek....'+EndOfWeek);
        
        try {
            if (crid != null) {
                cr = [SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,
                      TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,
                      TR1__Week_Ending__c,TR1__Timesheet_Approver__c,
                      TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c, TR1__Pay_Rate__c,
                      TR1__Payroll_Type__c,TR1__Week_Start__c, (SELECT Id, Name, lastmodifieddate,TRSCHED__Work_Shift_Location_lkId__r.Timesheet_Approver__c,TRSCHED__WeekEndDate__c, TRSCHED__Schedule_Date__c 
                                                                //FROM TRSCHED__ClosingReportSchedules__r  WHERE TRSCHED__Schedule_Date__c >= :StartOfWeek   and TRSCHED__Schedule_Date__c <= :EndOfWeek  ) 
                                                                FROM TRSCHED__ClosingReportSchedules__r ) 
                      FROM TR1__Closing_Report__c
                      WHERE Id = : crid
                      //AND RecordTypeId = : crconsultingId
                      AND TR1__Generate_Timesheet__c = true
                      AND TR1__Assignment_Ended__c = 'No'
                      AND((TR1__Start_Date__c <= : StartOfWeek AND(TR1__End_Date__c >= : StartOfWeek OR TR1__End_Date__c = null)) OR(TR1__Start_Date__c >= : StartOfWeek AND TR1__Start_Date__c <= : EndOfWeek AND(TR1__End_Date__c >= : StartOfWeek OR TR1__End_Date__c = null)))
                     ];
                msg = Label.CreateTSPage_Ctrl_Constructor_try_MSG;
                crlist.add(cr);
            }
        } catch (Exception ex) {
            msg = Label.CreateTSPage_Ctrl_Constructor_catch_MSG;
        }
    }
    public PageReference createts() {
        try {
            if (tempTimesheet.TR1__Week_Ending__c != null ) {
                SelectedDate = tempTimesheet.TR1__Week_Ending__c;
                // Step 1. Calculate Start of Week based on CR.Client.PayPeriodStart
                integer count = 0; 
                Date StartOfWeekTemp;
                StartOfWeekTemp = SelectedDate.tostartofWeek() + 1;
                Datetime runDateTime = Datetime.newInstance(StartOfWeekTemp.year(),StartOfWeekTemp.month(),StartOfWeekTemp.day());
                //if(runDateTime.format('EEEE').equalsIgnoreCase('Monday')){
                //    StartOfWeekTemp = StartOfWeekTemp .addDays(-1);
                //}        
                //step 2 - calculate weekend date based on timesheet type
                if(TimesheetType == label.Weekly)
                {
                    EndOfWeek= StartOfWeekTemp.addDays(6);
                    system.debug('Weekly TimesheetType:'+EndOfWeek);
                }else if(TimesheetType == label.Bi_Weekly){
                    EndOfWeek= StartOfWeekTemp.addDays(13);
                    system.debug('Bi-Weekly TimesheetType:'+EndOfWeek);
                }else if(TimesheetType ==label.Semi_Monthly) {
                    if(StartOfWeekTemp.day() >= 16)
                    {
                        EndOfWeek= StartOfWeekTemp.toStartOfMonth().addDays(date.daysInMonth(StartOfWeekTemp.year(),StartOfWeekTemp.month())-1);
                        system.debug('Semi-Monthly TimesheetType1:'+EndOfWeek);
                    }else{
                        EndOfWeek= StartOfWeekTemp.toStartOfMonth().addDays(13);
                        system.debug('Semi-Monthly TimesheetType2:'+EndOfWeek);
                    }
                }else if(TimesheetType == label.Monthly) {
                    EndOfWeek = StartOfWeekTemp.toStartOfMonth().addDays(date.daysInMonth(StartOfWeekTemp.year(),StartOfWeekTemp.month())-1);
                    system.debug('StartOfWeek--'+StartOfWeek+'EndOfWeek---'+EndOfWeek);
                }
                
                StartOfWeek = StartOfWeekTemp;
                // Step 2 .Calculate defWekending date.
                defaultEndOfWeek = TR1.Utility.calculateEndDateBasedOnTimesheetType(SelectedDate, timesheetType);
                
                /***** TR-4478 ****/
                Map<Id,Map<Id,list<TRSCHED__Closing_Report_Schedule__c>>> mapCRIdVSMapWIDVSCRSList = new Map<Id,Map<Id,list<TRSCHED__Closing_Report_Schedule__c>>>();
                Map<Id,list<TRSCHED__Closing_Report_Schedule__c>> mapWIDVSCRSList;
                Map<Id,TR1__Closing_Report__c> mapCRIdVsCR = new Map<Id,TR1__Closing_Report__c>();
                set<Id> worksiteIds = new set<Id>();    
                  List<TR1__Closing_Report__c> crlist = new List<TR1__Closing_Report__c>();
                
                if (crid != null) {
                   crlist = [SELECT Id,Name,TR1__Start_Date__c,TR1__End_Date__c,
                          TR1__Job__c,TR1__Person_Placed__c,TR1__Account__c,
                          TR1__Week_Ending__c,TR1__Timesheet_Approver__c,
                          TR1__Timesheet_Second_Approver__c,TR1__Bill_Rate__c, TR1__Pay_Rate__c,
                          TR1__Payroll_Type__c,TR1__Week_Start__c, (SELECT Id, Name, lastmodifieddate,TRSCHED__Work_Shift_Location_lkId__r.Timesheet_Approver__c,TRSCHED__WeekEndDate__c, TRSCHED__Schedule_Date__c 
                                                                    FROM TRSCHED__ClosingReportSchedules__r  WHERE TRSCHED__Schedule_Date__c >= :StartOfWeek   and TRSCHED__Schedule_Date__c <= :EndOfWeek  ) 
                          // FROM TRSCHED__ClosingReportSchedules__r ) 
                          FROM TR1__Closing_Report__c
                          WHERE Id = : crid
                          //AND RecordTypeId = : crconsultingId
                          AND TR1__Generate_Timesheet__c = true
                          AND TR1__Assignment_Ended__c = 'No'
                          AND((TR1__Start_Date__c <= : StartOfWeek AND(TR1__End_Date__c >= : StartOfWeek OR TR1__End_Date__c = null)) OR(TR1__Start_Date__c >= : StartOfWeek AND TR1__Start_Date__c <= : EndOfWeek AND(TR1__End_Date__c >= : StartOfWeek OR TR1__End_Date__c = null)))
                         ];
                    
                    for(TR1__Closing_Report__c cr: crlist ){
                        mapWIDVSCRSList = new Map<Id,list<TRSCHED__Closing_Report_Schedule__c>>();
                        for(TRSCHED__Closing_Report_Schedule__c cReportSchedule: cr.TRSCHED__ClosingReportSchedules__r){
                            if(mapWIDVSCRSList.containskey(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c)){
                                mapWIDVSCRSList.get(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c).add(cReportSchedule);
                            }else{
                                mapWIDVSCRSList.put(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c, new list<TRSCHED__Closing_Report_Schedule__c>{cReportSchedule});
                            }
                            worksiteIds.add(cReportSchedule.TRSCHED__Work_Shift_Location_lkId__c);               
                        }
                        if(mapWIDVSCRSList != null && mapWIDVSCRSList.size() > 0){
                            mapCRIdVSMapWIDVSCRSList.put(cr.Id,mapWIDVSCRSList);
                            mapCRIdVsCR.put(cr.Id,cr); 
                        }     
                    }  
                } 
                Map<Id,Account> worsiteLocations = new map<Id,Account>([select id, Name,Timesheet_Approver__c from Account
                                                                        where id in :worksiteIds]);
                list<TR1__Timesheet__c> timesheetList = [SELECT TR1__Closing_Report__c,TR1__Week_Ending__c,Work_Shift_Location__c
                                                         , (SELECT Id, Name, TR1__Date__c,TRSCHED__Closing_Report_Schedule__c,TR1__Timesheet__r.Work_Shift_Location__c FROM TR1__Timecards__r )
                                                         FROM TR1__Timesheet__c
                                                         WHERE TR1__Closing_Report__c IN :mapCRIdVsCR.keyset() 
                                                         AND (TR1__Week_Ending__c = :EndOfWeek OR TR1__Week_Ending__c = :defaultEndOfWeek)];
                
                Map<Id,Map<Id,TR1__Timesheet__c>> mapCRVSWSIdVSTimesheet = new Map<Id,Map<Id,TR1__Timesheet__c>>();
                map<Id,list<TR1__Timesheet_Detail__c>> mapCRSIdVsTimesheetDetails = new map<Id,list<TR1__Timesheet_Detail__c>>();
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
                for(Id cReportId:mapCRIdVsCR.keyset()){
                    cr  = mapCRIdVsCR.get(cReportId);
                    for(Id worksiteId:mapCRIdVSMapWIDVSCRSList.get(cReportId).keyset()){
                        
                        if(mapCRVSWSIdVSTimesheet != null && mapCRVSWSIdVSTimesheet.containskey(cReportId)
                           && mapCRVSWSIdVSTimesheet.get(cReportId).containsKey(worksiteId)){
                           }else{
                               timesheet = new TR1__Timesheet__c();
                               timesheet.TR1__Status__c='Unsubmitted';
                               timesheet.TR1__Closing_Report__c =cr.Id;
                               timesheet.TR1__Consultant__c=cr.TR1__Person_Placed__c;
                               timesheet.TR1__Job_Order__c = cr.TR1__Job__c;
                               if(worsiteLocations != null && worsiteLocations.containskey(worksiteId) && worsiteLocations.get(worksiteId).Timesheet_Approver__c != null){
                                   timesheet.TR1__Approver__c= worsiteLocations.get(worksiteId).Timesheet_Approver__c;
                               }else{
                                   timesheet.TR1__Approver__c= cr.TR1__Timesheet_Approver__c;
                               }                        
                               timesheet.TR1__Timesheet_Second_Approver__c = cr.TR1__Timesheet_Second_Approver__c;
                               timesheet.TR1__Client__c= cr.TR1__Account__c;
                               timesheet.TR1__Week_Ending__c = EndOfWeek;
                               timesheet.TR1__Pay_Week_Ending__c = EndOfWeek;  
                               timesheet.Work_Shift_Location__c = worksiteId;
                               newtimesheetList.add(timesheet); 
                           }
                    }
                }
                Database.insert(newtimesheetList,false);
                for(TR1__Timesheet__c tsheet:newtimesheetList){
                    if(mapCRVSWSIdVSTimesheet.containskey(tsheet.TR1__Closing_Report__c)){
                        mapCRVSWSIdVSTimesheet.get(tsheet.TR1__Closing_Report__c).put(tsheet.Work_Shift_Location__c,tsheet);
                    }else{
                        mapCRVSWSIdVSTimesheet.put(tsheet.TR1__Closing_Report__c, new map<Id,TR1__Timesheet__c>{tsheet.Work_Shift_Location__c =>tsheet}); 
                    }
                }
                TR1__Timesheet_Detail__c tDetail;
                list<TR1__Timesheet_Detail__c> tDetailList = new list<TR1__Timesheet_Detail__c>();
                for(Id cReportId:mapCRIdVsCR.keyset()){
                    cr  = mapCRIdVsCR.get(cReportId);
                    for(Id worksiteId:mapCRIdVSMapWIDVSCRSList.get(cReportId).keyset()){
                        for(TRSCHED__Closing_Report_Schedule__c cRSchedule:mapCRIdVSMapWIDVSCRSList.get(cReportId).get(worksiteId)){
                            if(!mapCRSIdVsTimesheetDetails.containskey(cRSchedule.Id)){
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
                                 AND (TR1__Week_Ending__c = :EndOfWeek OR TR1__Week_Ending__c = :defaultEndOfWeek)];
                for(TR1__Timesheet__c  tSh: timesheetList){
                    if(tSh.TR1__Timecards__r == null || tSh.TR1__Timecards__r.size() == 0){
                        deleteTList.add(tSh);
                    }
                }
                if(deleteTList != null && deleteTList.size() > 0){
                    Database.delete(deleteTList,false);
                }
            }
            
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            return null;
            
        }
        return new PageReference('/' + crid);
    }
    
    public PageReference goBack() {
        return new PageReference('/' + crid);
    }
    
    private date calculateStartDate(Date selectedDate) {
        return selectedDate.toStartOfWeek() + 1;
    }
    
    private date calculateEndDate(Date selectedDate) {
        return selectedDate.toStartOfWeek() + 7;
    }
}
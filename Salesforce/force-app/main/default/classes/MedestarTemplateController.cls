global without sharing class MedestarTemplateController {
    //global properties
    global String closingReportId {get; set{
        closingReportId = value;
        fetchClosingReportData();
    }}
    global TR1__Closing_Report__c crRecord {get; set;}
    global List<WorkSiteWrapper> listUniqueWorkSites{get; set;}
    global List<ClosingReportScheduleWrapper> closingReportScheduleWrapper {get; set;}
    
    //private variables
    private Set<String> uniqueWorkSiteLocations;
    
    //constructor
    public MedestarTemplateController(){
        
    }
    
    //method to fetch Closing Report data
    private void fetchClosingReportData(){
        listUniqueWorkSites = new List<WorkSiteWrapper>();
        uniqueWorkSiteLocations = new Set<String>();
        closingReportScheduleWrapper = new List<ClosingReportScheduleWrapper>();
        if(closingReportId != null){
            DateTime startDate = DateTime.Now();
            for(TR1__Closing_Report__c cr : [Select Name, Send_Confirmation_Letter_To__c,
                                            Send_Confirmation_Letter_To__r.FirstName, 
                                            Send_Confirmation_Letter_To__r.LastName,
                                            Send_Confirmation_Letter_To__r.MailingCity,
                                            Send_Confirmation_Letter_To__r.MailingState,
                                            Send_Confirmation_Letter_To__r.MailingCountry,
                                            Send_Confirmation_Letter_To__r.MailingPostalCode,
                                            Send_Confirmation_Letter_To__r.MailingStreet,
                                            TR1__Person_Placed__r.Salutation, 
                                            TR1__Person_Placed__c, TR1__Person_Placed__r.FirstName,
                                            TR1__Person_Placed__r.LastName,
                                            TR1__Person_Placed__r.MailingCity,
                                            TR1__Person_Placed__r.MailingState,
                                            TR1__Person_Placed__r.MailingCountry,
                                            TR1__Person_Placed__r.MailingPostalCode,
                                            TR1__Person_Placed__r.MailingStreet,Break_Time_Mins__c, Name_on_W_9__c, 
                                            TR1__Account__c, TR1__Account__r.Name, TR1__Account__r.ShippingState,
                                            TR1__Job__c, TR1__Job__r.Specialties__c,TR1__Job__r.TR1__Primary_Background__c,
                                            Mileage_Required__c, Rental_Car_Required__c, Mileage_Billable__c,
                                            Lodging_Billable__c, Rental_Car_Billable__c, Airfare_Billable__c,  
                                            Lodging_Required__c, Airfare_Required__c, Medestar_Daily_Admin_Fee__c,
                                            TR1__Timesheet_Approver__r.Email, 
                                            (Select Rate_Definition__c , TR1__RateBill__c , Id, TR1__TimeType__c, TR1__TimeType__r.Name, TR1__RatePay__c, Name  from TR1__Rates__r order by createdDate Desc),
                                            (Select Id, TRSCHED__Vacancy_Schedule__r.TRSCHED__Work_Shift_Location_lkId__c,
                                             TRSCHED__Vacancy_Schedule__r.TRSCHED__Work_Shift_Location_lkId__r.Name,
                                             TRSCHED__Work_Shift_Location_lkId__r.Name,
                                             TRSCHED__Work_Shift_Location_lkId__r.ShippingCity,
                                             TRSCHED__Work_Shift_Location_lkId__r.ShippingState,
                                             TRSCHED__Work_Shift_Location_lkId__r.ShippingCountry,
                                             TRSCHED__Work_Shift_Location_lkId__r.ShippingStreet,
                                             TRSCHED__Work_Shift_Location_lkId__r.ShippingPostalCode,
                                             TRSCHED__Vacancy_Schedule__r.TRSCHED__Job_s_Account__r.Name,
                                             TRSCHED__Vacancy_Schedule__r.TRSCHED__Job_s_Account__c,
                                             TRSCHED__End_DateTime_d2d__c, TRSCHED__Start_DateTime_d2d__c,
                                             TRSCHED__CSD_Start_Time__c, TRSCHED__CSD_End_Time__c, 
                                             Workshift_Location__c, Tentative_or_Confirmed__c    
                                             from TRSCHED__ClosingReportSchedules__r 
                                             where Workshift_Location__c != null 
                                              AND TRSCHED__Start_DateTime_d2d__c >=: startDate
                                              Order by TRSCHED__Start_DateTime_d2d__c) 
                                            from TR1__Closing_Report__c 
                                            where id =: closingReportId
                                            ]){
                crRecord = cr;
                for(TRSCHED__Closing_Report_Schedule__c crs : cr.TRSCHED__ClosingReportSchedules__r){
                   if(crs.TRSCHED__Vacancy_Schedule__r.TRSCHED__Work_Shift_Location_lkId__c != null){
                        uniqueWorkSiteLocations.add(crs.TRSCHED__Vacancy_Schedule__r.TRSCHED__Work_Shift_Location_lkId__c);
                    }else{
                        uniqueWorkSiteLocations.add(crs.TRSCHED__Vacancy_Schedule__r.TRSCHED__Job_s_Account__c);
                    }
                    closingReportScheduleWrapper.add(new ClosingReportScheduleWrapper(crs));
                }    
            }
            
            //fetching work site information
            if(uniqueWorkSiteLocations.size() > 0){
                for(Account acc : [Select Name, BillingCity, BillingCountry, BillingStreet, BillingState, BillingPostalCode
                                    from Account where id in : uniqueWorkSiteLocations]){
                    listUniqueWorkSites.add(new WorkSiteWrapper(acc));
                }
            }
        }
    }
    
    public static String getMonthName(Integer monthNumber){
            if(monthNumber == 1){
                return 'Jan';
            } else if(monthNumber == 2){
                return 'Feb';
            }else if(monthNumber == 3){
                return 'Mar';
            }else if(monthNumber == 4){
                return 'Apr';
            }else if(monthNumber == 5){
                return 'May';
            }else if(monthNumber == 6){
                return 'Jun';
            }else if(monthNumber == 7){
                return 'Jul';
            }else if(monthNumber == 8){
                return 'Aug';
            }else if(monthNumber == 9){
                return 'Sep';
            }else if(monthNumber == 10){
                return 'Oct';
            }else if(monthNumber == 11){
                return 'Nov';
            }else{
                return 'Dec';
            }
        }
    
    //wrapper class to hold CRS data
    global class WorkSiteWrapper{
        global Account workSiteLocation {get; set;}        
        //constructor
        global WorkSiteWrapper(Account  acc){
            workSiteLocation = acc;
        }
    }
    
    global class ClosingReportScheduleWrapper{
        global TRSCHED__Closing_Report_Schedule__c crs {get; set;}
        //global Date startDate {get; set;}
        global String formattedStartDate {get; set;}
        global String formattedEndDate {get; set;}        
        
        global ClosingReportScheduleWrapper(TRSCHED__Closing_Report_Schedule__c crs){
            this.crs = crs;
            if(crs.TRSCHED__Start_DateTime_d2d__c != null){
                String localStartDateTimeString = crs.TRSCHED__Start_DateTime_d2d__c.format();
                String localStartDateString = localStartDateTimeString.split(' ')[0];
                String localStartTimeString = localStartDateTimeString.split(' ')[1];
                String localStartAmPmString = localStartDateTimeString.split(' ')[2];
                formattedStartDate = MedestarTemplateController.getMonthName(Integer.valueOf(localStartDateString.split('/')[0])) + ' ' + localStartDateString.split('/')[1] +', ' + localStartTimeString.split(':')[0] + ':' + localStartTimeString.split(':')[1] + ' ' + localStartAmPmString;
            }
            
            if(crs.TRSCHED__End_DateTime_d2d__c != null){
                String localEndDateTimeString = crs.TRSCHED__End_DateTime_d2d__c.format();
                String localEndDateString = localEndDateTimeString.split(' ')[0];
                String localEndTimeString = localEndDateTimeString.split(' ')[1];
                String localEndAmPmString = localEndDateTimeString.split(' ')[2];
                formattedEndDate = MedestarTemplateController.getMonthName(Integer.valueOf(localEndDateString.split('/')[0])) + ' ' + localEndDateString.split('/')[1] +', ' + localEndTimeString.split(':')[0] + ':' + localEndTimeString.split(':')[1] + ' ' + localEndAmPmString;
            }
            
            //startDate = date.newinstance(localStartDate.year(), localStartDate.month(), localStartDate.day());
            //system.assert(false, formattedStartDate + '===' + formattedEndDate);
        }
    }
}
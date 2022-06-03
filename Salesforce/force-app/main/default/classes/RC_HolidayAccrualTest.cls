@isTest
private class RC_HolidayAccrualTest {

    private static testMethod void AccrualProcess() {
        
        TR1__Job__c objJob = RC_UtilityClass.insertJob();
        
        TR1__Timesheet__c  objTimesheet = RC_UtilityClass.insertTimeSheet(objJob.Id);
        Contact objContact = new Contact(Firstname = 'Test', Lastname = 'Conatct1');
        insert objContact;
        objTimesheet.TR1__Consultant__c = objContact.Id;
        update objTimesheet;
        
        TR1__Timesheet_Detail__c objTimesheetDetail = RC_UtilityClass.insertTimeSheetDetail(objTimesheet.Id);
        objTimesheetDetail.TR1__Vacation_Hours__c = 4;
        objTimesheetDetail.TR1__Regular_Hours__c = 4;
        update objTimesheetDetail;
        
        objTimesheet.TR1__Status__c = 'Approved';
        update objTimesheet;
        
        objTimesheet.TR1__Status__c = 'Unsubmitted';
        update objTimesheet;
        
        objTimesheet.TR1__Status__c = 'Approved';
        update objTimesheet;
        
        delete objTimesheetDetail;
        

    }

}
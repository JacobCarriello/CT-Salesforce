global class ClosingReportSchedulesBatch implements Database.Batchable<sObject>, Schedulable{
    //Schedulable Method
    public void execute(SchedulableContext sc) {
	      ClosingReportSchedulesBatch b = new ClosingReportSchedulesBatch(); 
	      Database.executebatch(b, 100);
   	}
   	
   	public Database.QueryLocator start(Database.BatchableContext BC) {
   		String query = 'Select Id, Next_Working_Date__c from TR1__Closing_Report__c where CRS_Count__c > 0';
		return Database.getQueryLocator(query); 
	}

   	public void execute(Database.BatchableContext BC, List<TR1__Closing_Report__c> closingReports) {
   		
   		List<TR1__Closing_Report__c> closingReportsToUpdate = new List<TR1__Closing_Report__c>();
   		//fetching the CRS
   		for(TR1__Closing_Report__c cr : [Select Id, Next_Working_Date__c, 
   										(Select Id, TRSCHED__Schedule_Date__c, TRSCHED__End_DateTime_d2d__c, TRSCHED__Start_DateTime_d2d__c 
   										From TRSCHED__ClosingReportSchedules__r where TRSCHED__Start_DateTime_d2d__c != null 
   										AND TRSCHED__Start_DateTime_d2d__c >: Date.today() 
   										AND (Tentative_or_Confirmed__c = 'Confirmed' OR Tentative_or_Confirmed__c = 'Tentative') 
   										order by TRSCHED__Start_DateTime_d2d__c limit 1) 
   										from TR1__Closing_Report__c where Id in : closingReports]){
   			if(cr.TRSCHED__ClosingReportSchedules__r.size() > 0){ 
   				if(cr.Next_Working_Date__c != cr.TRSCHED__ClosingReportSchedules__r.get(0).TRSCHED__Start_DateTime_d2d__c){
   					closingReportsToUpdate.add(new TR1__Closing_Report__c (Id = cr.id, 
   												Next_Working_Date__c = cr.TRSCHED__ClosingReportSchedules__r.get(0).TRSCHED__Start_DateTime_d2d__c.date()));
   				}
   			}else{
   				if(cr.Next_Working_Date__c != null){
   					closingReportsToUpdate.add(new TR1__Closing_Report__c (Id = cr.id, 
   												Next_Working_Date__c = null));
   				}
   			}
   		}
   		
   		update closingReportsToUpdate;
   		try {
			Database.SaveResult[] results = Database.update(closingReportsToUpdate,false);
			if (results != null){
				for (Database.SaveResult result : results) {
					if (!result.isSuccess()) {
						/*
						Database.Error[] errs = result.getErrors();
						for(Database.Error err : errs)
							System.debug(err.getStatusCode() + ' - ' + err.getMessage());
							
						*/
					}
				}
			}
		
		} catch (Exception e) {
			System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
		}
   	}
	
	public void finish(Database.BatchableContext BC) { 
	}
}
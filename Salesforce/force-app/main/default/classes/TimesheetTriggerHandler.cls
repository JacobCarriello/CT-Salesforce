public class TimesheetTriggerHandler {

	private TR1__Timesheet__c oldTimesheet;
	private TR1__Timesheet__c newTimesheet;
	private date myDate = date.today();
	private date startOfWeek = myDate.toStartofWeek();
	private date startWeekLess7 = startOfWeek - 7;

	public TimesheetTriggerHandler(TR1__Timesheet__c oldT, TR1__Timesheet__c newT) {
		this.oldTimesheet = oldT;
		this.newTimesheet = newT;
	}

	public void checkInvoiceDate() {
		try {
			if (newTimesheet.Invoice_Date__c >= startWeekLess7 && newTimesheet.Invoice_Date__c < startOfWeek && oldTimesheet.Invoice_Date__c >= startOfWeek && newTimesheet.Invoice_Date__c != oldTimesheet.Invoice_Date__c) {
				updateGoals(oldTimesheet, newTimesheet);
			}
		} catch (Exception e) {
			String emailBody = 'This is the exception message: ' + e.getMessage() + '<br/><br/>Stack trace: ' + e.getStackTraceString();
			EmailServices.sendErrorEmail(emailBody);
		}
	}

	private void updateGoals(TR1__Timesheet__c oldT, TR1__Timesheet__c newT){
		List<TR1__Gross_Profit__c> lstGP = [SELECT Id, TR1__GP_Amount__c FROM TR1__Gross_Profit__c WHERE TR1__Timesheet__c =: newT.Id];
		System.debug(lstGP);
		List<Goal__c> lstGoal = new List<Goal__c>();
		for (TR1__Gross_Profit__c gp : lstGP) {
			Goal__c goalTW = [SELECT Id, Weekly_Actual_Net_Revenue_Billed__c FROM Goal__c WHERE RecordTypeId = '0122M000001UZsoQAG' AND (Start_Date__c >=: getStartOfWeek(oldT.Invoice_Date__c) AND End_Date__c <:  getEndOfWeek(oldT.Invoice_Date__c) AND User__c =: gp.TR1__Recruiter_Name__c AND Group__c =: gp.Group_Region__c AND (Team__c = 'Carolyn Magilley' OR Team__c = 'Laura Shirley') AND Goal_Status__c = 'Active')];
			Goal__c goalLW = [SELECT Id, Weekly_Actual_Net_Revenue_Billed__c FROM Goal__c WHERE RecordTypeId = '0122M000001UZsoQAG' AND (Start_Date__c >=: getStartOfWeek(newT.Invoice_Date__c) AND End_Date__c <:  getEndOfWeek(newT.Invoice_Date__c) AND User__c =: gp.TR1__Recruiter_Name__c AND Group__c =: gp.Group_Region__c AND (Team__c = 'Carolyn Magilley' OR Team__c = 'Laura Shirley') AND Goal_Status__c = 'Active')];
			System.debug(goalTW);
			System.debug(goalLW);
		}
	}

	private date getStartOfWeek(date myDate){
		return myDate.toStartofWeek();
	}

	private date getEndOfWeek(date myDate){
		return myDate.toStartofWeek() + 7;
	}
}
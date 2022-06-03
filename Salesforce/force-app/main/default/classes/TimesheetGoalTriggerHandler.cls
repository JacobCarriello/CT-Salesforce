public class TimesheetGoalTriggerHandler {
	public void updateGoalsAccordingToInvoiceDates(Map<Id, TR1__Timesheet__c> oldTsMap, Map<Id, TR1__Timesheet__c> newTsMap) {
		date myDate = date.today();
		date startOfWeek = myDate.toStartofWeek() + 1;
		date startWeekLess7 = startOfWeek - 7;
		try {
			Map<Id, TR1__Timesheet__c> tsMap = new Map<Id, TR1__Timesheet__c>();
			for (Id id : oldTsMap.keySet()) {
				TR1__Timesheet__c oldTimesheet = oldTsMap.get(id);
				TR1__Timesheet__c newTimesheet = newTsMap.get(id);
				if (newTimesheet.Invoice_Date__c >= startWeekLess7 && newTimesheet.Invoice_Date__c < startOfWeek && oldTimesheet.Invoice_Date__c >= startOfWeek && newTimesheet.Invoice_Date__c != oldTimesheet.Invoice_Date__c) {
					tsMap.put(id, newTimesheet);
				}
			}
			if (!tsMap.isEmpty()) {
				updateGoals(tsMap);
			}
		} catch (Exception e) {
			String emailBody = 'This is the exception message: ' + e.getMessage() + '<br/><br/>Stack trace: ' + e.getStackTraceString();
			EmailServices.sendErrorEmail(emailBody);
		}
	}

	private void updateGoals(Map<Id, TR1__Timesheet__c> timesheetsMap){
		System.debug(timesheetsMap.keySet());
		List<TR1__Gross_Profit__c> lstGP = [SELECT Id, TR1__GP_Amount__c, TR1__Recruiter_Name__c, Group_Region__c FROM TR1__Gross_Profit__c WHERE TR1__Timesheet__c IN :timesheetsMap.keySet()];

		List<Id> recNames = new List<Id>();
		List<String> groupRegs = new List<String>();
		for (TR1__Gross_Profit__c gp : lstGP) {
			System.debug(gp);
			if (recNames.contains(gp.TR1__Recruiter_Name__c) == false) {
				recNames.add(gp.TR1__Recruiter_Name__c);
			}
			if (groupRegs.contains(gp.Group_Region__c) == false) {
				groupRegs.add(gp.Group_Region__c);
			}
		}
		System.debug(recNames);
		System.debug(groupRegs);

		List<Goal__c> goalsTW = [SELECT Id, Weekly_Actual_Net_Revenue_Billed__c, User__c, Group__c FROM Goal__c WHERE RecordType.Name = 'Recruiter' AND (Start_Date__c >=: getStartOfWeek('this') AND End_Date__c <=:  getEndOfWeek('this') AND User__c IN: recNames AND Group__c IN: groupRegs AND (Team__c = 'Carolyn Magilley' OR Team__c = 'Laura Shirley') AND Goal_Status__c = 'Active')];
		List<Goal__c> goalsLW = [SELECT Id, Weekly_Actual_Net_Revenue_Billed__c, User__c, Group__c FROM Goal__c WHERE RecordType.Name = 'Recruiter' AND (Start_Date__c >=: getStartOfWeek('last') AND End_Date__c <=:  getEndOfWeek('last') AND User__c IN: recNames AND Group__c IN: groupRegs AND (Team__c = 'Carolyn Magilley' OR Team__c = 'Laura Shirley') AND Goal_Status__c = 'Active')];

		System.debug(goalsTW);
		System.debug(goalsLW);
		List<Goal__c> goalsToUpdate = new List<Goal__c>();
		for (TR1__Gross_Profit__c gp : lstGP) {
			Goal__c goalTW = null;
			Goal__c goalLW = null;
			for (Goal__c tempGoal: goalsTW) {
				if (tempGoal.User__c == gp.TR1__Recruiter_Name__c && tempGoal.Group__c == gp.Group_Region__c) {
					goalTW = tempGoal;
					break;
				}
			}
			for (Goal__c tempGoal: goalsLW) {
				if (tempGoal.User__c == gp.TR1__Recruiter_Name__c && tempGoal.Group__c == gp.Group_Region__c) {
					goalLW = tempGoal;
					break;
				}
			}

			if (goalTW != null && goalLW != null) {
				goalTW.Weekly_Actual_Net_Revenue_Billed__c = goalTW.Weekly_Actual_Net_Revenue_Billed__c - gp.TR1__GP_Amount__c;
				goalLW.Weekly_Actual_Net_Revenue_Billed__c = goalLW.Weekly_Actual_Net_Revenue_Billed__c + gp.TR1__GP_Amount__c;
				if (!goalsToUpdate.contains(goalTW)) {
					goalsToUpdate.add(goalTW);
				}
				if (!goalsToUpdate.contains(goalLW)) {
					goalsToUpdate.add(goalLW);
				}
			}
		}
		System.debug(goalsToUpdate);
		update goalsToUpdate;
	}

	private date getStartOfWeek(String week){
		date myDate = date.today();

		date startWeek = null;
		if (week == 'this') {
			startWeek = myDate.toStartofWeek() + 1;
		} else if (week == 'last'){
			startWeek = (myDate.toStartofWeek() + 1) - 7;
		}
		return startWeek;
	}

	private date getEndOfWeek(String week){
		date myDate = date.today();

		date endWeek = null;
		if (week == 'this') {
			endWeek = myDate.toStartofWeek() + 8;
		} else if (week == 'last') {
			endWeek = myDate.toStartofWeek() + 1;
		}
		return endWeek;
	}
}
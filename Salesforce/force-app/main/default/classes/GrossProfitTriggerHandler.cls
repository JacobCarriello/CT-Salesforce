public class GrossProfitTriggerHandler {

	private List<TR1__Gross_Profit__c> originalGrossProfits;

	public GrossProfitTriggerHandler(List<TR1__Gross_Profit__c> grossProfits) {
		this.originalGrossProfits = grossProfits;
	}

	public void deleteDuplicates() {
		try {
			if (originalGrossProfits != null && !originalGrossProfits.isEmpty()) {
				List<TR1__Gross_Profit__c> oGP = checkGrossProfitFromTrigger(originalGrossProfits);
				checkGrossProfitFromQuery(oGP);
			}
		} catch (Exception e) {
			String emailBody = 'This is the exception message: ' + e.getMessage() + '<br/><br/>Stack trace: ' + e.getStackTraceString();
			EmailServices.sendErrorEmail(emailBody);
		}
	}

	private List<TR1__Gross_Profit__c> checkGrossProfitFromTrigger(List<TR1__Gross_Profit__c> grossProfitsTrigger) {
		List<TR1__Gross_Profit__c> lstGrossProfit = new List<TR1__Gross_Profit__c>();
		List<TR1__Gross_Profit__c> lstDuplicateGrossProfit = new List<TR1__Gross_Profit__c>();
		List<Id> insertIDGP = new List<Id>();

		for (TR1__Gross_Profit__c gpF : grossProfitsTrigger) {
			for (TR1__Gross_Profit__c gpS : grossProfitsTrigger) {
				if (gpF.Id == gpS.Id) {
					if(lstDuplicateGrossProfit.indexOf(gpF) == -1 && lstGrossProfit.indexOf(gpF) == -1){
						lstGrossProfit.add(gpF);
					}
				} else if (gpF.Id != gpS.Id && gpF.TR1__Credit_Type__c == gpS.TR1__Credit_Type__c && gpF.TR1__Closing_Report__c == gpS.TR1__Closing_Report__c && gpF.TR1__Timesheet__c == gpS.TR1__Timesheet__c) {
					if(lstGrossProfit.indexOf(gpF) == -1 && lstDuplicateGrossProfit.indexOf(gpF) == -1){
						lstDuplicateGrossProfit.add(gpF);
						insertIDGP.add(gpF.Id);
					}
				}
			}
		}
		System.debug(lstDuplicateGrossProfit);
		System.debug(lstGrossProfit);

		Database.delete(insertIDGP);
		return lstGrossProfit;
	}

	private void checkGrossProfitFromQuery(List<TR1__Gross_Profit__c> grossProfits) {
		List<TR1__Gross_Profit__c> lstDuplicateGrossProfit = new List<TR1__Gross_Profit__c>();

		for (TR1__Gross_Profit__c oGP : grossProfits) {
			List<TR1__Gross_Profit__c> lstGrossProfit = [SELECT Id, TR1__Credit_Type__c, TR1__GP_Amount__c, TR1__Closing_Report__c, TR1__Timesheet__c FROM TR1__Gross_Profit__c WHERE TR1__Closing_Report__c = :oGP.TR1__Closing_Report__c AND (TR1__GP_Amount__c = :oGP.TR1__GP_Amount__c AND TR1__Credit_Type__c =:oGP.TR1__Credit_Type__c AND TR1__Timesheet__c =:oGP.TR1__Timesheet__c)];
			for (TR1__Gross_Profit__c qGP : lstGrossProfit) {
				if (oGP.Id != qGP.Id && oGP.TR1__Credit_Type__c == qGP.TR1__Credit_Type__c && oGP.TR1__Closing_Report__c == qGP.TR1__Closing_Report__c && oGP.TR1__Timesheet__c == qGP.TR1__Timesheet__c) {
					if(lstDuplicateGrossProfit.indexOf(qGP) == -1){
						lstDuplicateGrossProfit.add(qGP);
					}
				}
			}
		}
		System.debug(lstDuplicateGrossProfit);
		delete lstDuplicateGrossProfit;
	}
}
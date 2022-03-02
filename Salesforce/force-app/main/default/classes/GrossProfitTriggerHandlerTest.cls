@isTest
public class GrossProfitTriggerHandlerTest {

	@isTest
	static void triggerGPTest(){
		List<TR1__Gross_Profit__c> gps = new List<TR1__Gross_Profit__c>();

		gps.add(new TR1__Gross_Profit__c(
			TR1__Credit_Type__c='Job Credit',
			TR1__GP_Amount__c=192,
			TR1__Closing_Report__c='a092M00001HVpCTQA1'
		));

		gps.add(new TR1__Gross_Profit__c(
			TR1__Credit_Type__c='Job Credit',
			TR1__GP_Amount__c=192,
			TR1__Closing_Report__c='a092M00001HVpCTQA1'
		));

		gps.add(new TR1__Gross_Profit__c(
			TR1__Credit_Type__c='Job Credit',
			TR1__GP_Amount__c=192,
			TR1__Closing_Report__c='a092M00001HVpCTQA1'
		));
		insert gps;
	}
}
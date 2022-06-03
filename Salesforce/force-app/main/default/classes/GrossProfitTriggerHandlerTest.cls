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

	@isTest
	static void triggerGPCLassTest(){
		List<TR1__Gross_Profit__c> gps = new List<TR1__Gross_Profit__c>();

		gps.add(new TR1__Gross_Profit__c(
			TR1__Credit_Type__c='Job Credit',
			TR1__GP_Amount__c=192,
			TR1__Closing_Report__c='a092M00001HVpCTQA1',
			TR1__Timesheet__c='a0y2M00000BFYKCQA5',
			RecordTypeId='01241000000kGvuAAE'
		));

		gps.add(new TR1__Gross_Profit__c(
			TR1__Credit_Type__c='Job Credit',
			TR1__GP_Amount__c=192,
			TR1__Closing_Report__c='a092M00001HVpCTQA1',
			TR1__Timesheet__c='a0y2M00000BFYKCQA5',
			RecordTypeId='01241000000kGvuAAE'
		));

		gps.add(new TR1__Gross_Profit__c(
			TR1__Credit_Type__c='Job Credit',
			TR1__GP_Amount__c=192,
			TR1__Closing_Report__c='a092M00001HVpCTQA1',
			TR1__Timesheet__c='a0y2M00000BFYKCQA5',
			RecordTypeId='01241000000kGvuAAE'
		));
		insert gps;

		Test.startTest();
			GrossProfitTriggerHandler grossDuplicateTrigger = new GrossProfitTriggerHandler(gps);
			grossDuplicateTrigger.deleteDuplicates();
		Test.stopTest();
	}
}
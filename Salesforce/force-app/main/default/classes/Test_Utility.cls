@isTest(SeeAllData = false)
public with sharing class Test_Utility {

	static testmethod void test_method_one() {
		
		List<String> strList = new List<String>();
		strList.add('Test');
		strList.add('Test1');
		
		Account acc = new Account(Name = 'Test');
		
		//Start Test
		Test.startTest();
		
		Utility.addTableRow('Test', 0.5);
		Utility.addTableRow('Test', 'Test');
		
		Utility.addTableRow('Test value' , System.today());
		
		Utility.DateFormat(System.today());
		
		Utility.AddInfoMessage('Test value');
		Utility.AddWarningMessage('Test value');
		Utility.AddConfirmMessage('Test value');
		Utility.AddErrorMessage('Test value');
		Utility.AddFatalMessage('Test value');
		
		Utility.listToFormattedMultiPicklistString(strList);
		Utility.listToFormattedMultiPicklistStringSemi(strList);
		
		Utility.addTableRow('Test', acc);		
        for(Integer i=0;i<=12;i++){
            Utility.getDay(i);
            Utility.getFullDay(i);
            Utility.getMonth(i);
        }
        Utility.formatDate(Date.today());
        Utility.formatedDate(Date.today().format());
        Utility.getPageParameter('param');
        System.debug('===>>'+Utility.hasMessage('pageMessage'));
        System.debug('======>>>'+Utility.currentUserProfileName);
        System.debug('====>>>'+Utility.isEducationProfile());
        System.debug('===>>'+Utility.isInternalUser());
        System.debug('==>'+Utility.CONSULTING);
		//Stop Test
		Test.stopTest();
		
	}
}
@isTest
private class RC_CandidateExpenseReportDetailTest
{
    private static testMethod void test() 
    {
        RecordType objRecordType = [SELECT DeveloperName, Id FROM RecordType WHERE SobjectType = 'TR1__Expense_Report_Detail__c' and DeveloperName ='Mileage' ];
        System.debug('objRecordType ' + objRecordType);
        Integer indexZero = 0;
        Integer indexOne = 1;
        
        Account testAcc = new Account(name='Test');  
        insert testAcc; 
        
        User communityUser  = RC_UtilityClass.returnCommunityContactTypeUser('client');
        
        TR1__Closing_Report__c objCloseRep = new TR1__Closing_Report__c();
        objCloseRep.TR1__Account__c = testAcc.id;
        objCloseRep.TR1__Job_Percentage__c = 20;
        objCloseRep.TR1__Candidate_Percentage__c  = 20;
        objCloseRep.TR1__Marketing_Percentage__c  = 20;
        objCloseRep.TR1__Other_Percentage__c  = 20;
        objCloseRep.TR1__Other2_Percentage__c = 20;
        objCloseRep.TR1__Job__c = RC_UtilityClass.insertJob().id; 
        objCloseRep.TR1__Person_Placed__c = communityUser.contactId;
        insert objCloseRep;

        System.runAs(communityUser)
        {
            
            
            Apexpages.currentPage().getParameters().put('NewExp', 'true');   
            Apexpages.currentPage().getParameters().put('isSubmitted', 'false');    
            RC_CandidateExpenseReportDetail objExpenseDetail = new RC_CandidateExpenseReportDetail();       
            objExpenseDetail.redirectUnAuthenticatedUser();
      	    list<SelectOption> lstSelect = objExpenseDetail.getClosingReports(); 
            system.assertNotEquals(null, lstSelect);
            objExpenseDetail.objExpRep = new TR1__Expense_Report__c();
            objExpenseDetail.objExpRep.TR1__Expense_Period_Start__c = date.today();
            objExpenseDetail.objExpRep.TR1__Expense_Period_End__c = date.today() + 7;
            objExpenseDetail.objExpRep.TR1__Comments__c = 'test';
            objExpenseDetail.objExpRep.TR1__Closing_Report__c = objCloseRep.Id;
            objExpenseDetail.strClosingReport = objCloseRep.Id;
            objExpenseDetail.objExpRep.TR1__Consultant__c = communityUser.contactId;
            
            //creating line item
            System.debug('objExpenseDetail.lstExpenseDetailItems ' + objExpenseDetail.lstExpenseDetailItems);
            objExpenseDetail.lstExpenseDetailItems[indexZero].TR1__Date__c = date.today()+1;
            objExpenseDetail.lstExpenseDetailItems[indexZero].TR1__Comments__c = 'TestComment 1';
            objExpenseDetail.lstExpenseDetailItems[indexZero].TR1__Amount__c = 100;
            objExpenseDetail.lstExpenseDetailItems[indexZero].TR1__Lodging_Amnt__c = 300;
            
            objExpenseDetail.addLineItem();
            
            //creating line item
            objExpenseDetail.lstExpenseDetailItems[indexOne].TR1__Date__c = date.today()+2;
            objExpenseDetail.lstExpenseDetailItems[indexOne].TR1__Comments__c = 'TestComment 2';
            objExpenseDetail.lstExpenseDetailItems[indexOne].TR1__Amount__c = 200;
            objExpenseDetail.lstExpenseDetailItems[indexOne].TR1__Lodging_Amnt__c = 400;
           
            objExpenseDetail.saveExpenseReport();
            Apexpages.currentPage().getParameters().put('NewExp', '');
            Apexpages.currentPage().getParameters().put('ExpRep', objExpenseDetail.objExpRep.Id); 
            System.debug('objExpenseDetail.objExpRep.Id ' + objExpenseDetail.objExpRep.Id);
            Apexpages.currentPage().getParameters().put('isSubmitted', 'false');

            system.assertEquals('false', ApexPages.currentPage().getParameters().get('isSubmitted'));
            system.assertEquals(objExpenseDetail.objExpRep.Id, ApexPages.currentPage().getParameters().get('ExpRep'));
            objExpenseDetail.enableEditMode();
            
            // delete
            Apexpages.currentPage().getParameters().put('index', '0');
            System.assertEquals(2, objExpenseDetail.lstExpenseDetailItems.size());
            objExpenseDetail.deleteLineItem();
			System.assertEquals(1, objExpenseDetail.lstExpenseDetailItems.size());
            
            // update
            objExpenseDetail.objExpRep.TR1__Comments__c = 'Updated comment';          
            objExpenseDetail.updateExpenseReport();
            System.assertEquals('Updated comment', objExpenseDetail.objExpRep.TR1__Comments__c);

			// show on Picklist 
            Apexpages.currentPage().getParameters().put('NewExp', '');
            Apexpages.currentPage().getParameters().put('ExpRep', objExpenseDetail.objExpRep.Id);   
          
            RC_CandidateExpenseReportDetail objExpenseDetail2 = new RC_CandidateExpenseReportDetail(); 
            
            //delete Expense Report
            
            Apexpages.currentPage().getParameters().put('NewExp', 'true');
            Apexpages.currentPage().getParameters().put('ExpRep', objExpenseDetail.objExpRep.Id);    
            Apexpages.currentPage().getParameters().put('isSubmitted', 'true');

            RC_CandidateExpenseReportDetail objExpenseDetailTest = new RC_CandidateExpenseReportDetail();       
           
            objExpenseDetailTest.objExpRep = new TR1__Expense_Report__c();
            objExpenseDetailTest.objExpRep.TR1__Expense_Period_Start__c = date.today();
            objExpenseDetailTest.objExpRep.TR1__Expense_Period_End__c = date.today() + 7;
            objExpenseDetailTest.objExpRep.TR1__Comments__c = 'test';
            objExpenseDetailTest.objExpRep.TR1__Closing_Report__c = objCloseRep.Id;
            objExpenseDetailTest.strClosingReport = objCloseRep.Id;
            
            objExpenseDetailTest.lstExpenseDetailItems[indexZero].TR1__Date__c = date.today()+1;
            objExpenseDetailTest.lstExpenseDetailItems[indexZero].TR1__Comments__c = 'TestComment';
            objExpenseDetailTest.lstExpenseDetailItems[indexZero].TR1__Amount__c = 100;
            objExpenseDetailTest.lstExpenseDetailItems[indexZero].TR1__Lodging_Amnt__c = 300;
            
            objExpenseDetailTest.saveExpenseReport();
            
            System.debug('objExpenseDetailTest.objExpRep.Id ' + objExpenseDetailTest.objExpRep.Id);
            Apexpages.currentPage().getParameters().put('NewExp', '');
            Apexpages.currentPage().getParameters().put('ExpRep', objExpenseDetailTest.objExpRep.Id);
            
            Integer countOfExpRepAfterDel = [Select count() From TR1__Expense_Report__c];
            objExpenseDetailTest.deleteExpenseReports();
            Integer countOfExpRepBeforeDel = [Select count() From TR1__Expense_Report__c];
            System.assertNotEquals(countOfExpRepAfterDel, countOfExpRepBeforeDel);
        }    
    }
}
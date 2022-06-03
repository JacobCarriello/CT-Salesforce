@isTest
public class NG_TrgHndlr_FyreSyncReq_Test 
{
    @testSetup 
    static void setupData() 
    {    
    }
/*    
    @isTest
    static void test_JobCreation()
    {
    	NG_TrgHndlr_FyreSyncReq processJobs1 = new NG_TrgHndlr_FyreSyncReq();
    	Map<Id,Account> accts = new Map<Id, Account>([SELECT Id, ParentId, Name FROM Account WHERE Name in ('ChildAcct1','ChildAcct12','ChildAcct2')]);
    	Id ParentAccountId;
    	Id WorkAccountId; 
    	for(Account a : accts.values()) { if(a.Name == 'ChildAcct2') { ParentAccountId=a.ParentId; WorkAccountId=a.Id;}}
    	List<TR1__Job__c> tempJobs = [	SELECT Id, TR1__Account__c, FyreSyncReq__c, TR1__Division__c, TR1__Primary_Background__c, Specialties__c, TR1__State_Area__c 
										FROM TR1__Job__c 
										WHERE TRSCHED__Work_Shift_Location_lkId__c in: accts.keySet() 
										ORDER BY TR1__Account__c, TR1__Division__c, TR1__Primary_Background__c, LastModifiedDate ASC];
	    System.assertequals(tempJobs.size(),4);
	    TR1__Job__c job;
	    for(TR1__Job__c j:tempJobs) if(j.TR1__Account__c == ParentAccountId) { System.debug('--------------Found the Job'); job=j; }
	    
	    TRSCHED__Vacancy_D2D__c vac1 = new TRSCHED__Vacancy_D2D__c (TRSCHED__Vacancy__c=job.Id,TRSCHED__Job_s_Account__c=ParentAccountId, TRSCHED__Work_Shift_Location_lkId__c= WorkAccountId, TRSCHED__Start_Date_Time__c=DateTime.newInstance(2019,01,01) , TRSCHED__End_Date_Time__c=DateTime.newInstance(2019,01,01), TRSCHED__Status__c='Open', Fyre_Sync_Req__c=null, TRSCHED__Vacancy_Date__c=Date.newInstance(2019,01,01)); insert vac1;
	    
	    NG_TrgHndlr_FyreSyncReq processJobs2 = new NG_TrgHndlr_FyreSyncReq();
    }
*/   
 
    @isTest
    static void test_VacancyCreation_TR()
    {
	
        Account parent1 = new Account(Name='Parent1');insert parent1;
        Account parent2 = new Account(Name='Parent2');insert parent2;
    	Account selfAccount = new Account (Name ='Self');insert selfAccount;
    	NGCSH__C ngcs = new NGCSH__C(SetupOwnerId=UserInfo.getOrganizationId(),SelfAccountId__c=selfAccount.Id,FyreIntegrationInTestMode__c=FALSE); insert ngcs;
        Account childAcct1 = new Account(Name='ChildAcct1', ParentId=parent1.Id, VMS_Job_Account_Mapping__c=parent1.Id); insert childAcct1;
        Account childAcct12 = new Account(Name='ChildAcct12', ParentId=parent1.Id, VMS_Job_Account_Mapping__c=parent1.Id); insert childAcct12;
        Account childAcct2 = new Account(Name='ChildAcct2', ParentId=parent2.Id, VMS_Job_Account_Mapping__c=parent2.Id); insert childAcct2;
        Account childAcct22 = new Account(Name='ChildAcct22', ParentId=parent2.Id, VMS_Job_Account_Mapping__c=parent2.Id); insert childAcct22;
    	Id ParentAccountId = parent2.Id;
    	Id WorkAccountId = childAcct2.Id; 
		Id jobRecordTypeId = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Medestar Locums').getRecordTypeId();        
      	TR1__Job__c jobold = new TR1__Job__c(TR1__Account__c=parent2.Id, TR1__Division__c='Nurse Practitioner',TR1__Primary_Background__c='Patient Care Services', Name='TestJob21',RecordTypeId=jobRecordTypeId,TR1__State_Area__c='Florida',TRSCHED__Work_Shift_Location_lkId__c=childAcct2.Id,TR1__Work_Shift_Location_lkId__c=childAcct2.Id); insert jobold;
		//Existing OLD RECORD Vacancy NO FREQ Reference	    
	    TRSCHED__Vacancy_D2D__c vac1 = new TRSCHED__Vacancy_D2D__c (TRSCHED__Vacancy__c=jobold.Id,TRSCHED__Job_s_Account__c=ParentAccountId, TRSCHED__Work_Shift_Location_lkId__c= WorkAccountId, TRSCHED__Start_Date_Time__c=DateTime.newInstance(2019,01,01) , TRSCHED__End_Date_Time__c=DateTime.newInstance(2019,01,01), TRSCHED__Status__c='Open', Fyre_Sync_Req__c=null, TRSCHED__Vacancy_Date__c=Date.newInstance(2019,01,01)); insert vac1;
    	
		Test.startTest();
        //First Job Create
        FyreSync__Requisition__c fReq1 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq1',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='FL', Name='fReq1', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,01)); insert fReq1;
		//NO job creation as everything is same.
        FyreSync__Requisition__c fReq12 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq12',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='FL', Name='fReq12', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,02)); insert fReq12;
        //This will create job since different state
        FyreSync__Requisition__c fReq13 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq13',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='CA', Name='fReq13', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,01)); insert fReq13;
        //This will create job since different spec.
        FyreSync__Requisition__c fReq14 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq14',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq14', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,01)); insert fReq14;
        //NO job even though different account but same parent and specs.
        FyreSync__Requisition__c fReq15 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq15',FyreSync__Account__c=childAcct12.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq15', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,02)); insert fReq15;
        
        //This will not create a job because it will pick jobold from above.
        FyreSync__Requisition__c fReq2=  new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq2',FyreSync__Account__c=childAcct2.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq2', FyreSync__Status__c='active', FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,01,01)); insert fReq2;
		
    	
//    	NG_TrgHndlr_FyreSyncReq_Generic processJobs1 = new NG_TrgHndlr_FyreSyncReq_Generic();
    	Map<Id,Account> accts = new Map<Id, Account>([SELECT Id, ParentId, VMS_Job_Account_Mapping__c, Name FROM Account WHERE Name in ('ChildAcct1','ChildAcct12','ChildAcct2')]);
    	//for(Account a : accts.values()) { if(a.Name == 'ChildAcct2') { ParentAccountId=a.VMS_Job_Account_Mapping__c; WorkAccountId=a.Id;}}
    	/*List<TR1__Job__c> tempJobs = [	SELECT Id, TR1__Account__c, FyreSyncReq__c, TR1__Division__c, TR1__Primary_Background__c, Specialties__c, TR1__State_Area__c 
										FROM TR1__Job__c 
										WHERE TRSCHED__Work_Shift_Location_lkId__c in: accts.keySet() 
										ORDER BY TR1__Account__c, TR1__Division__c, TR1__Primary_Background__c, LastModifiedDate ASC];
*/
	    //System.assertequals(4, tempJobs.size()); //# Jobs should stay the same.
	    //TR1__Job__c job;
	    //for(TR1__Job__c j:tempJobs) if(j.TR1__Account__c == ParentAccountId) { System.debug('--------------Found the Job'); job=j; }
//		TR1__Job__c jobold = new TR1__Job__c(TR1__Account__c=parent2.Id, TR1__Division__c='Nurse Practitioner',TR1__Primary_Background__c='Patient Care Services',TR1__State_Area__c='FL');

        //New FReq with existing start date as per old record above (This should not create Vacancy record)
        FyreSync__Requisition__c fReq21= new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq21',FyreSync__Account__c=WorkAccountId,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq21', FyreSync__Status__c='cancelled', FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,01,01)); insert fReq21;
        //New FReq with new start date, this should create vacancy record
        FyreSync__Requisition__c fReq22= new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq22',FyreSync__Account__c=WorkAccountId,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq22', FyreSync__Status__c='active', FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,01,02)); insert fReq22;
	    Test.stopTest();
//	    NG_TrgHndlr_FyreSyncReq_Generic processJobs2 = new NG_TrgHndlr_FyreSyncReq_Generic();
		List<TRSCHED__Vacancy_D2D__c> tempVacs = [ 	SELECT   Id, TRSCHED__Vacancy__c, TRSCHED__Job_s_Account__c, TRSCHED__Work_Shift_Location_lkId__c, TRSCHED__Start_Date_Time__c, TRSCHED__End_Date_Time__c, TRSCHED__Status__c, Fyre_Sync_Req__c, TRSCHED__Vacancy_Date__c
													FROM TRSCHED__Vacancy_D2D__c ];
													//WHERE TRSCHED__Vacancy__c =: jobold.Id ];
		System.debug(tempVacs);	    
 		System.assertequals(7, tempVacs.size()); //1 Manually non Fyre inserted Vac, 1 fReq2 which gets updated with fReq21, 1 last fReq22  .. so total 3. Thus we left the already existing record as is
    	List<TR1__Job__c> tempJobs = [	SELECT Id, TR1__Account__c, FyreSyncReq__c, TR1__Division__c, TR1__Primary_Background__c, Specialties__c, TR1__State_Area__c 
										FROM TR1__Job__c 
										WHERE TRSCHED__Work_Shift_Location_lkId__c in: accts.keySet() 
										ORDER BY TR1__Account__c, TR1__Division__c, TR1__Primary_Background__c, LastModifiedDate ASC];
	    System.assertequals(4, tempJobs.size()); //# Jobs should stay the same.
    	
    }
    
    @isTest
    static void test_VacancyCreation_NG()
    {
    	Account selfAccount = new Account (Name ='Self');insert selfAccount;
    	NGCSH__C ngcs = new NGCSH__C(SetupOwnerId=UserInfo.getOrganizationId(),SelfAccountId__c=selfAccount.Id,FyreIntegrationInTestMode__c=TRUE); insert ngcs;
        Account parent1 = new Account(Name='Parent1');insert parent1;
        Account parent2 = new Account(Name='Parent2');insert parent2;
        Account childAcct1 = new Account(Name='ChildAcct1', ParentId=parent1.Id, VMS_Job_Account_Mapping__c=parent1.Id); insert childAcct1;
        Account childAcct12 = new Account(Name='ChildAcct12', ParentId=parent1.Id, VMS_Job_Account_Mapping__c=parent1.Id); insert childAcct12;
        Account childAcct2 = new Account(Name='ChildAcct2', ParentId=parent2.Id, VMS_Job_Account_Mapping__c=parent2.Id); insert childAcct2;
        Account childAcct22 = new Account(Name='ChildAcct22', ParentId=parent2.Id, VMS_Job_Account_Mapping__c=parent2.Id); insert childAcct22;
        Account childAcct3 = new Account(Name='ChildAcct3', ParentId=parent2.Id, VMS_Job_Account_Mapping__c=selfAccount.Id); insert childAcct3;
    	Id ParentAccountId = parent2.Id;
    	Id WorkAccountId = childAcct2.Id; 
      	FyreTestJobs__c jobold = new FyreTestJobs__c(NG_Account__c=parent2.Id, NG_Division__c='Nurse Practitioner',NG_Primary_Background__c='Patient Care Services', Name='TestJob21',NG_State_Area__c='Florida',NG_Work_Shift_Location_lkId__c=childAcct2.Id); insert jobold;
	    FyreTestVac__c vac1 = new FyreTestVac__c (FyreTestJob__c=jobold.Id,NG_Job_s_Account__c=ParentAccountId, NG_Work_Shift_Location_lkId__c= WorkAccountId, NG_Start_Date_Time__c=DateTime.newInstance(2019,01,01) , NG_End_Date_Time__c=DateTime.newInstance(2019,01,01), NG_Status__c='Open', Fyre_Sync_Req__c=null, NG_Vacancy_Date__c=Date.newInstance(2019,01,01)); insert vac1;
     	
		Test.startTest();
        //First Job Create
        FyreSync__Requisition__c fReq1 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq1',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='FL', Name='fReq1', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,01), FyreSync__ReqDetails_EndTime__c='13:30:00',  FyreSync__ReqDetails_StartTime__c='03:30:00'); insert fReq1;
		//NO job creation as everything is same.
        FyreSync__Requisition__c fReq12 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq12',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='FL', Name='fReq12', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,02)); insert fReq12;
        //This will create job since different state
        FyreSync__Requisition__c fReq13 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq13',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='CA', Name='fReq13', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,01)); insert fReq13;
        //This will create job since different spec.
        FyreSync__Requisition__c fReq14 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq14',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq14', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,01)); insert fReq14;
        //NO job even though different account but same parent and specs.
        FyreSync__Requisition__c fReq15 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq15',FyreSync__Account__c=childAcct12.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq15', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,02)); insert fReq15;
        
        //This will create a job on new parent.
        FyreSync__Requisition__c fReq2=  new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq2',FyreSync__Account__c=childAcct2.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq2', FyreSync__Status__c='active', FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,01,01)); insert fReq2;

        FyreSync__Requisition__c fReq3=  new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq3',FyreSync__Account__c=childAcct3.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq2', FyreSync__Status__c='active', FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,01,01)); insert fReq3;
		
    	Map<Id,Account> accts = new Map<Id, Account>([SELECT Id, ParentId, VMS_Job_Account_Mapping__c, Name FROM Account WHERE Name in ('ChildAcct1','ChildAcct12','ChildAcct2')]);

		//Existing OLD RECORD Vacancy NO fReq Reference	    
	    //FyreTestVac__c vac1 = new FyreTestVac__c (FyreTestJob__c=jobold.Id,NG_Job_s_Account__c=ParentAccountId, NG_Work_Shift_Location_lkId__c= WorkAccountId, NG_Start_Date_Time__c=DateTime.newInstance(2019,01,01) , NG_End_Date_Time__c=DateTime.newInstance(2019,01,01), NG_Status__c='Open', Fyre_Sync_Req__c=null, NG_Vacancy_Date__c=Date.newInstance(2019,01,01)); insert vac1;
        //New FReq with existing start date as per old record above (This should not create Vacancy record)
        FyreSync__Requisition__c fReq21= new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq21',FyreSync__Account__c=WorkAccountId,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq21', FyreSync__Status__c='cancelled', FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,01,01)); insert fReq21;
        //New FReq with new start date, this should create vacancy record
        FyreSync__Requisition__c fReq22= new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq22',FyreSync__Account__c=WorkAccountId,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Patient Care Services', FyreSync__ReqDetails_State__c='FL', Name='fReq22', FyreSync__Status__c='active', FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,01,02)); insert fReq22;
		Test.stopTest();
 
    	List<FyreTestJobs__c> tempJobs = [	SELECT Id, NG_Account__c, FyreSyncReq__c, NG_Division__c, NG_Primary_Background__c, NG_State_Area__c 
										FROM FyreTestJobs__c 
										WHERE NG_Work_Shift_Location_lkId__c in: accts.keySet() 
										ORDER BY NG_Account__c, NG_Division__c, NG_Primary_Background__c, LastModifiedDate ASC];
	    System.assertequals(4,tempJobs.size()); //# Jobs should stay the same.
 	    
		List<FyreTestVac__c> tempVacs = [ 	SELECT   Id, FyreTestJob__c, NG_Job_s_Account__c, NG_Work_Shift_Location_lkId__c, NG_Start_Date_Time__c, NG_End_Date_Time__c, NG_Status__c, Fyre_Sync_Req__c, NG_Vacancy_Date__c
													FROM FyreTestVac__c 
													WHERE FyreTestJob__c =: jobold.Id ];

		System.assertequals(2,tempVacs.size()); //1 Manually non Fyre inserted Vac, later fReq2 gets updated with fReq21, 1 last fReq22  .. so total 2. Thus we left the already existing record as is
		//Check to see if Self Account relationship mapping works
		tempVacs = [ 	SELECT   Id, FyreTestJob__c, NG_Job_s_Account__c, NG_Work_Shift_Location_lkId__c, NG_Start_Date_Time__c, NG_End_Date_Time__c, NG_Status__c, Fyre_Sync_Req__c, NG_Vacancy_Date__c
													FROM FyreTestVac__c
													WHERE NG_Job_s_Account__c =: childAcct3.Id ];
		System.assertequals(1,tempVacs.size());
   	
    }

    @isTest
    static void test_VacancyUpdate_NG()
    {
    	Account selfAccount = new Account (Name ='Self');insert selfAccount;
    	NGCSH__C ngcs = new NGCSH__C(SetupOwnerId=UserInfo.getOrganizationId(),SelfAccountId__c=selfAccount.Id,FyreIntegrationInTestMode__c=TRUE); insert ngcs;
        Account parent1 = new Account(Name='Parent1');insert parent1;
        Account childAcct1 = new Account(Name='ChildAcct1', ParentId=parent1.Id, VMS_Job_Account_Mapping__c=parent1.Id); insert childAcct1;
		List<FyreSync__Requisition__c> l_FReqs = new List<FyreSync__Requisition__c>();
		Test.startTest();
        FyreSync__Requisition__c fReq1 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq1',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='FL', Name='fReq1', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,01)); insert fReq1;
        FyreSync__Requisition__c fReq2 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq2',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='FL', Name='fReq2', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,02), FyreSync__ReqDetails_EndTime__c='13:30:00',  FyreSync__ReqDetails_StartTime__c='03:30:00'); insert fReq2;
        FyreSync__Requisition__c fReq3 = new FyreSync__Requisition__c(FyreSync__ReqDetails_Title__c='fReq3',FyreSync__Account__c=childAcct1.Id,FyreSync__AtsFields_CustomText1__c='Nurse Practitioner', FyreSync__AtsFields_CustomText2__c='Nutrition', FyreSync__ReqDetails_State__c='FL', Name='fReq3', FyreSync__Status__c='active',FyreSync__ReqDetails_StartDate__c=Date.newInstance(2019,02,03), FyreSync__ReqDetails_EndTime__c='13:30:00',  FyreSync__ReqDetails_StartTime__c='03:30:00'); insert fReq3;

		//Collect all Future methods here.
		Test.stopTest();

		fReq1 = [SELECT Id, Name, FyreSync__ReqDetails_Title__c, FyreSync__Account__c, FyreSync__AtsFields_CustomText1__c, FyreSync__AtsFields_CustomText2__c, FyreSync__ReqDetails_State__c, FyreSync__Status__c, FyreSync__ReqDetails_StartDate__c, FyreSync__ReqDetails_StartTime__c, FyreSync__ReqDetails_EndTime__c FROM FyreSync__Requisition__c WHERE Id =: fReq1.Id LIMIT 1];
		fReq2 = [SELECT Id, Name, FyreSync__ReqDetails_Title__c, FyreSync__Account__c, FyreSync__AtsFields_CustomText1__c, FyreSync__AtsFields_CustomText2__c, FyreSync__ReqDetails_State__c, FyreSync__Status__c, FyreSync__ReqDetails_StartDate__c, FyreSync__ReqDetails_StartTime__c, FyreSync__ReqDetails_EndTime__c FROM FyreSync__Requisition__c WHERE Id =: fReq2.Id LIMIT 1];
		fReq3 = [SELECT Id, Name, FyreSync__ReqDetails_Title__c, FyreSync__Account__c, FyreSync__AtsFields_CustomText1__c, FyreSync__AtsFields_CustomText2__c, FyreSync__ReqDetails_State__c, FyreSync__Status__c, FyreSync__ReqDetails_StartDate__c, FyreSync__ReqDetails_StartTime__c, FyreSync__ReqDetails_EndTime__c FROM FyreSync__Requisition__c WHERE Id =: fReq3.Id LIMIT 1];


		FyreTestVac__c vTemp = [SELECT   Id, FyreTestJob__c, NG_Job_s_Account__c, NG_Work_Shift_Location_lkId__c, NG_Start_Date_Time__c, NG_End_Date_Time__c, NG_Status__c, Fyre_Sync_Req__c, NG_Vacancy_Date__c
								FROM FyreTestVac__c WHERE Fyre_Sync_Req__c =: fReq1.Id Limit 1];
		System.debug('FReq1 PRECHECK STARTDATETIME : ' + (vTemp.NG_Start_Date_Time__c).format() + 'HC=' + (DateTime.newInstance(2019,02,01,08,00,00)).format());
		System.debug('FReq1 PRECHECK ENDDATETIME : ' + (vTemp.NG_End_Date_Time__c).format() + 'HC='   + (DateTime.newInstance(2019,02,01,17,00,00)).format());


		fReq1.FyreSync__ReqDetails_StartTime__c = '03:30:00'; //From blank to a value which is not 8 AM - will update record.
		fReq1.FyreSync__ReqDetails_EndTime__c	= '13:30:00'; 
		l_FReqs.add(fReq1);
		
		fReq2.FyreSync__ReqDetails_StartTime__c = '07:30:00'; //value change so - will update record.
		fReq2.FyreSync__ReqDetails_EndTime__c	= '13:30:00'; 
		l_FReqs.add(fReq2);

		fReq3.FyreSync__ReqDetails_StartTime__c = '03:30:00'; //value does not change - should not update record.
		fReq3.FyreSync__ReqDetails_EndTime__c	= '13:30:00'; 
		l_FReqs.add(fReq3);
		
		update l_FReqs;

		List<FyreTestVac__c> tempVacs = [ 	SELECT   Id, FyreTestJob__c, NG_Job_s_Account__c, NG_Work_Shift_Location_lkId__c, NG_Start_Date_Time__c, NG_End_Date_Time__c, NG_Status__c, Fyre_Sync_Req__c, NG_Vacancy_Date__c
													FROM FyreTestVac__c ];

		for(FyreTestVac__c vac: tempVacs)
		{
			if(vac.Fyre_Sync_Req__c == fReq1.Id)
			{
				System.debug('FReq1 CHECK STARTDATETIME : ' + (vac.NG_Start_Date_Time__c).format() + 'HC=' + (DateTime.newInstance(2019,02,01,03,30,00)).format());
				System.debug('FReq1 CHECK ENDDATETIME : ' + (vac.NG_End_Date_Time__c).format() + 'HC='   + (DateTime.newInstance(2019,02,01,13,30,00)).format());
			}
			if(vac.Fyre_Sync_Req__c == fReq2.Id)
			{
				System.debug('FReq2 CHECK STARTDATETIME : ' + (vac.NG_Start_Date_Time__c).format() + 'HC=' + (DateTime.newInstance(2019,02,02,07,30,00)).format());
				System.debug('FReq2 CHECK ENDDATETIME : ' + (vac.NG_End_Date_Time__c).format() + 'HC='   + (DateTime.newInstance(2019,02,02,13,30,00)).format());
			}
			if(vac.Fyre_Sync_Req__c == fReq3.Id)
			{
				System.debug('FReq3 CHECK STARTDATETIME : ' + (vac.NG_Start_Date_Time__c).format() + 'HC=' + (DateTime.newInstance(2019,02,03,03,30,00)).format());
				System.debug('FReq3 CHECK ENDDATETIME : ' + (vac.NG_End_Date_Time__c).format() + 'HC='   + (DateTime.newInstance(2019,02,03,13,30,00)).format());
			}
		}
    }


}
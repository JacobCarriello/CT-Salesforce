public class NG_TrgHndlr_FyreSyncReq_Generic 
{
	Map<Id,Id> m_accountParent = new Map<Id,Id>();
	Map<Id,Id> m_ParentAccountsOnly = new Map<Id,Id>();
	List<FyreSync__Requisition__c> eligibleReqsToProcess = new List<FyreSync__Requisition__c>();
	Map<String,sObject> m_PAFSS_Jobs = new Map<String, sObject>(); //TBD: Assumption only one such combination job exists.
	Map<Id,sObject> m_PAFSS_JobIds = new Map<Id, sObject>();
	Map<String,sObject> m_JS_Vacs = new Map<String,sObject>();
	List<sObject> L_insertVacs = new List<sObject>();
	List<sObject> L_updateVacs = new List<sObject>();
	Map<Id, FyreSync__Requisition__c> m_newFReqsUpdateTrg = new Map<Id, FyreSync__Requisition__c>();
	Map<Id, FyreSync__Requisition__c> m_oldFReqsUpdateTrg = new Map<Id, FyreSync__Requisition__c>();
	NGCSH__c ngcs;
	public NG_TrgHndlr_FyreSyncReq_Generic () 
	{
		ngcs = NGCSH__c.getOrgDefaults();
	}
	//TODO: If Parent is null then create Job on child Account (which is Parent in this case)
	 
	public void manualNonTriggerTesting()
	{
//		List<TR1__Job__c> jobs = [SELECT Id FROM TR1__Job__c WHERE TR1__Account__r.Name='AVTestSinceParentNotPresentInSB'];
//		System.debug('NGDebug: Jobs to delete during Test/Dev ='+jobs.size());
//		delete jobs;
//	When auto testing remove the status condition, when manual testing keep it	
		List<FyreSync__Requisition__c> fyreReqs = [	SELECT Id, FyreSync__Account__c, FyreSync__AdditionalDetails_MedType__c, FyreSync__AdditionalDetails_MedSpecialty__c, FyreSync__Status__c, 
													FyreSync__Account__r.Parent.Id, FyreSync__ReqDetails_Title__c, FyreSync__ReqDetails_State__c, FyreSync__ReqDetails_StartDate__c, FyreSync__ReqDetails_EndDate__c,
													FyreSync__VmsType__c, FyreSync__ReqDetails_DescriptionHtml__c, FyreSync__ReqDetails_Description__c, FyreSync__ReqDetails_PositionType__c, FyreSync__ReqDetails_StartTime__c, FyreSync__ReqDetails_EndTime__c,
													FyreSync__AtsFields_CustomText1__c, FyreSync__AtsFields_CustomText2__c, FyreSync__AtsFields_CustomText3__c, FyreSync__ReqDetails_Comments__c,
													FyreSync__ReqDetails_Qualifications__c,FyreSync__ReqDetails_Skills__c, FyreSync__AdditionalDetails_MedSetting__c
													FROM FyreSync__Requisition__c 
	 												WHERE 	 												
//	 												FyreSync__Status__c = 'Unmapped' AND
	 												FyreSync__AtsFields_CustomText1__c = 'Nurse Practitioner' AND
	 												FyreSync__AtsFields_CustomText2__c in ('Nutrition','Patient Care Services') ];
	 												
		ngcs = NGCSH__c.getOrgDefaults();
		processFReqs_PopulateJobAndVac(fyreReqs);
	}

	Id getParentAccountId(Id fReqAccountId)
	{
		if(m_accountParent.containsKey(fReqAccountId)) return m_accountParent.get(fReqAccountId);
		return fReqAccountId;
	}

	void fetchAccountParentIds(List<FyreSync__Requisition__c> fyreReqs)
	{
		for(FyreSync__Requisition__c fReq : fyreReqs)
		{
			m_accountParent.put(fReq.FyreSync__Account__c, null);
		}
		List<Account> accts = [SELECT ID, ParentId, Name, VMS_Job_Account_Mapping__c FROM Account WHERE Id in: m_accountParent.keySet()];
		m_accountParent.clear();
		Id actingParent;
		for(Account a : accts)
		{	
			System.debug('NGDebug: AccountName='+a.Name+' AccountId='+a.Id+' ParentId='+a.ParentId+' VMS_Job_Account_Mapping__c='+a.VMS_Job_Account_Mapping__c);
			//actingParent = a.ParentId == null ? a.Id : a.ParentId;
			if(a.VMS_Job_Account_Mapping__c != null)
			{
				actingParent = ( a.VMS_Job_Account_Mapping__c == (Id)ngcs.SelfAccountId__c ) ? a.Id : a.VMS_Job_Account_Mapping__c;
				if(a.VMS_Job_Account_Mapping__c == (Id)ngcs.SelfAccountId__c) System.debug('------------SELF ID FOUND: '+ a.Name);
				m_accountParent.put(a.Id, actingParent);
				m_ParentAccountsOnly.put(actingParent, actingParent);
			}
		}	
	}

	public void processFReqs_UpdateExistingVacs(Map<Id, FyreSync__Requisition__c> m_newFReqs, Map<Id, FyreSync__Requisition__c> m_oldFReqs)
	{
		//Fetch all Vacs which are already mapped to FReqs. 
		//If criteria to update is good, update and remove from main fyreReqs list otherwise let MAIN METHOD handle this fReq.
		m_newFReqsUpdateTrg = m_newFReqs;
		m_oldFReqsUpdateTrg = m_oldFReqs;
		List<FyreSync__Requisition__c> remainingFReqs = new List<FyreSync__Requisition__c>();
		reFetchVacancies('FOR UPDATE');
		FyreSync__Requisition__c newFReq;
		FyreSync__Requisition__c oldFReq;
		
		for(sObject vac: m_JS_Vacs.values())
		{
			if(m_newFReqs.containsKey(getFReqId(vac))) 
			{
				newFReq = m_newFReqs.get(getFReqId(vac));
				oldFReq = m_oldFReqs.get(getFReqId(vac)); //Not Needed as isChangedVac() is handling this now.
				if(isChangedVac(vac, newFReq))
				{
					vac = populateVac('UPDATE',vac,newFReq,null); //existingJob can be null since Update already has the Job and does not need it in populateVac()
					L_updateVacs.add(vac);
				}
			}
			else 
			{
				remainingFReqs.add(newFReq);
				continue;
			}
			
		}
		if(L_updateVacs.size() > 0) update L_updateVacs;
		if(remainingFReqs.size() > 0) processFReqs_PopulateJobAndVac(remainingFReqs); //Further processing is only required if there isn't any 1 to 1 mapping Vacs (which should be rare)
	}
	
	public Id getFReqId(sObject vac)
	{
		Id retVal;
		if(ngcs.FyreIntegrationInTestMode__c)
			retVal = ((FyreTestVac__c)vac).Fyre_Sync_Req__c;
		else
			retVal = ((TRSCHED__Vacancy_D2D__c)vac).Fyre_Sync_Req__c;
			
		return retVal;
	}

	@future
	public static void processFReqs_PopulateJobAndVac(Set<Id> fReqIds)
	{
		List<FyreSync__Requisition__c> fyreReqs = [SELECT Id, Name, FyreSync__Account__c, FyreSync__AdditionalDetails_MedType__c, FyreSync__AdditionalDetails_MedSpecialty__c, FyreSync__Status__c, 
													FyreSync__Account__r.Parent.Id, FyreSync__ReqDetails_Title__c, FyreSync__ReqDetails_State__c, FyreSync__ReqDetails_StartDate__c, FyreSync__ReqDetails_EndDate__c,
													FyreSync__VmsType__c, FyreSync__ReqDetails_DescriptionHtml__c, FyreSync__ReqDetails_Description__c, FyreSync__ReqDetails_PositionType__c, FyreSync__ReqDetails_StartTime__c, FyreSync__ReqDetails_EndTime__c,
													FyreSync__AtsFields_CustomText1__c, FyreSync__AtsFields_CustomText2__c, FyreSync__AtsFields_CustomText3__c, FyreSync__ReqDetails_Comments__c,
													FyreSync__ReqDetails_Qualifications__c,FyreSync__ReqDetails_Skills__c, FyreSync__AdditionalDetails_MedSetting__c, FyreSync__ReqDetails_Reason__c
													FROM FyreSync__Requisition__c 
													WHERE Id in: fReqIds];
		try{
			NG_TrgHndlr_FyreSyncReq_Generic me = new NG_TrgHndlr_FyreSyncReq_Generic();
			//throw new NGIException('Checking Exception');
			me.processFReqs_PopulateJobAndVac(fyreReqs);
		}
		catch(Exception e) //This is a debug code, needed to debug certain issues on Production.
		{
			String errorMessage = 'Error Populating FyreReqs: ' + e.getMessage() + e.getLineNumber();
			errorMessage += '\n' + e.getCause();
			errorMessage += '\n' + e.getStackTraceString();
			for(FyreSync__Requisition__c req : fyreReqs)
			{
				errorMessage += '\n' + 'ID: ' + req.Id + ' Name: ' + req.Name;
			}
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    		String[] toAddresses = new String[] {'aniket.vast@thenuagegroup.com'};
     		mail.setToAddresses(toAddresses);
     		mail.setReplyTo('aniket.vast@thenuagegroup.com');  
     		mail.setSenderDisplayName('Apex error message');
     		mail.setSubject('Error from THMed Fyre Org : ');
     		mail.setPlainTextBody(errorMessage);
     		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

	/* MAIN METHOD */
	public void processFReqs_PopulateJobAndVac(List<FyreSync__Requisition__c> fyreReqs)
	{
		fetchAccountParentIds(fyreReqs);
		System.debug('NGDebug: Total Reqs before sorting='+fyreReqs.size());
		for(FyreSync__Requisition__c fReq : fyreReqs)
		{
			System.debug('NGDebug: '+fReq.FyreSync__Account__c +' '+getParentAccountId(fReq.FyreSync__Account__c));
			if(fReq.FyreSync__Account__c != null && getParentAccountId(fReq.FyreSync__Account__c) != null)
			{
				if(fReq.FyreSync__AtsFields_CustomText1__c != null && fReq.FyreSync__AtsFields_CustomText2__c != null)
				{
					eligibleReqsToProcess.add(fReq);
				}
			}
		}
		System.debug('NGDebug: EligibleReqsToProcess='+eligibleReqsToProcess.size());
		System.debug('NGDebug: m_ParentAccountsOnly='+m_ParentAccountsOnly.size());

		reFetchJobs();

		insertNewJobs();
		reFetchJobs();
		reFreshJobIdMap();
		
		reFetchVacancies('FOR INSERT');
		upsertVacancies();
		reFetchVacancies('FOR INSERT'); 
		
	}
	
	void reFetchJobs()
	{
		List<sObject> tempJobs;
		if(ngcs.FyreIntegrationInTestMode__c)
			tempJobs = [SELECT Id, Name, NG_Account__c, FyreSyncReq__c, NG_Division__c, NG_Primary_Background__c, NG_State_Area__c, Position_Type__c, Comments__c, NG_Client_Job_Description__c, Job_Source__c, NG_Work_Shift_Location_lkId__c, Qualifications__c, Skills__c, Medical_Setting__c
										FROM FyreTestJobs__c
										WHERE NG_Account__c in: m_ParentAccountsOnly.values()
										ORDER BY NG_Account__c, NG_Division__c, NG_Primary_Background__c, LastModifiedDate ASC];
		else
		{
			Id jobRecordTypeId = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Medestar Locums').getRecordTypeId();
			tempJobs = [SELECT Id, Name, TR1__Account__c, FyreSyncReq__c, TR1__Division__c, TR1__Primary_Background__c, TR1__State_Area__c, Position_Type__c, Comments__c, TR1__Client_Job_Description__c, Job_Source__c, Qualifications__c, Skills__c, Medical_Setting__c
										FROM TR1__Job__c 
										WHERE RecordTypeId =: jobRecordTypeId AND TR1__Account__c in: m_ParentAccountsOnly.values() 
										ORDER BY TR1__Account__c, TR1__Division__c, TR1__Primary_Background__c, LastModifiedDate ASC];
		}
		System.debug('NGDebug: sObjJobs='+tempJobs);		
		m_PAFSS_Jobs.clear();		
		for(sObject job : tempJobs)
			m_PAFSS_Jobs.put(getJobKey(job), job);		
		System.debug('NGDebug: m_PAFSS_Jobs='+m_PAFSS_Jobs.size()+'----');
		System.debug('NGDebug: m_PAFSS_Jobs='+m_PAFSS_Jobs);
		
	}
	
	void reFreshJobIdMap()
	{
		m_PAFSS_JobIds.clear();
		for(sObject tJob: m_PAFSS_Jobs.values())
			m_PAFSS_JobIds.put(tJob.Id,tJob);
	}

//TODO Decisions: Add vacancies to Closed jobs as well.
//To reduce # of records only look 3 years back.

	void reFetchVacancies(String action)
	{
		List<sObject> tVacs;
		if(action == 'FOR INSERT')
		{
			if(ngcs.FyreIntegrationInTestMode__c)
				tVacs = 	[SELECT Id, NG_Job_s_Account__c, NG_Work_Shift_Location_lkId__c, FyreTestJob__c, NG_Start_Date_Time__c, 
								NG_End_Date_Time__c, NG_Status__c, Fyre_Sync_Req__c, NG_Vacancy_Date__c   
										FROM 	FyreTestVac__c 
										WHERE 	FyreTestJob__c in: m_PAFSS_JobIds.keySet() //TODO: Put in date criteria and status criteria
										ORDER BY FyreTestJob__c,NG_Vacancy_Date__c ASC, Fyre_Sync_Req__c ASC];		
			else
				tVacs = 	[SELECT Id, TRSCHED__Job_s_Account__c, TRSCHED__Work_Shift_Location_lkId__c, TRSCHED__Vacancy__c, TRSCHED__Start_Date_Time__c, 
								TRSCHED__End_Date_Time__c, TRSCHED__Status__c, Fyre_Sync_Req__c, TRSCHED__Vacancy_Date__c   
										FROM 	TRSCHED__Vacancy_D2D__c 
										WHERE 	TRSCHED__Vacancy__c in: m_PAFSS_JobIds.keySet() //TODO: Put in date criteria and status criteria
										ORDER BY TRSCHED__Vacancy__c,TRSCHED__Vacancy_Date__c ASC, Fyre_Sync_Req__c ASC];		
		}
		else if(action == 'FOR UPDATE')
		{
			if(ngcs.FyreIntegrationInTestMode__c)
				tVacs = 	[SELECT Id, NG_Job_s_Account__c, NG_Work_Shift_Location_lkId__c, FyreTestJob__c, NG_Start_Date_Time__c, 
								NG_End_Date_Time__c, NG_Status__c, Fyre_Sync_Req__c, NG_Vacancy_Date__c   
										FROM 	FyreTestVac__c 
										WHERE 	Fyre_Sync_Req__c in: m_newFReqsUpdateTrg.keySet() //TODO: Put in date criteria and status criteria
										ORDER BY FyreTestJob__c,NG_Vacancy_Date__c ASC, Fyre_Sync_Req__c ASC];		
			else
				tVacs = 	[SELECT Id, TRSCHED__Job_s_Account__c, TRSCHED__Work_Shift_Location_lkId__c, TRSCHED__Vacancy__c, TRSCHED__Start_Date_Time__c, 
								TRSCHED__End_Date_Time__c, TRSCHED__Status__c, Fyre_Sync_Req__c, TRSCHED__Vacancy_Date__c   
										FROM 	TRSCHED__Vacancy_D2D__c 
										WHERE 	Fyre_Sync_Req__c in: m_newFReqsUpdateTrg.keySet() //TODO: Put in date criteria and status criteria
										ORDER BY TRSCHED__Vacancy__c,TRSCHED__Vacancy_Date__c ASC, Fyre_Sync_Req__c ASC];		
			
		}
		System.debug('NGDebug: reFetchVacancies : DB Vacs size ='+tVacs.size());
		m_JS_Vacs.clear();
		String vacKey;
		for(sObject tVac : tVacs)
		{
			//TBD: # of # opening should be included as well (put if containsKey then increase number and put in next key, seq may not be guaranteed)
			vacKey = getVacKey(tVac);
			m_JS_Vacs.put(vacKey, tVac);
		}
		System.debug('NGDebug: After VacKey Map Unique Vacs : m_JS_Vacs size = '+m_JS_Vacs.size());
		//System.debug('NGDebug: m_JS_Vacs  = '+m_JS_Vacs);
	}
	
	void upsertVacancies()
	{	
		L_updateVacs.clear();
		sObject existingJob; 
		String jobKey;
		sObject existingVac;
		sObject newVac;
		String vacKey;
		String fReqStatus ;
		for(FyreSync__Requisition__c fReq : eligibleReqsToProcess)
		{
			jobKey = getJobKey(fReq);
			existingJob = m_PAFSS_Jobs.get(jobKey);
			if(existingJob == null) {System.debug('NGDebug: Job not found OR Jobs recordType is not qualified .. SKIP FyreReq='+fReq.Id+' JobKey='+jobKey); continue; }
			vacKey = getVacKey(existingJob.Id, fReq);
			existingVac = m_JS_Vacs.get(vacKey);
			fReqStatus = getJobStatus(fReq.FyreSync__Status__c);
			if(existingVac == null)
			{
				System.debug('----------------INSERT VAC= '+fReq.FyreSync__ReqDetails_Title__c);
				if(fReqStatus == 'Unfilled' || fReqStatus == 'Cancelled') continue;
				newVac = populateVac('INSERT',newVac,fReq,existingJob);
				L_insertVacs.add(newVac);
			}
			else if(isChangedVac(existingVac,fReq)) //Identify change if changes need to be updated, then update.
			{
				System.debug('----------------UPDATE VAC= '+fReq.FyreSync__ReqDetails_Title__c);
				existingVac = populateVac('UPDATE',existingVac,fReq,existingJob);
				L_updateVacs.add(existingVac);
			}			
		}
		if(L_insertVacs.size() > 0)
			insert L_insertVacs;
		if(L_updateVacs.size() > 0)
			update L_updateVacs;
	}
	
	sObject populateVac(String method, sObject vac, FyreSync__Requisition__c fReq, sObject existingJob)
	{
		if(method.equalsIgnoreCase('INSERT'))
		{
			if(ngcs.FyreIntegrationInTestMode__c) 
			{	
				vac = new FyreTestVac__c();
				((FyreTestVac__c)vac).FyreTestJob__c 							= existingJob.Id;
				((FyreTestVac__c)vac).NG_Vacancy_Date__c 						= fReq.FyreSync__ReqDetails_StartDate__c;
				((FyreTestVac__c)vac).NG_Job_s_Account__c 						= getParentAccountId(fReq.FyreSync__Account__c);
				((FyreTestVac__c)vac).NG_Work_Shift_Location_lkId__c 			= fReq.FyreSync__Account__c;
				((FyreTestVac__c)vac).NG_Start_Date_Time__c 					= getStartDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_StartTime__c); 
				((FyreTestVac__c)vac).NG_End_Date_Time__c 						= getEndDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_EndDate__c, fReq.FyreSync__ReqDetails_EndTime__c);   
				((FyreTestVac__c)vac).NG_Status__c 								= getJobStatus(fReq.FyreSync__Status__c); 						 
				((FyreTestVac__c)vac).Fyre_Sync_Req__c 							= fReq.Id;				
			}
			else
			{
				vac = new TRSCHED__Vacancy_D2D__c();
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Vacancy__c 						= existingJob.Id;
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Vacancy_Date__c 				= fReq.FyreSync__ReqDetails_StartDate__c;
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Job_s_Account__c 				= getParentAccountId(fReq.FyreSync__Account__c);
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Work_Shift_Location_lkId__c 	= fReq.FyreSync__Account__c;
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Start_Date_Time__c 				= getStartDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_StartTime__c); 
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__End_Date_Time__c 				= getEndDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_EndDate__c, fReq.FyreSync__ReqDetails_EndTime__c);   
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Status__c 						= getJobStatus(fReq.FyreSync__Status__c); 						 
				((TRSCHED__Vacancy_D2D__c)vac).Fyre_Sync_Req__c 						= fReq.Id;
			}
		}else if(method.equalsIgnoreCase('UPDATE'))
		{
			if(ngcs.FyreIntegrationInTestMode__c)
			{
				((FyreTestVac__c)vac).NG_Status__c 									= getJobStatus(fReq.FyreSync__Status__c);
				if(!String.isBlank(fReq.FyreSync__ReqDetails_StartTime__c) && ((FyreTestVac__c)vac).NG_Start_Date_Time__c != getStartDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_StartTime__c))
					((FyreTestVac__c)vac).NG_Start_Date_Time__c = getStartDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_StartTime__c);
				if(!String.isBlank(fReq.FyreSync__ReqDetails_EndTime__c) && ((FyreTestVac__c)vac).NG_End_Date_Time__c != getEndDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_EndDate__c, fReq.FyreSync__ReqDetails_EndTime__c))
					((FyreTestVac__c)vac).NG_End_Date_Time__c = getEndDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_EndDate__c, fReq.FyreSync__ReqDetails_EndTime__c);
				//TODO: Add any additional changes that need to be moved over.
			}
			else
			{
				((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Status__c 					= getJobStatus(fReq.FyreSync__Status__c);
				if(!String.isBlank(fReq.FyreSync__ReqDetails_StartTime__c) && ((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Start_Date_Time__c != getStartDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_StartTime__c))
					((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__Start_Date_Time__c = getStartDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_StartTime__c);
				if(!String.isBlank(fReq.FyreSync__ReqDetails_EndTime__c) && ((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__End_Date_Time__c != getEndDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_EndDate__c, fReq.FyreSync__ReqDetails_EndTime__c))
					((TRSCHED__Vacancy_D2D__c)vac).TRSCHED__End_Date_Time__c = getEndDateTime(fReq.FyreSync__ReqDetails_StartDate__c, fReq.FyreSync__ReqDetails_EndDate__c, fReq.FyreSync__ReqDetails_EndTime__c);
				//TODO: Add any additional changes that need to be moved over.
			}
		}
		return vac;
	}
	
	boolean isChangedVac(sObject existingVac, FyreSync__Requisition__c newFReq)
	{
		Boolean retVal = false;
		String jobStatus;
		Boolean jobCreatedByFyre = false;
		if(ngcs.FyreIntegrationInTestMode__c)
		{
			jobStatus = ((FyreTestVac__c)existingVac).NG_Status__c;
			jobCreatedByFyre = ((FyreTestVac__c)existingVac).Fyre_Sync_Req__c != null ? true : false;
		}
		else
		{
			jobStatus = ((TRSCHED__Vacancy_D2D__c)existingVac).TRSCHED__Status__c;
			jobCreatedByFyre = ((TRSCHED__Vacancy_D2D__c)existingVac).Fyre_Sync_Req__c != null ? true : false;
		}
		FyreSync__Requisition__c oldFReq;
		if(m_oldFReqsUpdateTrg != null && m_oldFReqsUpdateTrg.size() > 0) 
			oldFReq = m_oldFReqsUpdateTrg.get(newFReq.Id);
			
		if(jobCreatedByFyre && jobStatus != 'Booked') //Only of the record is eligible to be upgraded with the basic criteria, then check for other criteria.
		{
			if(jobStatus != getJobStatus(newFReq.FyreSync__Status__c))
				retVal = true;
			if(!String.isBlank(newFReq.FyreSync__ReqDetails_StartTime__c) && newFReq.FyreSync__ReqDetails_StartTime__c != '00:00:00')
				if(oldFReq != null && oldFReq.FyreSync__ReqDetails_StartTime__c != newFReq.FyreSync__ReqDetails_StartTime__c)
					retVal = true;
			if(!String.isBlank(newFReq.FyreSync__ReqDetails_EndTime__c) && newFReq.FyreSync__ReqDetails_EndTime__c != '00:00:00')
				if(oldFReq != null && oldFReq.FyreSync__ReqDetails_EndTime__c != newFReq.FyreSync__ReqDetails_EndTime__c)
					retVal = true;
			if(oldFReq != null)
			{
//				if(oldFReq.FieldName != newFReq.FieldName || oldFReq.FieldName != newFReq.FieldName) retVal = true;
			}
		}
		return retVal;	
	}
	
	private Map<String,String> stateMap_toAbbrev = new Map<String,String>{ 'alabama'=>'AL','alaska'=>'AK','arizona'=>'AZ','arkansas'=>'AR','california'=>'CA','colorado'=>'CO','connecticut'=>'CT','delaware'=>'DE','district of columbia'=>'DC','florida'=>'FL','georgia'=>'GA','guam'=>'GU','hawaii'=>'HI','idaho'=>'ID','illinois'=>'IL','indiana'=>'IN','iowa'=>'IA','kansas'=>'KS','kentucky'=>'KY','louisiana'=>'LA','maine'=>'ME','maryland'=>'MD','massachusetts'=>'MA','michigan'=>'MI','minnesota'=>'MN','mississippi'=>'MS','missouri'=>'MO','montana'=>'MT','nebraska'=>'NE','nevada'=>'NV','new hampshire'=>'NH','new jersey'=>'NJ','new mexico'=>'NM','new york'=>'NY','north carolina'=>'NC','north dakota'=>'ND','ohio'=>'OH','oklahoma'=>'OK','oregon'=>'OR','pennsylvania'=>'PA','puerto rico'=>'PR','rhode island'=>'RI','south carolina'=>'SC','south dakota'=>'SD','tennessee'=>'TN','texas'=>'TX','utah'=>'UT','vermont'=>'VT','virginia'=>'VA','washington'=>'WA','west virginia'=>'WV','wisconsin'=>'WI','wyoming'=>'WY' };
    private Map<String,String> stateMap_toName = new Map<String,String>{ 'al'=>'Alabama','ak'=>'Alaska','az'=>'Arizona','ar'=>'Arkansas','ca'=>'California','co'=>'Colorado','ct'=>'Connecticut','de'=>'Delaware','dc'=>'District of Columbia','fl'=>'Florida','ga'=>'Georgia','gu'=>'Guam','hi'=>'Hawaii','id'=>'Idaho','il'=>'Illinois','in'=>'Indiana','ia'=>'Iowa','ks'=>'Kansas','ky'=>'Kentucky','la'=>'Louisiana','me'=>'Maine','md'=>'Maryland','ma'=>'Massachusetts','mi'=>'Michigan','mn'=>'Minnesota','ms'=>'Mississippi','mo'=>'Missouri','mt'=>'Montana','ne'=>'Nebraska','nv'=>'Nevada','nh'=>'New Hampshire','nj'=>'New Jersey','nm'=>'New Mexico','ny'=>'New York','nc'=>'North Carolina','nd'=>'North Dakota','oh'=>'Ohio','ok'=>'Oklahoma','or'=>'Oregon','pa'=>'Pennsylvania','pr'=>'Puerto Rico','ri'=>'Rhode Island','sc'=>'South Carolina','sd'=>'South Dakota','tn'=>'Tennessee','tx'=>'Texas','ut'=>'Utah','vt'=>'Vermont','va'=>'Virginia','wa'=>'Washington','wv'=>'West Virginia','wi'=>'Wisconsin','wy'=>'Wyoming' };
	private Map<String,String> status_fReq_Job = new Map<String,String>{ 'open'=>'Open','unmapped'=>'Open','cancelled'=>'Cancelled','filled'=>'Unfilled','closed'=>'Unfilled','hold'=>'Open','active'=>'Open','declined'=>'Unfilled','waiting'=>'Open' };
    private Map<String,String> map_positionType = new Map<String,String>{'temp'=>'Locum Tenens','per diem'=>'Locum Tenens','locums-to-perm'=>'Locum Tenens','locum tenens'=>'Locum Tenens','contract'=>'Locum Tenens','transition management'=>'Locum Tenens','perm'=>'Permanent','permanent'=>'Permanent'};
    public String getStateFullName(String state_name)
    { 
            if(state_name==null){ return null; }
            String state_name_lCase = state_name.toLowerCase().trim();
            return stateMap_toAbbrev.containsKey(state_name_lCase) ? stateMap_toAbbrev.get(state_name_lCase) : (stateMap_toName.containsKey(state_name_lCase) ? stateMap_toName.get(state_name_lCase) : null);
    }
	public String getStateAbbr(String state_name)
	{
            if(state_name==null){ return null; }
            String state_name_lCase = state_name.toLowerCase().trim();
            return stateMap_toAbbrev.containsKey(state_name_lCase) ? stateMap_toAbbrev.get(state_name_lCase) : (stateMap_toName.containsKey(state_name_lCase) ? state_name.toUpperCase() : null);
	}
    public String getMappedPositionType(String pt)
    { 
            if(pt==null){ return null;}
            String pt_lCase = pt.toLowerCase().trim();
            return map_positionType.containsKey(pt_lCase) ? map_positionType.get(pt_lCase) : null;
    }
    String getJobStatus(String fReqStatus)
    {
    	return status_fReq_Job.containsKey(fReqStatus) ? status_fReq_Job.get(fReqStatus) : 'Unfilled';
    }
	public String getJobKey(FyreSync__Requisition__c fReq)
	{
		String stateFullName = getStateFullName(fReq.FyreSync__ReqDetails_State__c);
		String jobKey = getParentAccountId(fReq.FyreSync__Account__c)+'_'+fReq.FyreSync__AtsFields_CustomText1__c+'_'+fReq.FyreSync__AtsFields_CustomText2__c+'_'+stateFullName;
		return jobKey;
	}
	public String getJobKey(sObject jobObj)
	{
		
		String jobKey = '';
		if(ngcs.FyreIntegrationInTestMode__c)
		{	
			FyreTestJobs__c job = (FyreTestJobs__c)jobObj;
			jobKey = job.NG_Account__c+'_'+job.NG_Division__c+'_'+job.NG_Primary_Background__c+'_'+job.NG_State_Area__c;
		}
		else
		{
			TR1__Job__c job = (TR1__Job__c)jobObj;
			jobKey = job.TR1__Account__c+'_'+job.TR1__Division__c+'_'+job.TR1__Primary_Background__c+'_'+job.TR1__State_Area__c;
		}
		return jobKey;
	}
	public String getVacKey(Id jobId, FyreSync__Requisition__c fReq)
	{
		String vacKey = jobId+'_'+fReq.FyreSync__ReqDetails_StartDate__c;
		return vacKey;
	}
	public String getVacKey(sObject vacObj)
	{
		String vacKey = '';
		//Vac cannot pre-exist without a job so in the vacKey we can begin with JobID
		if(ngcs.FyreIntegrationInTestMode__c)
		{	
			FyreTestVac__c tVac = (FyreTestVac__c)vacObj;
			vacKey = tVac.FyreTestJob__c+'_'+tVac.NG_Vacancy_Date__c; //For now only one Shift per day
		}
		else
		{
			TRSCHED__Vacancy_D2D__c tVac = (TRSCHED__Vacancy_D2D__c)vacObj;
			vacKey = tVac.TRSCHED__Vacancy__c+'_'+tVac.TRSCHED__Vacancy_Date__c; //For now only one Shift per day			
		}
		return vacKey;
	}
	public String getJobName(FyreSync__Requisition__c fReq)
	{
		String retVal = '';
//		retVal = (fReq.FyreSync__ReqDetails_Title__c != null && fReq.FyreSync__ReqDetails_Title__c.length() > 79) ? fReq.FyreSync__ReqDetails_Title__c.subString(0,79) : fReq.FyreSync__ReqDetails_Title__c;
		String posType = getMappedPositionType(fReq.FyreSync__ReqDetails_PositionType__c) == null ? '' : getMappedPositionType(fReq.FyreSync__ReqDetails_PositionType__c);
		retVal = getStateAbbr(fReq.FyreSync__ReqDetails_State__c) + ' ' + fReq.FyreSync__AtsFields_CustomText2__c + ' ' + fReq.FyreSync__AtsFields_CustomText1__c + ' - (' + posType  + ')';
		retVal = retVal.length() > 79 ? retVal.subString(0,79) : retVal;
		return retVal;
	}

	void insertNewJobs()
	{
		if(ngcs.FyreIntegrationInTestMode__c)
			insertNewTestJobs();
		else
			insertNewTRJobs();
	}
	
	void insertNewTestJobs()
	{				
		FyreTestJobs__c existingJob = null;
		String jobKey;
		List<FyreTestJobs__c> insertJobs = new List<FyreTestJobs__c>();
		for(FyreSync__Requisition__c fReq : eligibleReqsToProcess)
		{
			jobKey = getJobKey(fReq);
			existingJob = (FyreTestJobs__c)m_PAFSS_Jobs.get(jobKey);
			if(existingJob == null)
			{	
				System.debug('NGDebug: Creating inMemory Job for = '+ jobKey);
				FyreTestJobs__c tJob 				= new FyreTestJobs__c();
				tJob.NG_Account__c 					= getParentAccountId(fReq.FyreSync__Account__c);
				tJob.FyreSyncReq__c 				= fReq.Id;
				tJob.NG_Division__c 				= fReq.FyreSync__AtsFields_CustomText1__c;
				tJob.NG_Primary_Background__c 		= fReq.FyreSync__AtsFields_CustomText2__c;
				tJob.Name 							= getJobName(fReq);
				tJob.NG_State_Area__c	 			= getStateFullName(fReq.FyreSync__ReqDetails_State__c);
				tJob.Job_Source__c					= fReq.FyreSync__VmsType__c;
				tJob.NG_Client_Job_Description__c	= fReq.FyreSync__ReqDetails_DescriptionHtml__c;
				tJob.Comments__c					= fReq.FyreSync__ReqDetails_Description__c;
				tJob.Position_Type__c				= getMappedPositionType(fReq.FyreSync__ReqDetails_PositionType__c);
				tJob.NG_Work_Shift_Location_lkId__c	= fReq.FyreSync__Account__c;
				tJob.Specialties_Accepted__c		= fReq.FyreSync__AtsFields_CustomText3__c;
				tJob.NG_Reason_for_Vacancy__c		= fReq.FyreSync__ReqDetails_Reason__c;
				tJob.NG_Types_of_Cases__c			= fReq.FyreSync__ReqDetails_Comments__c;
				tJob.Qualifications__c 				= fReq.FyreSync__ReqDetails_Qualifications__c;
				tJob.Skills__c						= fReq.FyreSync__ReqDetails_Skills__c;
				tJob.Medical_Setting__c				= fReq.FyreSync__AdditionalDetails_MedSetting__c;
				insertJobs.add(tJob);
				m_PAFSS_Jobs.put(jobKey,tJob);
			}
		}
		System.debug('NGDebug: New Jobs to insert='+insertJobs.size()+' '+insertJobs);
		insert insertJobs;		
	}
	void insertNewTRJobs()
	{				
		TR1__Job__c existingJob = null;
		String jobKey;
		List<TR1__Job__c> insertJobs = new List<TR1__Job__c>();
		Id jobRecordTypeId = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Medestar Locums').getRecordTypeId(); 
		for(FyreSync__Requisition__c fReq : eligibleReqsToProcess)
		{
			jobKey = getJobKey(fReq);
			existingJob = (TR1__Job__c)m_PAFSS_Jobs.get(jobKey);
			if(existingJob == null)
			{	
				System.debug('NGDebug: Creating inMemory Job for = '+ jobKey);
				TR1__Job__c tJob 					= new TR1__Job__c();
				tJob.TR1__Account__c 				= getParentAccountId(fReq.FyreSync__Account__c);
				tJob.FyreSyncReq__c 				= fReq.Id;
				tJob.TR1__Division__c 				= fReq.FyreSync__AtsFields_CustomText1__c;
				tJob.TR1__Primary_Background__c 	= fReq.FyreSync__AtsFields_CustomText2__c;
				tJob.TR1__External_Job_Title__c 	= fReq.FyreSync__ReqDetails_Title__c;
				tJob.TR1__Job_Title__c 				= fReq.FyreSync__ReqDetails_Title__c;
				tJob.Name 							= getJobName(fReq);
				tJob.RecordTypeId 					= jobRecordTypeId;
				tJob.TR1__State_Area__c 			= getStateFullName(fReq.FyreSync__ReqDetails_State__c);
				tJob.TR1__Estimated_Start_Date__c	= fReq.FyreSync__ReqDetails_StartDate__c;
//				tJob.TR1__Estimated_End_Date__c		= fReq.FyreSync__ReqDetails_EndDate__c != null ? fReq.FyreSync__ReqDetails_EndDate__c : fReq.FyreSync__ReqDetails_StartDate__c;
				tJob.TRSCHED__Work_Shift_Location_lkId__c 	= fReq.FyreSync__Account__c;
				tJob.TR1__Work_Shift_Location_lkId__c		= fReq.FyreSync__Account__c;
				tJob.Job_Source__c					= fReq.FyreSync__VmsType__c;
				tJob.TR1__Client_Job_Description__c	= fReq.FyreSync__ReqDetails_DescriptionHtml__c;
				tJob.Comments__c					= fReq.FyreSync__ReqDetails_Description__c;
				tJob.Position_Type__c				= getMappedPositionType(fReq.FyreSync__ReqDetails_PositionType__c);
				tJob.Specialties__c					= fReq.FyreSync__AtsFields_CustomText3__c;
				tJob.TRSCHED__Reason_for_Vacancy__c	= fReq.FyreSync__ReqDetails_Reason__c;
				tJob.Types_of_Cases__c				= fReq.FyreSync__ReqDetails_Comments__c;
				tJob.Qualifications__c 				= fReq.FyreSync__ReqDetails_Qualifications__c;
				tJob.Skills__c						= fReq.FyreSync__ReqDetails_Skills__c;
				tJob.Medical_Setting__c				= fReq.FyreSync__AdditionalDetails_MedSetting__c;				
				insertJobs.add(tJob);
				m_PAFSS_Jobs.put(jobKey,tJob);
			}
		}
		System.debug('NGDebug: New Jobs to insert='+insertJobs.size()+' '+insertJobs);
		insert insertJobs;		
	}
	
	DateTime getStartDateTime(Date dt, String t)
	{
		return getDT(dt, t, 'START');
	}
	DateTime getEndDateTime(Date sDT, Date eDt, String et)
	{
		if(eDT != null) return getDT(eDt, et, 'END');
		return getDT(sDT, et, 'END');
	}
	DateTime getDT(Date dt, String t, String dtType)
	{
		String strDt = '';
		DateTime retVal;
		t = String.isBlank(t) ? ( dtType == 'START'? '08:00:00' : '17:00:00') : t ;
		strDt = String.valueOf(dt) + ' '+t;
		System.debug('NGDebug: '+dtType+' DateTime Conversion : Input= ' + strDt);
		//retVal = DateTime.parse(String.valueOf(dt) +' '+ t);
		String[] splitDT = strDt.split('[\\x20:-]');
		System.debug(splitDT);
		//retVal = DateTime.valueOfGMT(String.valueOf(dt) + ' '+t);
		Integer year 	= Integer.valueOf(splitDT[0]);
		Integer month 	= Integer.valueOf(splitDT[1]);
		Integer day 	= Integer.valueOf(splitDT[2]);
		Integer hour	= 0; 	
		Integer min 	= 0; 
		Integer sec 	= 0; 
		try { hour = splitDT.size() >= 4 ? Integer.valueOf(splitDT[3]) : 0; } catch(Exception e) { hour = 0;}
		try { min  = splitDT.size() >= 5 ? Integer.valueOf(splitDT[4]) : 0; } catch(Exception e) { min  = 0;}
		try { sec  = splitDT.size() >= 6 ? Integer.valueOf(splitDT[5]) : 0; } catch(Exception e) { sec  = 0;}
		retVal = DateTime.newInstance(year,month,day,hour,min,sec);
		System.debug('NGDebug: '+dtType+' DateTime Conversion : OutputGMT= '+retVal+' OutputFormat='+retVal.format());
		return retVal;
	}
public class NGIException extends Exception {}
}
public virtual class BaseTriggerHandler 
    implements ITriggerHandler
{
    private string m_Object_Name;
 	private List<SObjectUnitOfWork> m_uowList = new List<SObjectUnitOfWork>();

    public BaseTriggerHandler(String objectName) {
        this.m_Object_Name = objectName;
    }

	/**
	 * bulkBefore
	 *
	 * This method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	public void bulkBefore()
	{
		// If this a delete trigger Cache a list of Account Id's that are 'in use'
		if (Trigger.isDelete)
		{
			// Example Gateway calls to pre-fetch any needed account records
			//--------------------------------------------------------------
			// pre load all the in use projects passed to this trigger
			//m_inUseIds = AccountGateway.findAccountIdsInUse(Trigger.oldMap.keySet());
			//--------------------------------------------------------------
		}
	}
	
	public void bulkAfter()
	{
	}
		
	public void beforeInsert(SObject so)
	{
		List<ITriggerHelper> helpers = TriggerHelperGateway.handleHelpers(m_Object_Name, so, 'beforeInsert');
		addUnitOfWorksFromHelpersToList(helpers);
	}
	
	public void beforeUpdate(SObject so, SObject oldSo)
	{
		List<ITriggerHelper> helpers = TriggerHelperGateway.handleHelpers(m_Object_Name, so, oldSo, 'beforeUpdate');
		addUnitOfWorksFromHelpersToList(helpers);
	}
	
	/**
	 * beforeDelete
	 *
	 * This method is called iteratively for each record to be deleted during a BEFORE
	 * trigger.
	 */
	public void beforeDelete(SObject so)
	{	
		List<ITriggerHelper> helpers = TriggerHelperGateway.handleHelpers(m_Object_Name, so, 'beforeDelete');
		addUnitOfWorksFromHelpersToList(helpers);
	}
	
	public void afterInsert(SObject so)
	{
		List<ITriggerHelper> helpers = TriggerHelperGateway.handleHelpers(m_Object_Name, so, 'afterInsert');
		addUnitOfWorksFromHelpersToList(helpers);		
	}
	
	public void afterUpdate(SObject so, SObject oldSo)
	{
		List<ITriggerHelper> helpers = TriggerHelperGateway.handleHelpers(m_Object_Name, so, oldSo, 'afterUpdate');
		addUnitOfWorksFromHelpersToList(helpers);
	}
	
	public void afterDelete(SObject so)
	{
		List<ITriggerHelper> helpers = TriggerHelperGateway.handleHelpers(m_Object_Name, so, 'afterDelete');
		addUnitOfWorksFromHelpersToList(helpers);
	}
	
	/**
	 * andFinally
	 *
	 * This method is called once all records have been processed by the trigger. Use this 
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	public void andFinally()
	{
		// Example of any finally logic needed
		//------------------------------------
		// insert any audit records
		//if (!m_audits.isEmpty())
		//{
		//	insert m_audits;
		//}
		//------------------------------------

		for(SObjectUnitOfWork uow : m_uowList) {
			uow.commitWork();
		}
	}

	private void addUnitOfWorksFromHelpersToList(List<ITriggerHelper> helpers) {
		system.debug('bw-trgframe: BaseTriggerHandler.addUnitOfWorksFromHelpersToLsit -> helpers = ' + helpers);
		if(helpers != null) {
			List<SObjectUnitOfWork> uows = new List<SObjectUnitOfWork>();

			for(ITriggerHelper h : helpers) {
				uows = h.getUnitsOfWork();
				system.debug('bw-trgframe: BaseTriggerHandler.addUnitOfWorksFromHelpersToLsit -> h.uows = ' + uows);
				if(uows != null) {
					m_uowList.addAll(uows);
				}
			}
		}
	}
}
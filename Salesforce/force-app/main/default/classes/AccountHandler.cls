/**
 * Class AccountHandler
 *
 * Trigger Handler for the Account SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class AccountHandler
	extends BaseTriggerHandler
{	
	// Example member variables
	//--------------------------
	// Member variable to hold the Id's of Accounts 'in use'
	//private Set<Id> m_inUseIds = new Set<Id>();
	
	// Member variable to record Audit records
	//private List<Audit__c> m_audits = new List<Audit__c>();
	//--------------------------

	// Constructor
	public AccountHandler()
	{
		super('Account');
	}

}
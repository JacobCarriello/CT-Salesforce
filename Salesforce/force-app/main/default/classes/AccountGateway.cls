/**
 * Class AccountGateway
 *
 * Provides finder methods for accessing data in the Account object.
 */
public without sharing class AccountGateway
{
	public static String getName(Id ident) {
		List<Account> accts = [SELECT Name FROM Account WHERE Id = :ident Limit 1];

		if(accts.size() > 0){
			return accts[0].Name;
		}

		return null;
	}
	// Example method used to fetch recrords using SOQL
	///**
	// * Returns a subset of id's where there are any records in use.
	// *
	// * Arguments:	Set<Id> accIds - Set of Account Id's to examine
	// *
	// * Returns:		Set<Id> - Set of Account Id's that are 'in use'
	// */
	//public static Set<Id> findAccountIdsInUse(Set<Id> accIds)
	//{
	//	Set<Id> inUseIds = new Set<Id>();
	//	
	//	for (Account[] accounts : [Select p.Id, (Select Id From Opportunities Limit 1) From Account p where p.Id in : accIds])
	//	{	
	//		for (Account acc : accounts)
	//		{
	//			if (acc.Opportunities.size() > 0)
	//			{
	//				inUseIds.add(acc.id);
	//			}
	//		}
	//	}
	//	
	//	return inUseIds;
	//}
}
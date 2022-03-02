public class NG_TrgHndler_FyreSync 
{
	private boolean m_isExecuting = false;
  	private integer BatchSize = 0;
    private static boolean updateOnce = True;
  	
  	public NG_TrgHndler_FyreSync(boolean isExecuting, integer size)
  	{
    	m_isExecuting = isExecuting;
    	BatchSize = size;
  	}   

 	public void onAfterInsert(Map <Id,FyreSync__Requisition__c> newFReqs)
  	{
		NG_TrgHndlr_FyreSyncReq_Generic.processFReqs_PopulateJobAndVac(newFReqs.keySet());
  		//NG_TrgHndlr_FyreSyncReq_Generic hndlr1 = new NG_TrgHndlr_FyreSyncReq_Generic();
  		//hndlr1.processFReqs_PopulateJobAndVac(newFReqs.values());
  	}
    public void onAfterUpdate(Map<Id, FyreSync__Requisition__c> newFReqs, Map<Id, FyreSync__Requisition__c> oldFReqs) 
    {
  		NG_TrgHndlr_FyreSyncReq_Generic hndlr1 = new NG_TrgHndlr_FyreSyncReq_Generic();
  		hndlr1.processFReqs_UpdateExistingVacs(newFReqs, oldFReqs);
    } 	
  	    
}
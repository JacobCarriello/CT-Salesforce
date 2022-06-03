global class DocusignRecipientStatusBatchUpdate implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, dsfs__DocuSign_Recipient_Email__c from dsfs__DocuSign_Recipient_Status__c where dsfs__DocuSign_Recipient_Email__c != null AND dsfs__Contact__c = null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<String, Contact> mapContacts = new Map<String, Contact>();
        for(dsfs__DocuSign_Recipient_Status__c sObj : (List<dsfs__DocuSign_Recipient_Status__c>)scope){
            mapContacts.put(sObj.dsfs__DocuSign_Recipient_Email__c, null);
        }
        
        //fetch Contacts
    	for(Contact ct : [Select Id, Email from Contact where Email in : mapContacts.keySet()]){
    		mapContacts.put(ct.Email, ct);
    	}
    	
    	List<dsfs__DocuSign_Recipient_Status__c> listToUpdate = new List<dsfs__DocuSign_Recipient_Status__c>();
    	for(dsfs__DocuSign_Recipient_Status__c sObj : (List<dsfs__DocuSign_Recipient_Status__c>)scope){
    		if(mapContacts.containsKey(sObj.dsfs__DocuSign_Recipient_Email__c) && mapContacts.get(sObj.dsfs__DocuSign_Recipient_Email__c) != null){
    			listToUpdate.add(new dsfs__DocuSign_Recipient_Status__c(dsfs__Contact__c = mapContacts.get(sObj.dsfs__DocuSign_Recipient_Email__c).Id, Id = sObj.id));
    		}
    	}
        try{
        	Database.update(listToUpdate,true);
        }catch(Exception ex){
        	System.debug('Exception ----- ' + ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}
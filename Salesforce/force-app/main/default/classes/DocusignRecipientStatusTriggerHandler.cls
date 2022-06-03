public class DocusignRecipientStatusTriggerHandler {
    
    public static void beforeInsertUpdate(List<dsfs__DocuSign_Recipient_Status__c> newList, Map<Id, dsfs__DocuSign_Recipient_Status__c> oldMap){
    	assignContact(newList, oldMap);
    }
    
    private static void assignContact(List<dsfs__DocuSign_Recipient_Status__c> newList, Map<Id, dsfs__DocuSign_Recipient_Status__c> oldMap){
    	Boolean isInsert = oldMap == null;
    	
    	Map<String, Contact> mapContacts = new Map<String, Contact>();
    	
    	for(dsfs__DocuSign_Recipient_Status__c sObj : newList){
    		if(sObj.dsfs__Contact__c == null && sObj.dsfs__DocuSign_Recipient_Email__c != null && 
    			(isInsert || sObj.dsfs__DocuSign_Recipient_Email__c != oldMap.get(sObj.id).dsfs__DocuSign_Recipient_Email__c)){
    			mapContacts.put(sObj.dsfs__DocuSign_Recipient_Email__c, null);
    		}
    	}
    	
    	//fetch Contacts
    	for(Contact ct : [Select Id, Email from Contact where Email in : mapContacts.keySet()]){
    		mapContacts.put(ct.Email, ct);
    	}
    	
    	for(dsfs__DocuSign_Recipient_Status__c sObj : newList){
    		if(mapContacts.containsKey(sObj.dsfs__DocuSign_Recipient_Email__c) && mapContacts.get(sObj.dsfs__DocuSign_Recipient_Email__c) != null){
    			sObj.dsfs__Contact__c = mapContacts.get(sObj.dsfs__DocuSign_Recipient_Email__c).Id;
    		}
    	}
    }
}
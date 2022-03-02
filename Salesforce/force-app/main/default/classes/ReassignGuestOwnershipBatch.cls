public class ReassignGuestOwnershipBatch implements Database.Batchable<sObject>, Database.Stateful{

    private List<String> objectApiNameList;
    private Set<Id> guestSiteUserIdSet;
    private Id reassignUserId;
    private Integer currIndex;
    private Integer processBatchSize;
    private Set<String> debugLogSet = new Set<String>();

    public ReassignGuestOwnershipBatch(List<String> objectNameList, Integer currentIndex, Set<Id> siteUserIdSet, Id fallbackUserId, Integer batchSize){
        this.guestSiteUserIdSet = siteUserIdSet;
        this.objectApiNameList = objectNameList;
        this.currIndex = currentIndex;
        this.reassignUserId = fallbackUserId;
        this.processBatchSize = batchSize;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String soql = 'SELECT OwnerId FROM ' + objectApiNameList.get(currIndex) + ' WHERE OwnerId IN :guestSiteUserIdSet';
        return Database.getQueryLocator(soql);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(reassignUserId != null && !guestSiteUserIdSet.isEmpty()) {
            //Change the owner of the records
            for (SObject objRecord : scope) {
                objRecord.put('OwnerId', reassignUserId);
            }

            List<Database.SaveResult> saveResultList = Database.update(scope, false);

            for(Database.SaveResult sr:saveResultList){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        if(!debugLogSet.contains(err.getMessage())) debugLogSet.add(err.getMessage());
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC){

        Integer nextIndex = currIndex + 1;
        if (nextIndex < objectApiNameList.size()) {
            ReassignGuestOwnershipBatch qBatch = new ReassignGuestOwnershipBatch(objectApiNameList, nextIndex, guestSiteUserIdSet, reassignUserId, processBatchSize);
            Database.executeBatch(qBatch, processBatchSize);
        }
    }

}
public with sharing class Trigger_LogicMenon {
    
    public Static Boolean DELETE_LOGICMELON_JOBPOSTING = true;
    
    //Method to delete all LogicMelon channels with status as delivered
    public static void LogicMenon_deleteJobPostings(Map<id,TR1__Job__c> newJobMap , Map<Id , TR1__Job__c> oldJobMap){

        set<id> jobIdToProcess = new set<id>();
        
        if(oldJobMap != null){
            for(TR1__Job__c job : newJobMap.values()){
                if(job.TR1__Status__c != oldJobMap.get(job.id).TR1__Status__c && job.TR1__Status__c == 'Closed'){
                    jobIdToProcess.add(job.id); 
                }
            }
        }
        //Call future method to update LogicMelon channel List 
        if(jobIdToProcess.size() > 0){
            processJobPostings(jobIdToProcess);
        }
    }
    
    
    @future(callout=true)
    public static void processJobPostings (set<Id> jobList){
        PostToLogicMelonController helperClass = new PostToLogicMelonController(null);
        
        List<PostToLogicMelonController.AdvChannelWrapper> wrapListforAdvCheck =  helperClass.advChannelWrapperList;
            
        for(Id job : jobList){
             
            TR1__Job__c tempJob = new TR1__Job__c(id = job);
            helperClass.getChannelAndPostDetailsForStatus(tempJob);
            wrapListforAdvCheck =  helperClass.advChannelWrapperList;
        }
        
        List<String> channelId = new List<String>();
        if(wrapListforAdvCheck.size()>0){
            for(PostToLogicMelonController.AdvChannelWrapper temp :wrapListforAdvCheck){
                if(temp.ChannelStatus != 'Deleted'){
                    channelId.add(temp.channelId);  
                }
                
            }
            if(channelId.size()>0){
                for(id jobIdset : jobList){
                    TR1__Job__c tempJob = new TR1__Job__c(id = jobIdset);
                    helperClass.job = tempJob;
                    helperClass.processDeleting(tempJob, channelId);
                }   
            }
        }
    }

}
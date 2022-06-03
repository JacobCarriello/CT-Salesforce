public class SplitsManagerController {
    public String fromObj {get; set;}
    public String recordId {get; set;}
    public List<Split__c> listExistingSplits {get; set;}
    public String selectedIndex {get; set;}
    
    private List<Split__c> listExistingSplitsToDelete;
    private Date contractDate;
    
    //Constructor
    public SplitsManagerController(){
        if(ApexPages.currentPage().getParameters().containsKey('from')){
            fromObj = ApexPages.currentPage().getParameters().get('from');
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('recordId')){
            recordId = ApexPages.currentPage().getParameters().get('recordId');
        }
        fetchExistingSplits();
    }
    
    //method to fetch all Existing Splits
    private void fetchExistingSplits(){
        listExistingSplits = new List<Split__c>();
        listExistingSplitsToDelete = new List<Split__c>(); 
        String query = 'Select Job_Lead__r.Contract_In_Timestamp__c, User__c, Role__c, Closing_Report__c, Job_Lead__c, Split_Percentage__c, Name, Procurement__c, RecordTypeId, RecordType.Name ' + 
                        ' from Split__c where ';
        if(fromObj == 'TR1__Closing_Report__c'){
            query += ' Closing_Report__c =:recordId';
        }else if(fromObj == 'TR1__Job_Leads__c'){
            query += ' Job_Lead__c =:recordId';
            //fetch the Job Lead to get the contract data
            for(TR1__Job_Leads__c jobLead : [Select Contract_In_Timestamp__c from TR1__Job_Leads__c
                                            where Id = : recordId limit 1]){
               contractDate = jobLead.Contract_In_Timestamp__c != null ? Date.valueOf(jobLead.Contract_In_Timestamp__c) : null;                                 
            }
        }else{
            query += ' Procurement__c =:recordId';
        }               
        for(Split__c split : Database.query(query)){
            listExistingSplits.add(split);
            listExistingSplitsToDelete.add(split);
        }
    }
    
    //method to add a new row
    public Pagereference addSplitRow(){
        if(fromObj == 'TR1__Closing_Report__c'){
            listExistingSplits.add(new Split__c(Closing_Report__c = recordId, RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('Split__c', 'Closing Report')));
        }else if(fromObj == 'TR1__Job_Leads__c'){
            listExistingSplits.add(new Split__c(Job_Lead__c = recordId, RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('Split__c', 'Contract Lead')));
        }else{
            listExistingSplits.add(new Split__c(Procurement__c = recordId, RecordTypeId = CallListGenerationController.getRecordTypeIdbyName('Split__c', 'Procurement')));
        }
        return null;
    }
    
    //method to remove a row
    public Pagereference removeSplitRow(){
        //system.assert(false, selectedIndex);
        if(selectedIndex != null){
            listExistingSplits.remove(Integer.valueOf(selectedIndex));
        }
        return null;
    }
    
    //cancel actiohn
    public Pagereference cancelAction(){
        return new Pagereference('/' + recordId);
    }
    
    //this method is used for saving the split information
    public Pagereference saveSplitsInformation(){
        Savepoint sp = Database.setSavepoint();
        try{
            Double totalPercentage = 0;
            Set<String> existingUsers = new Set<String>();
            List<Split__c> listToInsert = new List<Split__c>();
            for(Split__c split : listExistingSplits){
                //checking for duplicate users
                if(!existingUsers.contains(split.User__c)){
                    existingUsers.add(split.User__c);
                }else{
                    User user = [Select Name from User where id =: split.User__c limit 1];
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, user.Name + ' : ' +Label.User_already_selected);
                    ApexPages.addMessage(msg);
                    return null;
                }
                //checking for total of 100 percentage
                if(split.Split_Percentage__c != null){
                    totalPercentage += split.Split_Percentage__c;
                }
                Split__c tempSplit = split.clone();
                if(contractDate != null){
                    tempSplit.First_Month_Date__c = contractDate.toStartOfMonth();
                }
                listToInsert.add(tempSplit);
            }
            if(totalPercentage != 100){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Split_Percentage_Total);
                ApexPages.addMessage(msg);
                return null;
            }
            //first we need to delete the existing ones and then recreate the new
            delete listExistingSplitsToDelete;
            
            //now inserting all the rows
            insert listToInsert;
            if(fromObj == 'TR1__Job_Leads__c'){
                insertSplitCreditRecordsForJobLeads(listToInsert);
            }
            return new Pagereference('/' + recordId);
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Split_information_success);
            //ApexPages.addMessage(msg);
        }catch(Exception ex){
            Database.rollback( sp );
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + ' at ' + ex.getLineNumber());
            ApexPages.addMessage(msg);
        }
        return null;
    }
    
    private void insertSplitCreditRecordsForJobLeads(List<Split__c> newSplits){
        //creating the  Split Credit records
        List<Splits_Credit__c> splitCreditsToInsert = new List<Splits_Credit__c>();
        for(Split__c split : [Select Job_Lead__c, Job_Lead__r.Retainer_Amount__c, Job_Lead__r.of_Months__c, 
                                Job_Lead__r.Non_Physician_of_Months__c , Job_Lead__r.Contract_In_Timestamp__c  
                                from Split__c where id in : newSplits AND 
                                Job_Lead__c =: recordId AND Job_Lead__r.Contract_In_Timestamp__c != null]){
            TR1__Job_Leads__c lead = split.Job_Lead__r;
            Date contractDate = Date.valueOf(lead.Contract_In_Timestamp__c);
            if(lead.of_Months__c != null && lead.of_Months__c > 0){
                Date firstDayOfMonth = contractDate.toStartOfMonth();
                for(Integer i = 0; i < lead.of_Months__c ; i++){
                    splitCreditsToInsert.add(ContractLeadTriggerHandler.prepareSplitCreditRecords(split, firstDayOfMonth, 'Physician'));
                    Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                    firstDayOfMonth = lastDayOfMonth.addDays(1);
                }
            }
            
            if(lead.Non_Physician_of_Months__c != null && lead.Non_Physician_of_Months__c > 0){
                Date firstDayOfMonth = contractDate.toStartOfMonth();
                for(Integer i = 0; i < lead.Non_Physician_of_Months__c ; i++){
                    splitCreditsToInsert.add(ContractLeadTriggerHandler.prepareSplitCreditRecords(split, firstDayOfMonth, 'Non-Physician'));
                    Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                    firstDayOfMonth = lastDayOfMonth.addDays(1);
                }
            }
        }
        
        if(splitCreditsToInsert.size() > 0){
            insert splitCreditsToInsert;
        }
    }
}
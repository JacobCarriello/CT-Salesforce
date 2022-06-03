public with sharing class LookupPage1Controller {
    
    public Boolean render1 { get; set; }
    public String expTypeId {get; set;}
    public String crId {get; set;}
    public String contId {get; set;}
    public String expid {get; set;}
    
    List<TR1__Rate__c> records=new List<TR1__Rate__c>();
    
    public String searchvalue { get; set; }
    
    public LookupPage1Controller(){
        //try{
            searchvalue='';
            
            expTypeId = ApexPages.currentPage().getParameters().get('expTypeId');
            crId = ApexPages.currentPage().getParameters().get('crId');
            contId = ApexPages.currentPage().getParameters().get('contId');
            expid = ApexPages.currentPage().getParameters().get('expid');
            system.debug('expid===>'+expid);
            
            if(String.IsNotBlank(searchvalue)){
                render1=true;
                records=returnRate(searchvalue);
            }else{
                render1=true;
                records=returnRate(searchvalue);
            }
      /*  }catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while filtring Rates.');
            ApexPages.addMessage(errorMessage);
        }*/
    }
    
    public List<TR1__Rate__c> getRecords() {
        if(records.size()!=0){return records;}else{return null;}
    }
    
    public PageReference onkeyupAction() {
        searchAction();
        return null;
    }
    
    public PageReference searchAction() {
        render1=true;
        records=returnRate(searchvalue);//[Select Name, Id from TR1__Rate__c where Name like :+searchvalue+'%' order by Name asc];
        if(records.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,'No Records Found'));
        }
        return null;
    }
    
    public List<TR1__Rate__c> returnRate(String searchKey){
        List<TR1__Rate__c> rateList = new List<TR1__Rate__c>();
        
        //String expRecordTypeName ='Lodging';
        System.debug('expTypeId>>'+expTypeId);
        System.debug('contId>>'+contId);
        System.debug('crId>>'+crId);
        /*if(expTypeId != '')
         expRecordTypeName = Schema.SObjectType.TR1__Expense_Report_Detail__c.getRecordTypeInfosById().get(expTypeId).getName();*/
         /* for(TR1__Closing_Report__c cr : [Select Id, (Select Id, Name, TR1__Rate_Type_Name__c 
                                                            From TR1__Rates__r Where TR1__Active__c = true and
                                                            TR1__TimeType__r.Show_in_Community__c = true And Name like :+searchKey+'%' 
                                                            And TR1__TimeType__r.RecordType.DeveloperName = 'Expense_Time_Type'
                                                            order by Name asc )
                                         From TR1__Closing_Report__c 
                                         Where TR1__Person_Placed__c =: contId AND Id =: crId]){  */ 
         for(TR1__Expense_Report__c  er : [Select Id, (Select Id, Name, TR1__Rate_Type_Name__c 
                                                            From TR1__Rates__r Where TR1__Active__c = true
                                                            And TR1__TimeType__r.TR1__Show_in_Community__c = true and Name like :+searchKey+'%' 
                                                            And TR1__TimeType__r.RecordType.DeveloperName = 'Expense_Time_Type'
                                                            order by Name asc )
                                         From TR1__Expense_Report__c 
                                         where Id =: expid]    ){                               
           if(er.TR1__Rates__r.size() >0){
             for(TR1__Rate__c objRates : er.TR1__Rates__r){
                 rateList.add(objRates); 
             } 
           }
           system.debug('**rateList**'+rateList);  
      }
      return rateList;
    }
}
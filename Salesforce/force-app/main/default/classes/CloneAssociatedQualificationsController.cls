public with sharing class CloneAssociatedQualificationsController {
    //global variables
    public Id recordId {get;set;}
    
    String strParentRecordId;
    String objectAPIName;
    List<AssociatedQualificationWrapper> listAssociatedQualifications;
    
    //constructor
    public CloneAssociatedQualificationsController() {
        String strRecordId = ApexPages.currentPage().getParameters().get('Id');
      
        if(strRecordId != null && strRecordId != '') {
            strParentRecordId = ApexPages.currentPage().getParameters().get('ParentId');
            recordId = (Id) strRecordId;
            objectAPIName = recordId.getSObjectType().getDescribe().getName();
        }
    }
    
    //method to fetch all the Associated Qualifications from Parent
    public List<AssociatedQualificationWrapper> getAllAssociatedQualificationsOnParent() {
        listAssociatedQualifications = new List<AssociatedQualificationWrapper>();
      	Set<String> closingReportIdSet = new Set<String>();
      	
        if(strParentRecordId != null && strParentRecordId != '') {
            Set<Id> setAQIdsAlreadyCloned = new Set<Id>();
            String strQuery = queryAllSobjectFields('TR1__Associated_Qualification__c');
            String strQueryExistingAQualifications = 'SELECT Cloned_From__c FROM TR1__Associated_Qualification__c WHERE Cloned_From__c != null';//TR1__TimeType__r.Name
      
            if(objectAPIName == 'TR1__Job__c') {
              strQuery += ' WHERE Account__c = :strParentRecordId';
              strQueryExistingAQualifications += ' AND TR1__Job__c = :recordId';
              
            } else if(objectAPIName == 'TR1__Closing_Report__c') {
              strQuery += ' WHERE TR1__Job__c = :strParentRecordId';
              strQueryExistingAQualifications += ' AND Marriage_Report__c = :recordId';
              
            }
            //Logic to fetch All Closing Reports related to Contact
            else if(objectAPIName == 'Contact'){
            	//fetching closing reports for Contact
            	for(TR1__Closing_Report__c cr : [Select Id from TR1__Closing_Report__c 
            									where TR1__Person_Placed__c =:recordId AND TR1__End_Date__c >: Date.Today()]){
            		closingReportIdSet.add(cr.id);
            	}
            	strQueryExistingAQualifications += ' AND TR1__Contact__c = :recordId';
            	strQuery += ' WHERE Marriage_Report__c IN : closingReportIdSet';
            }
            
            for(TR1__Associated_Qualification__c objAQExisting : Database.query(strQueryExistingAQualifications)) {
                setAQIdsAlreadyCloned.add(objAQExisting.Cloned_From__c);
            }
         
            strQuery += ' AND Id NOT IN :setAQIdsAlreadyCloned ';
      		//system.assert(false, strQuery + '====' + objectAPIName);
            for(TR1__Associated_Qualification__c objAQ : Database.query(strQuery)) {
                listAssociatedQualifications.add(new AssociatedQualificationWrapper(objAQ));
            }
        }    
        return listAssociatedQualifications;
    }
    
    
    //method to clone all the Associated Qualifications to respective Objects
    public PageReference cloneAssociatedQualificationRecords() {
      
        list<TR1__Associated_Qualification__c> listAQ = new list<TR1__Associated_Qualification__c>();
        String strQuery = 'Select Id, Name from TR1__Associated_Qualification__c where ';
        Map<string, integer> mapHasAQName = new Map<string, integer>();
        List<TR1__Associated_Qualification__c> aQsToBeClonedOnJobList = new List<TR1__Associated_Qualification__c>();
          
        Id aQRecordTypeId;
        
        if(objectAPIName == 'TR1__Job__c') {
            strQuery += 'TR1__Job__c = :recordId ';
            aQRecordTypeId = Schema.SObjectType.TR1__Associated_Qualification__c.getRecordTypeInfosByName().get('Job Credential').getRecordTypeId();
            
        }else if(objectAPIName == 'TR1__Closing_Report__c') {
            strQuery += 'Marriage_Report__c = :recordId ';
            aQRecordTypeId = Schema.SObjectType.TR1__Associated_Qualification__c.getRecordTypeInfosByName().get('Marriage Report Credential').getRecordTypeId();
                  
        }else if(objectAPIName == 'Contact') {
        	strQuery += 'TR1__Contact__c = :recordId ';
        	aQRecordTypeId = Schema.SObjectType.TR1__Associated_Qualification__c.getRecordTypeInfosByName().get('Contact Credential').getRecordTypeId();
        } 
        listAQ = database.query(strQuery);
        
        //preparing  map for unique AQ names
        for(TR1__Associated_Qualification__c objAQ : listAQ){
            if(mapHasAQName.containsKey(objAQ.Name)){
                integer cnt = mapHasAQName.get(objAQ.Name);
                mapHasAQName.put(objAQ.Name, cnt+1);
            }else{
                mapHasAQName.put(objAQ.Name, 1);
            }
        } 
        
        //preparing list of AQs to be inserted
        for(AssociatedQualificationWrapper objAQWrapper : listAssociatedQualifications) {
            if(objAQWrapper.isSelected) {
                String strName = objAQWrapper.associatedQualification.Name;
                if(mapHasAQName.containskey(objAQWrapper.associatedQualification.Name)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Associated Qualification with Name '+strName+ ' already exist for the corresponding record.'));
                    return null;
                }
                
                TR1__Associated_Qualification__c objAQClone = objAQWrapper.associatedQualification.clone(false, false, false, false);
                objAQClone.RecordTypeId = aQRecordTypeId; 
                objAQClone.Account__c = null;
                objAQClone.Cloned_From__c = objAQWrapper.associatedQualification.Id;
                    
                if(objectAPIName == 'TR1__Job__c') {
                  objAQClone.TR1__Job__c = recordId;
                  objAQClone.Marriage_Report__c = null;
                  objAQClone.TR1__Contact__c = null;
                      
                }else if(objectAPIName == 'TR1__Closing_Report__c') {
                  objAQClone.TR1__Job__c = null;
                  objAQClone.Marriage_Report__c = recordId;
                  objAQClone.TR1__Contact__c = null;
                  
                }else if(objectAPIName == 'Contact') {
                  objAQClone.TR1__Job__c = null;
                  objAQClone.Marriage_Report__c = null;
                  objAQClone.TR1__Contact__c = recordId;
                  
                }  
                system.debug('Associated Qualification list===='+aQsToBeClonedOnJobList);
                aQsToBeClonedOnJobList.add(objAQClone);
            }
        }
      
        //DML operation
        try {
            if(aQsToBeClonedOnJobList.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Associated Qualification is selected.'));
                return null;
            }
          
            if(!aQsToBeClonedOnJobList.isEmpty()){
                insert aQsToBeClonedOnJobList;
            }
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        return ApexPages.hasMessages() ? null : new pagereference('/'+recordId).setredirect(true);
    }

    
    //querying all fields from sOBject
    private String queryAllSobjectFields(String objectName) {
      
        String strQuery = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        for(String strFieldApiName : objectFields.keySet()) {
            strQuery += strFieldApiName + ',';
        }
        
        strQuery = strQuery.removeEnd(',');
        strQuery += ' FROM ' + objectName;
        system.debug('RateQuery'+strQuery);
        return strQuery;
    }
    
    //cancel method
    public PageReference Cancel(){        
        return new PageReference('/' + recordId).setRedirect(true);       
    }
    
    //wrapper class to hold Qualifications
    public class AssociatedQualificationWrapper {
      
        public TR1__Associated_Qualification__c associatedQualification {get; set;}
        public Boolean isSelected {get; set;}
      
        public AssociatedQualificationWrapper(TR1__Associated_Qualification__c associatedQualification) {
            this.associatedQualification = associatedQualification;
        }
    } 
}
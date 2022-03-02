public without sharing class Utilities {

    // Used to get the contact Id from the current User since Community Users have both.
    public static String GetContactIdFromUser() {
        User u = [Select ContactId from User where Id = :UserInfo.getUserId()];       
        return (u != null ? u.ContactId : null);
    }

    // Used to get the base Salesforce Url from the Page Url.
    public static String GetBaseUrl(){
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return baseUrl;
    }

    public static String GetNGCSHValue(String valueName) {
        NGCSH__c config = NGCSH__c.getOrgDefaults();
        return String.valueOf(config.get(valueName));
    }

    public static String GetRecordTypeNameFromId(String objectAPIName, Id recordTypeId) {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<Id,String> mapofCaseRecordTypeIdandName = new Map<Id,String>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
           mapofCaseRecordTypeIdandName.put(info.getRecordTypeId(), info.getName());
        }

        return mapofCaseRecordTypeIdandName.get(recordTypeId);
    }
}
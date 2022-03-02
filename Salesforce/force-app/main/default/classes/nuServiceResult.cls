public without sharing class nuServiceResult {
    @AuraEnabled
    public object data {get; set;}

    @AuraEnabled
    public object error {get; set;}
}
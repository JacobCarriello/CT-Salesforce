public without sharing class nuCustomProperty {
    @AuraEnabled
    public string propertyName {get; set;}

    @AuraEnabled
    public object propertyValue {get; set;}
}
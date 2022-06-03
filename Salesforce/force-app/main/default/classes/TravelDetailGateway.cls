public without sharing class TravelDetailGateway {
    public static List<TR1__Worker_Comp__c> fetchTravelDetailsForContact(Id contactId){
        List<TR1__Worker_Comp__c> travelDetails = [SELECT Id, RecordTypeId, Vendor_Location__r.Name,
                                                    Vendor_Location__r.Website,
                                                    Check_in_Date__c, Check_out_Date__c,
                                                    Confirmation_Details__c, Address__c,
                                                    Pickup_Date__c, Pickup_Time__c, Return_Date__c,
                                                    Departure_Date__c, Departure_Time_Range__c,
                                                    Departure_City_Location__c, Departure_Airport_Code__c,
                                                    Flight__c, Arrival_Airport_Code__c, Arrival_City_Location__c,
                                                    Arrival_time_range__c, NG_In_Past__c
                                            FROM TR1__Worker_Comp__c
                                            WHERE Contact__c = :contactId
                                            ORDER BY Check_out_Date__c DESC, Return_Date__c DESC, Departure_Date__c DESC];

        system.debug('bw: travelDetails = ' + travelDetails);
        return travelDetails;
    }
}
public with sharing class TravelService {

    @AuraEnabled(cacheable=true)
    public static List<TravelService.TravelEntry> fetchTravelEntriesForEmployee(Id contactId) {
        List<TravelService.TravelEntry> entries = translateDetails(TravelDetailGateway.fetchTravelDetailsForContact(contactId));
        return entries;
    }

    private static List<TravelService.TravelEntry> translateDetails(List<TR1__Worker_Comp__c> details) {
        List<TravelService.TravelEntry> entries = new List<TravelService.TravelEntry>();

        for(TR1__Worker_Comp__c detail: details) {
            string recordType = Utilities.GetRecordTypeNameFromId('TR1__Worker_Comp__c', detail.RecordTypeId);
            if(recordType == 'Lodging') {
                entries.add(new TravelService.TravelEntry(detail.Id,
                                                          detail.Vendor_Location__r.Name,
                                                          detail.Vendor_Location__r.Website,
                                                          detail.Address__c,
                                                          detail.Check_in_Date__c.format(),
                                                          detail.Check_out_Date__c.format(),
                                                          detail.Confirmation_Details__c,
                                                          detail.NG_In_Past__c));
            }
            else if(recordType == 'Rental Car') {
                entries.add(new TravelService.TravelEntry(detail.Id, 
                                                       detail.Vendor_Location__r.Name,
                                                       detail.Vendor_Location__r.Website,
                                                       detail.Address__c, 
                                                       detail.Pickup_Date__c.format(),
                                                       detail.Pickup_Time__c,
                                                       detail.Return_Date__c.format(),
                                                       detail.Confirmation_Details__c,
                                                       detail.NG_In_Past__c));
            }
            else if(recordType == 'Airfare') {
                string departureAirport = detail.Departure_Airport_Code__c + ' - ' + detail.Departure_City_Location__c;
                string arrivalAirport = detail.Arrival_Airport_Code__c + ' - ' + detail.Arrival_City_Location__c;

                entries.add(new TravelService.TravelEntry(detail.Id, 
                                                        detail.Vendor_Location__r.Name,
                                                        detail.Vendor_Location__r.Website, 
                                                        detail.Departure_Date__c.format(),
                                                        detail.Departure_Time_Range__c,
                                                        departureAirport,
                                                        detail.Arrival_time_range__c,
                                                        arrivalAirport,
                                                        detail.Flight__c,
                                                        detail.Confirmation_Details__c,
                                                        detail.NG_In_Past__c));
            }
        }

        return entries;
    }
    
    public class TravelEntry {
        public TravelEntry(string id, 
                         string lodgingName, 
                         string lodgingWebsite, 
                         string lodgingAddress, 
                         string checkInDate,
                         string checkOutDate,
                         string confirmationNumber,
                         boolean inPast) {

            this.Id = id;
            this.RecordType = 'Lodging';
            this.VendorName = lodgingName;
            this.VendorAddress = lodgingAddress;
            this.VendorWebsite = lodgingWebsite;
            this.CheckInDate = checkInDate;
            this.CheckOutDate = checkOutDate;
            this.ConfirmationNumber = confirmationNumber;
            this.InPast = inPast;
        }

        public TravelEntry(string id, 
                         string rentalCompanyName, 
                         string rentalCompanyWebsite, 
                         string rentalCompanyAddress, 
                         string pickupDate,
                         string pickupTime,
                         string returnDate,
                         string confirmationNumber,
                         boolean inPast) {
            
            this.Id = id;
            this.RecordType = 'Rental Car';
            this.VendorName = rentalCompanyName;
            this.VendorAddress = rentalCompanyAddress;
            this.VendorWebsite = rentalCompanyWebsite;
            this.PickupDate = pickupDate;
            this.PickupTime = pickupTime;
            this.ReturnDate = returnDate;
            this.ConfirmationNumber = confirmationNumber;
            this.InPast = inPast;
        }

        public TravelEntry(string id, 
                         string airlineName, 
                         string airlineWebsite, 
                         string departureDate,
                         string departureTime,
                         string departureAirport,
                         string arrivalTime,
                         string arrivalAirport,
                         string flightNumber,
                         string confirmationNumber,
                         boolean inPast) {

            this.Id = id;
            this.RecordType = 'Airfare';
            this.VendorName = airlineName;
            this.VendorWebsite = airlineWebsite;
            this.DepartureDate = departureDate;
            this.DepartureTime = departureTime;
            this.DepartureAirport = departureAirport;
            this.ArrivalTime = arrivalTime;
            this.ArrivalAirport = arrivalAirport;
            this.FlightNumber = flightNumber;
            this.ConfirmationNumber = confirmationNumber;
            this.InPast = inPast;
        }

        @AuraEnabled
        public string Id {get; private set;}
        @AuraEnabled
        public string RecordType {get; private set;}
        @AuraEnabled
        public string VendorName {get; private set;}
        @AuraEnabled
        public string VendorWebsite {get; private set;}
        @AuraEnabled
        public string VendorAddress {get; private set;}
        @AuraEnabled
        public string CheckInDate {get; private set;}
        @AuraEnabled
        public string CheckOutDate {get; private set;}
        @AuraEnabled
        public string ConfirmationNumber {get; private set;}
        @AuraEnabled
        public string PickupDate {get; private set;}
        @AuraEnabled
        public string PickupTime {get; private set;}
        @AuraEnabled
        public string ReturnDate {get; private set;}
        @AuraEnabled
        public string DepartureDate {get; private set;}
        @AuraEnabled
        public string DepartureTime {get; private set;}
        @AuraEnabled
        public string DepartureAirport {get; private set;}
        @AuraEnabled
        public string FlightNumber {get; private set;}
        @AuraEnabled
        public string ArrivalTime {get; private set;}
        @AuraEnabled
        public string ArrivalAirport {get; private set;}
        @AuraEnabled
        public boolean InPast{get; private set;}
    }
}
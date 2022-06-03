@isTest
public class TravelDetailGateway_Tests {
    @isTest
    public static void ftechTravelDetailsForContact_Tests() {
        Test.loadData(Account.sobjectType, 'test_data_accounts');
        Test.loadData(Contact.sobjectType, 'test_data_contacts');
        Test.loadData(TR1__Worker_Comp__c.sobjectType, 'test_data_travel');
        
        //integer acctCount = [SELECT count() FROM Account];
        //integer ctcCount = [SELECT count() FROM Contact];
        List<TR1__Worker_Comp__c> travel = [SELECT Id, Contact__c, Contact__r.LastName FROM TR1__Worker_Comp__c];
        
        //system.assertEquals(10, acctCount);
        //system.assertEquals(1, ctcCount);
        
		List<TR1__Worker_Comp__c> details = TravelDetailGateway.fetchTravelDetailsForContact(travel[0].Contact__c);
        
        system.assertEquals(details.size(), 3);
    }
}
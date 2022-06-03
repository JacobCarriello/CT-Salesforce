/**
 * This test class is used to test the functionality of 'RC_TravelDetailsListingController' apex class.	
*/
@isTest
private class RC_Test_TravelDetailsListing {
    
    private static testMethod void test_RC_TravelDetailsListing() {
        
        //Instantiate the controller class
        RC_TravelDetailsListingController controller = new RC_TravelDetailsListingController();
        
        //Call the class method
        PageReference pg = controller.redirectUnAuthenticatedUser();
        
        //Assert
        System.assertEquals('/Signin',pg.getURL()); 
        User u = RC_UtilityClass.returnCommunityUser();
        Contact con = [SELECT id FROM Contact LIMIT 1];
		
        //Test Data [Travel Detail]
        TR1__Worker_Comp__c travelDetail =  new TR1__Worker_Comp__c(Name='TravelDetail1', Contact__c = con.Id); 
        
        //Insert
        insert travelDetail;

        //Run as a community User
        System.runAs(u)
        {
            pg = controller.redirectUnAuthenticatedUser();
            System.assertEquals(null,pg);  
        }
    }
}
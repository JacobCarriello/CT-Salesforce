/**
 * This test class is used to test the functionality of 'RC_TravelDetails' apex class.	
*/
@isTest
public class RC_Test_TravelDetails {
    
    private static testMethod void test_RC_TravelDetails() {
        
        //Get Travel Details record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'TR1__Worker_Comp__c'];
        
        //Community User 
        User u = RC_UtilityClass.returnCommunityUser();
        Contact con = [SELECT id FROM Contact LIMIT 1];
		
        //List to hold the travel details
        List<TR1__Worker_Comp__c> travelDetails = new List<TR1__Worker_Comp__c>();
        
        //Add item into travelDetails list
        travelDetails.add(new TR1__Worker_Comp__c(Name='TravelDetail1', Contact__c = con.Id, RecordTypeId = recordTypes[0].Id));
        travelDetails.add(new TR1__Worker_Comp__c(Name='TravelDetail2', Contact__c = con.Id, RecordTypeId = recordTypes[1].Id));
        travelDetails.add(new TR1__Worker_Comp__c(Name='TravelDetail3', Contact__c = con.Id, RecordTypeId = recordTypes[2].Id));
        travelDetails.add(new TR1__Worker_Comp__c(Name='TravelDetail4', Contact__c = con.Id, RecordTypeId = recordTypes[3].Id));
        
        //Insert travel Details data
        Insert travelDetails;
        
        //Set the page reference
        PageReference pageRef = Page.TravelDetails;
        test.setCurrentPage(pageRef);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('TravelDetail_Id',travelDetails[0].Id);
        
        //Run as a community User
        System.runAs(u)
        {
        	//Instantiate the controller class
        	RC_TravelDetails controller = new RC_TravelDetails();
            
            System.assert(controller.contact != null);
            ApexPages.currentPage().getParameters().put('TravelDetail_Id',travelDetails[1].Id);
            controller = new RC_TravelDetails();
            
            ApexPages.currentPage().getParameters().put('TravelDetail_Id','');
            controller = new RC_TravelDetails();
           
            //Loop over the messages
            for(ApexPages.Message msg : ApexPages.getMessages()) {
            	System.assertEquals('Associated Travel Detail Missing', msg.getSummary());
            }
        }
    }

}
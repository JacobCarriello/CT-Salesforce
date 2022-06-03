/*
    Author : Veda arvind kaja.
    Date : 6/2/2017
    Description : 
*/
public class UpdateContactFromEvent
{
   public Set<String> createdRecordIds = new Set<String>();
   public List<contact> contsToUpdate = new List<Contact>();
   public Set<String> setContactIds = new Set<String>();
   public List<FeedItem> posts = new List<FeedItem>();
   
   Public UpdateContactFromEvent(){
   
   }
   
   public void UpdateContact(list<event> newevent){
      
      //preparing a set of current inserted record Ids
      for(Event eventObj : newevent){
        if(Schema.SObjectType.Event.getRecordTypeInfosById().get(eventObj.recordtypeid).getname() == 'Pass'){
            createdRecordIds.add(eventObj.id);
        }
      } 
        //show error if Existing event is not 60 days old.
      //W-000492
      for(Event eventObj : newevent){
        Date createdDateObj;
        for(Event oe : [select id,createddate,whoid,recordtypeid 
                            from event 
                            where whoid =: eventObj.whoid 
                            and recordtype.name = 'Pass' AND Id != : createdRecordIds]){
            createdDateObj = date.valueof(oe.createddate);
            Integer noOfDays = createdDateObj.daysBetween(date.today());
            if(noOfDays < Integer.valueof(label.CheckEventDays)){
              eventObj.adderror(label.ErrorOnEventCreation);
            }
         }
         if(!setContactIds.contains(eventObj.whoId)){
             contsToUpdate.add(new Contact(Id = eventObj.whoId, 
                                           Last_Pass_Date__c = date.valueof(eventObj.createddate),
                                           TR1__Secondary_Owner__c = UserInfo.getUserId()));
            setContactIds.add(eventObj.whoId);                     
         }
      }
       

      if(contsToUpdate.size() > 0){
          update contsToUpdate;
          UpdateOnChatter();
          
      }    
    
   }
   
   Public void UpdateOnChatter(){
      CollaborationGroup chatterGroup = [SELECT Id,Name FROM CollaborationGroup WHERE Name = 'Pass Events' LIMIT 1];
      if(chatterGroup != null){
          for(contact contactOnChatter :[select id,TR1__Candidate_Highlights__c,TR1__Primary_Background__c,TR1__State_Area__c,
                                                  TR1__Industry_Experience__c from contact where Id in : contsToUpdate]){
           String status = ' New Pass '+'\n'+
                           'Specialty : '+contactOnChatter.TR1__Primary_Background__c +'\n'+
                           'State : ' +contactOnChatter.TR1__State_Area__c +'\n'+
                           'Industry Experience : '+contactOnChatter.TR1__Industry_Experience__c ; 
           FeedItem post = new FeedItem(
                                   ParentId = chatterGroup.Id,
                                   Title = 'New Pass',
                                   Body = status
                                  );
              posts.add(post);
           }
           insert posts;
           
       }    
   }
   
}
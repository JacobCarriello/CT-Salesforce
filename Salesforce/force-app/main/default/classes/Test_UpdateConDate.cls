@isTest(SeeAllData = true) 
Public class Test_UpdateConDate {
    static testMethod void validate() {
       
       contact con = new contact();
       con.lastname='test';
       con.Medestar_Status__c='Reappt'; 
       con.Assignment_Status__c='Upcoming';
       con.Last_Pass_Date__c = null ;
       insert con;
       
       contact con1 = new contact();
       con1.lastname='test';
       con1.Medestar_Status__c='Reappt'; 
       con1.Assignment_Status__c='Upcoming';
       con1.Last_Pass_Date__c = null ;
       insert con1;
       
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testkajathmade@testorg.com');
       insert u;

       
       UpdateContactFromEvent updateEveCon = new UpdateContactFromEvent();
       
       Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Event; 
       Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
       event eve = new event(Ownerid=u.id,Subject='Call', StartDateTime=datetime.newInstance(2014, 9, 15, 12, 30, 0), 
                   EndDateTime=datetime.newInstance(2014, 9, 15, 13, 30,      0),whoid=con.id,recordtypeid=AccountRecordTypeInfo.get('Pass').getRecordTypeId());
       
       list<event> eventlist = new list<event>();
       eventlist.add(eve);
       
        
       insert eventlist;
       /* 
       event oldEvent = [select id,recordtypeid,whoid from event where 
                          recordtype.name = 'Pass' and id !=:eventlist[0].id];// whoid =: eventlist[0].whoid
                          
       Database.SaveResult result = Database.insert(oldEvent, false);
       System.assertEquals('You can not insert event',result.getErrors()[0].getMessage());                 
       
       con.id = eventlist[0].whoid ; 
       */
      
       con.Last_Pass_Date__c = date.valueof(eve.createddate);
       con.TR1__Secondary_Owner__c = UserInfo.getUserId();
       con.TR1__Candidate_Highlights__c = 'test this functionality';
       con.TR1__State_Area__c = 'Alabama';
       con.TR1__Industry_Experience__c = 'Accounting';
       
       list<contact> Updatecon = new list<contact>(); 
       Updatecon.add(con);
      
       Test.startTest();
       update Updatecon ;
       
       CollaborationGroup chatterGroup = [SELECT Id,Name FROM CollaborationGroup WHERE Name = 'Pass Events' LIMIT 1];
       String status = ' New Pass ' + con.TR1__Candidate_Highlights__c +'  '+ con.TR1__State_Area__c +'  '
                                     +con.TR1__Industry_Experience__c ;
       FeedItem post = new FeedItem(
                               ParentId = chatterGroup.Id,
                               Title = 'New Pass',
                               Body = status
                              );
           
       insert post; 
       
       updateEveCon.UpdateContact(eventlist);
       Test.stopTest();
       System.assertEquals(date.valueof(eve.createddate),con.Last_Pass_Date__c);
    }
}
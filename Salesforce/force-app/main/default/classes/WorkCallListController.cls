global class WorkCallListController{
    public String callListId                                                    {get; set;}
    public TR1__Call_List__c callList                                           {get; set;}
    public Integer recordLimit                                                  {set; get;}
    public integer total_size                                                   {set; get;}
    public Map<Id,TR1__Call_List_Member__c> callListMemberMap ;
    public List<ContactWrapper> contactWrapperList                              {get; set;}
    public list<SelectOption> pageNumberList                                    {get; set;} 
    public Integer pageNumber                                                   {get; set;}
    public List<Schema.FieldSetMember> fieldSetContact                          {get; set;}

    public WorkCallListController(ApexPages.StandardController controller){
        callListId = controller.getId();
        callListMemberMap = new Map<Id,TR1__Call_List_Member__c>();
        pageNumberList = new List<SelectOption>();
        contactWrapperList = new List<ContactWrapper>();
        fieldSetContact = new List<Schema.FieldSetMember>();
        fieldSetContact = SObjectType.Contact.FieldSets.getMap().get(Label.Contact_On_Call_List).getFields();
    }

    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                recordLimit = 10;
                Set<String> contacts = new Set<String>();
                for(TR1__Call_List_Member__c member : [SELECT TR1__Contact__c,TR1__Call_List__r.Name FROM TR1__Call_List_Member__c WHERE TR1__Call_List__c =: callListId]){
                    callList = member.TR1__Call_List__r;
                    contacts.add(member.TR1__Contact__c);
                }
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT Id FROM Contact WHERE Id IN :contacts ORDER BY Name ASC '));
                setCon.setPageSize(recordLimit);
                total_size = setCon.getResultSize();
                for(Integer i = 1 ; i <= getTotalPages() ; i++) {
                    pageNumberList.add(new SelectOption(i + '' ,i + ''));
                }
                pageNumber = setCon.getPageNumber();
            }
            return setCon;
        }set;
    }

    public List<ContactWrapper> getContactWrapper() {
        Map<String,TR1__Call_List_Member__c> contactIdCallListMemberMap = new Map<String,TR1__Call_List_Member__c>();
        Set<String> contacts = new Set<String>();
        for(Contact con : (List<Contact>)setCon.getRecords()){
           contacts.add(con.Id);
        }
        for(TR1__Call_List_Member__c member : [SELECT Id, Do_Not_Contact__c, TR1__Contact__c FROM TR1__Call_List_Member__c WHERE TR1__Call_List__c =: callListId AND TR1__Contact__c IN :contacts]){
            contactIdCallListMemberMap.put(member.TR1__Contact__c, member);
        }
        pageNumber = setCon.getPageNumber();
        for(ContactWrapper wrapper : contactWrapperList) {
            if(wrapper.callListMember.Do_Not_Contact__c) {
                callListMemberMap.put(wrapper.callListMember.Id, wrapper.callListMember);
            }
        }
        for(ContactWrapper wrapper : contactWrapperList) {
            if(callListMemberMap.containsKey(wrapper.callListMember.id)) {
                callListMemberMap.get(wrapper.callListMember.id).Do_Not_Contact__c = wrapper.callListMember.Do_Not_Contact__c;
            }
        }
        String queryString = 'SELECT Id' ;
        for(Schema.FieldSetMember objField : fieldSetContact) {
            queryString += ','+ objField.getFieldPath();
        }
        queryString += ' ,(Select Id, RecordTypeId, WhoId, WhatId, Subject, ActivityDate, OwnerId, Owner.Name, Description, Status__c From Tasks order by ActivityDate desc limit 5)' +
                    ' From Contact where Id in :contacts ORDER BY Name ASC ';
        contactWrapperList = new List<ContactWrapper>();
        for(Contact contact : Database.Query(queryString)) {
            contactWrapperList.add(new ContactWrapper(contact, contact.Tasks, contactIdCallListMemberMap.get(contact.Id)));
        }
        for(ContactWrapper wrapper : contactWrapperList) {
            if(callListMemberMap.containsKey(wrapper.callListMember.id) && callListMemberMap.get(wrapper.callListMember.id).Do_Not_Contact__c) {
                wrapper.callListMember.Do_Not_Contact__c = true;
            }
        }
        return contactWrapperList;
    }

    public void refreshPageSize() {
        pageNumberList = new List<SelectOption>();
        setCon.setPageSize(recordLimit);
        for(Integer i = 1 ; i <= getTotalPages() ; i++) {
            pageNumberList.add(new SelectOption(i + '' ,i + ''));
        }
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, recordLimit) > 0) {
            return total_size/recordLimit + 1;
        } else {
            return (total_size/recordLimit);
        }
     }

    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public void retrieveRecordsBasedOnPageNumber() {
        setCon.setPageNumber(pageNumber);
    }

    public void save() {
        for(ContactWrapper wrapper : contactWrapperList) {
            if(callListMemberMap.containsKey(wrapper.callListMember.id)) {
                callListMemberMap.get(wrapper.callListMember.id).Do_Not_Contact__c = wrapper.callListMember.Do_Not_Contact__c;
            } else if(wrapper.callListMember.Do_Not_Contact__c) {
                callListMemberMap.put(wrapper.callListMember.Id, wrapper.callListMember);
            }
        }
        if(!callListMemberMap.isEmpty()) {
            update callListMemberMap.values();
        }
    }
    
    public class ContactWrapper{
        public transient Contact contact                        {get; set;}
        public transient List<ActivityWrapper> activities       {get; set;}
        public transient List<Task> tasks                       {get; set;}
        public TR1__Call_List_Member__c callListMember          {get; set;}
        
        public ContactWrapper(Contact contact, List<Task> tasks, TR1__Call_List_Member__c callListMember){
            this.contact = contact;
            activities = new List<ActivityWrapper>();
            this.tasks = tasks;
            this.callListMember = callListMember;
            for(Task tsk : tasks){
                activities.add(new ActivityWrapper(tsk.subject, tsk.Description, tsk.ActivityDate, tsk.Owner.Name));
            }    
        }
    }
    
    public class ActivityWrapper{
        public String subject                       {get; set;}
        public String comments                      {get; set;}
        public Date dueDate                         {get; set;}
        public String assignedTo                    {get; set;}
        
        public ActivityWrapper(String subject, String comments, Date dueDate, String assignedTo){
            this.subject = subject;
            this.comments = comments;
            this.dueDate = dueDate;
            this.assignedTo = assignedTo;
        }
    }
}
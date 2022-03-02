trigger CallListMemberTrigger on TR1__Call_List_Member__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        //call handler.after method
        CallListMemberTriggerHandler.onBeforeInsert(Trigger.new);
    }
}
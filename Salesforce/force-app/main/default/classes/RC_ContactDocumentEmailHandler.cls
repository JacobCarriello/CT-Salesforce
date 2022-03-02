global class RC_ContactDocumentEmailHandler implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String conid = email.subject;
        if(conid.contains(':')){
                conid =email.subject.Split(': ')[1];
            }
            if(conid!=null){
                List<TR1__ContactDocument__c> condoc = [Select Id,Name, TR1__isDefault__c  from TR1__ContactDocument__c where TR1__Contact__c =:conid  order by createddate DESC limit 1];
                If(!condoc.IsEmpty()){
                condoc[0].TR1__Convert_to_Content_Document__c = true;
                condoc[0].TR1__Delete_Attachment__c = true;
                update condoc;
                }
            }
        return result;
    }


}
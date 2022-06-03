@isTest
private  class EmailServicesTest {
    @isTest static void testEmailServices() {
        Map<String, Blob> attachments = new Map<String, Blob>();
        attachments.put('Attachment', Blob.valueOf('Test content'));
        EmailServices.sendSingleEmail('test@exonos.us', 'Errors', new String[]{'javier@exonos.us'}, new String[]{'javier@exonos.us'}, 'Salesforce Test Email', 'Salesforce Test Email', attachments);
        System.assertNotEquals(0, Limits.getEmailInvocations(), 'Assert failed: No email invocations');
    }
}
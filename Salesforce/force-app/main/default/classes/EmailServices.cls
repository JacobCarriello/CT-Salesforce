public class EmailServices {

    public static void sendErrorEmail(String htmlBody) {
        //Call the email recipen to recibe the errors emails
        List<error_email__mdt> errorEmail = [SELECT email__c FROM error_email__mdt];

        EmailServices.sendSingleEmail('errors@thenuagegroup.com', 'Errors', new String[]{errorEmail[0].email__c}, null, 'Salesforce Error Ocurred', htmlBody);
    }

    public static void sendSingleEmail(String fromAddress, String fromName, String[] toAddresses, String[] ccAddresses, String subject, String htmlBody) {
        sendSingleEmail(fromAddress, fromName, toAddresses, ccAddresses, subject, htmlBody, null);
    }

    public static void sendSingleEmail(String fromAddress, String fromName, String[] toAddresses, String[] ccAddresses, String subject, String htmlBody, Map<String, Blob> attachments) {
        System.debug('Sending email. Subject: ' + subject);
        System.debug('Body: ' + htmlBody);
        if (Limits.getEmailInvocations() <= Limits.getLimitEmailInvocations()) {
            // First, reserve email capacity for the current Apex transaction to ensure
            // that we won't exceed our daily email limits when sending email after
            // the current transaction is committed.
            Messaging.reserveSingleEmailCapacity(2);

            // Processes and actions involved in the Apex transaction occur next,
            // which conclude with sending a single email.

            // Now create a new single email message object
            // that will send out a single email to the addresses in the To, CC & BCC list.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            if (ccAddresses != null) {
                mail.setCcAddresses(ccAddresses);
            }

            // Specify the address used when the recipients reply to the email.
            mail.setReplyTo(fromAddress);

            // Specify the name used as the display name.
            mail.setSenderDisplayName(fromName);

            // Specify the subject line for your email address.
            mail.setSubject(subject);

            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);

            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);

            // Specify the text content of the email.
            mail.setPlainTextBody(htmlBody);

            mail.setHtmlBody(htmlBody);

            if (attachments != null) {
                List<Messaging.EmailFileAttachment> listAttc = new List<Messaging.EmailFileAttachment>();
                for (String attachmentName : attachments.keySet()) {
                    Messaging.EmailFileAttachment attc = new Messaging.EmailFileAttachment();
                    attc.setFileName(attachmentName);
                    attc.setBody(attachments.get(attachmentName));
                    listAttc.add(attc);
                }
                mail.setFileAttachments(listAttc);
            }

            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } else {
            System.debug('There have been already ' + Limits.getLimitEmailInvocations() + ' email invocations for this run. Can not send more emails.');
        }
    }
}
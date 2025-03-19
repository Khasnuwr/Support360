/**
 * @description       : Email Helper class to send email with CSV attachment.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-07-2025
 * @last modified by  : Arif Mahmud
**/
public with sharing class EmailHelper {
    /**
    * @description This Method sends an email with a CSV attachment to the recipient.
    * @author Arif Mahmud | 02-07-2025 
    * @param recipientEmail 
    * @param subject 
    * @param body 
    * @param csvContent 
    **/
    public static void sendEmailWithCSV(String recipientEmail, String subject, String body, String csvContent) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{recipientEmail});
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        // Converts CSV to Attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Cases_Due_Yesterday.csv');
        attachment.setBody(Blob.valueOf(csvContent));
        attachment.setContentType('text/csv');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});

        // Sending Email
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}
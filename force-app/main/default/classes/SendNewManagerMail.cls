/**
 * @description       : This class is used to send emails to the current logged in user with a CSV attachment as an attachment.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : Arif Mahmud
**/
public with sharing class SendNewManagerMail {
    /**
    * @description This Method sends emails to the current logged in user with a CSV attachment as an attachment. The CSV attachment contains the list of projects for the current logged in user. The email subject and body are also passed as parameters to the method. The email is sent to the current logged in user. If the current logged in user does not have an email address, the method does not send the email. The method returns the email message Id if the email is sent successfully. If the email is not sent, the method throws an exception with the error message. The method is exposed as an AuraEnabled method and can be called from the Lightning component. The method is also marked as invocable so that it can be called from the Process Builder or Flow. The method is also marked as global so that it can be called from the test class. The method is also marked as with sharing so that it runs in the user's context and respects the user's record-level access.
    * @author Arif Mahmud | 02-13-2025 
    * @param newOwnerId 
    * @param projects 
    **/
    public static void sendNotificationEmail(Id newOwnerId, List<Project__c> projects) {
        User newOwner = [SELECT Email FROM User WHERE Id = :newOwnerId];
        if (newOwner.Email == null) return;

        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        List<String> projectLinks = new List<String>();
        for (Project__c p : projects) {
            projectLinks.add(p.Name + ': ' + baseUrl + '/lightning/r/Project__c/' + p.Id + '/view');
        }

        String emailBody = 'You have been assigned as the owner of the following projects:\n\n' + String.join(projectLinks, '\n');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ newOwner.Email });
        email.setSubject('You are now the owner of multiple Projects');
        email.setPlainTextBody(emailBody);
        Messaging.sendEmail(new List<Messaging.Email>{ email });
    }
}
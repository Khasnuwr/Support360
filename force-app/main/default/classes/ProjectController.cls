/**
 * @description       : ProjectController class is used to handle the business logic for the Project__c object.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-18-2025
 * @last modified by  : Arif Mahmud
**/
public with sharing class ProjectController {
    /**
    * @description This Method returns the list of users except the current logged in user.
    * @author Arif Mahmud | 02-13-2025 
    * @return List<User> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [SELECT Id, Name FROM User WHERE IsActive = true AND Id != :UserInfo.getUserId()];
    }

    /**
    * @description This Method returns the current logged in user or return null. It also accepts the search keyword to filter the projects by name or description. If the search keyword is empty, it returns all the projects for the current logged in user sorted by the project name. If the search keyword is not empty, it returns the projects that match the search keyword sorted by the project name. The method is exposed as an AuraEnabled method and can be called from the Lightning component. The method is also marked as invocable so that it can be called from the Process Builder or Flow. The method is also marked as global so that it can be called from the test class. The method
    * @author Arif Mahmud | 02-13-2025 
    * @param projectIds 
    * @param newOwnerId 
    * @param sendEmail 
    * @return String 
    **/
    @AuraEnabled
    public static String updateProjectOwners(List<Id> projectIds, Id newOwnerId, Boolean sendEmail) {
            system.debug(projectIds );
            system.debug(newOwnerId );
            List<Project__c> projectsToUpdate = [SELECT Id, Name,OwnerId FROM Project__c WHERE Id IN :projectIds];
       

            for (Project__c p : projectsToUpdate) {
                p.OwnerId = newOwnerId;
            }
      
            system.debug(projectsToUpdate );
            update projectsToUpdate;
        

            // If Send Notification Mail Checked in Lwc Component then send email to the new owner
            if (sendEmail) {
                // Send email to the new Manager
                SendNewManagerMail.sendNotificationEmail(newOwnerId, projectsToUpdate);
            }

            return newOwnerId.toString();
       
        
    }

}
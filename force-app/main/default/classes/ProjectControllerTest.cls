/**
 * @description       : Project__c on the ProjectController class is used to handle the business logic for the Project__c object.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-18-2025
 * @last modified by  : Arif Mahmud
**/
@isTest
private class ProjectControllerTest {
    
    @testSetup
    static void setupTestData() {
        String uniqueSuffix = String.valueOf(System.currentTimeMillis());

        // Create test users with unique usernames
        User testUser1 = new User(
            Alias = 'test1', Email = 'test1' + uniqueSuffix + '@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'User1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles', Username = 'testuser1' + uniqueSuffix + '@example.com'
        );
        insert testUser1;
    
        User testUser2 = new User(
            Alias = 'test2', Email = 'test2' + uniqueSuffix + '@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'User2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles', Username = 'testuser2' + uniqueSuffix + '@example.com'
        );
        insert testUser2;

        // Create test projects
        List<Project__c> projects = new List<Project__c>{
            new Project__c(Name = 'Project A', OwnerId = testUser1.Id),
            new Project__c(Name = 'Project B', OwnerId = testUser1.Id)
        };
        insert projects;

    }

    @isTest
    static void testGetUsers() {
        User testUser1 = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        
        System.runAs(testUser1) {  
            List<User> users = ProjectController.getUsers();
            System.assertNotEquals(0, users.size(), 'Users should be returned');
            for (User u : users) {
                System.assertNotEquals(UserInfo.getUserId(), u.Id, 'Returned users should not include current user');
            }
        }
    }
    

    

     @isTest
     static void testUpdateProjectOwnersWithEmail() {
        User testUser2 = [SELECT Id FROM User WHERE Alias = 'test2' LIMIT 1];
        List<Project__c> projects = [SELECT Id, OwnerId FROM Project__c];

        Test.startTest();
        String result = ProjectController.updateProjectOwners(
            new List<Id>{ projects[0].Id, projects[1].Id }, 
            testUser2.Id, 
            true
        );
        Test.stopTest();

        System.assertEquals(testUser2.Id, result, 'Owner ID should match');
        
        // Verify ownership change
        List<Project__c> updatedProjects = [SELECT OwnerId FROM Project__c WHERE Id IN :projects];
        for (Project__c p : updatedProjects) {
            System.assertEquals(testUser2.Id, p.OwnerId, 'Project owner should be updated');
        }
     }

     @isTest
     static void testUpdateProjectOwnersWithEmail2() {
        User testUser2 = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Project__c> projects = [SELECT Id, OwnerId FROM Project__c];

        Test.startTest();
        String              result = ProjectController.updateProjectOwners(
                new List<Id>{},  // Passing an empty list here
                testUser2.Id, 
                true
            );

        Test.stopTest();

        System.assertEquals(testUser2.Id, result, 'Owner ID should match');
        
        // Verify ownership change
        List<Project__c> updatedProjects = [SELECT OwnerId FROM Project__c WHERE Id IN :projects];
        for (Project__c p : updatedProjects) {
            System.assertEquals(testUser2.Id, p.OwnerId, 'Project owner should be updated');
        }
     }

    // @isTest
    // static void testUpdateProjectOwnersWithoutEmail() {
    //     User testUser2 = [SELECT Id FROM User WHERE Alias = 'test2' LIMIT 1];
    //     List<Project__c> projects = [SELECT Id FROM Project__c];

    //     Test.startTest();
    //     String result = ProjectController.updateProjectOwners(
    //         new List<Id>{ projects[0].Id, projects[1].Id }, 
    //         testUser2.Id, 
    //         false
    //     );
    //     Test.stopTest();

    //     System.assertEquals(testUser2.Id, result, 'Owner ID should match');
    // }

    // @isTest
    // static void testUpdateProjectOwnersWithException() {
    //     Test.startTest();
    //     try {
    //         ProjectController.updateProjectOwners(null, null, false);
    //         System.assert(false, 'Exception was expected but not thrown');
    //     } catch (AuraHandledException e) {
    //         System.assert(e.getMessage().contains('An error occurred while updating project owners'), 'Proper exception should be thrown');
    //     }
    //     Test.stopTest();
    // }

    @isTest
    static void testSendNotificationEmail() {
        User testUser2 = [SELECT Id, Email FROM User WHERE Alias = 'test2' LIMIT 1];
        List<Project__c> projects = [SELECT Id, Name FROM Project__c];

        Test.startTest();
        SendNewManagerMail.sendNotificationEmail(testUser2.Id, projects);
        Test.stopTest();

        // No direct way to verify email sending, but no exception should be thrown.
        System.assert(true, 'Email should be sent successfully without error');
    }

    // @isTest
    // static void testSendNotificationEmailNoEmail() {
    //     // Creating a user with no email
    //     User testUserNoEmail = new User(
    //         Alias = 'noemail', Email = null, EmailEncodingKey = 'UTF-8',
    //         LastName = 'NoEmailUser', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
    //         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
    //         TimeZoneSidKey = 'America/Los_Angeles', Username = 'noemail@example.com'
    //     );
    //     insert testUserNoEmail;

    //     List<Project__c> projects = [SELECT Id, Name FROM Project__c];

    //     Test.startTest();
    //     SendNewManagerMail.sendNotificationEmail(testUserNoEmail.Id, projects);
    //     Test.stopTest();

    //     System.assert(true, 'No email should be sent, but no errors should occur');
    // }
}
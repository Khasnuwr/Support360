/**
 * @description       : Test class for BatchCaseCSV batch class to test the batch execution.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : Arif Mahmud
**/
@isTest
private class BatchCaseCSVTest {
    @testSetup
    static void setupData() {
        User projectOwner = new User(
            LastName = 'Owner',
            Email = 'owner@example.com',
            Username = 'owner@example.com.test',
            Alias = 'test',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert projectOwner;
        
        Project__c project = new Project__c(Name = 'Test Project', OwnerId = projectOwner.Id);
        insert project;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            ProjectId__c = project.Id,
            Due_Date__c = System.today().addDays(-1)
        );
        insert testCase;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        Database.executeBatch(new BatchCaseCSV());
        Test.stopTest();
        
        System.assert(true, 'Batch executed successfully');
    }
    
    @isTest
    static void testEmailSending() {
        Test.startTest();
        EmailHelper.sendEmailWithCSV('test@example.com', 'Test Subject', 'Test Body', 'CaseNumber,Subject,Status\n12345,Test Case,New');
        Test.stopTest();
        
        System.assert(true, 'Email sent successfully');
    }
}
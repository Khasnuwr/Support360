/**
 * @description       : Invocable method to run the Case CSV Batch. Test class to test the invocable method.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-18-2025
 * @last modified by  : Arif Mahmud
**/
@isTest
private class BatchCaseCSVInvokerTest {
    @testSetup
    static void setupData() {
        // Insert test Cases (if required by BatchCaseCSV logic)
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(Subject = 'Test Case ' + i, Status = 'Open'));
        }
        insert cases;
    }

    @isTest
    static void testRunBatch() {
        Test.startTest();
        
        // Call the invocable method
        BatchCaseCSVInvoker.runBatch();
        
        // Verify that a batch job has been submitted
        Integer batchJobsCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status IN ('Processing', 'Queued')];
        System.assert(batchJobsCount > 0, 'Batch job was not enqueued properly');
        
        Test.stopTest();
    }
}
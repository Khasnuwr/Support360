/**
 * @description       : Invocable method to run the Case CSV Batch.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-07-2025
 * @last modified by  : Arif Mahmud
**/
public with sharing class BatchCaseCSVInvoker {
    /**
    * @description This Method runs the Case CSV Batch.
    * @author Arif Mahmud | 02-07-2025 
    **/
    @InvocableMethod(label='Run Batch Case CSV' description='Executes the Case CSV Batch')
    public static void runBatch() {
        Database.executeBatch(new BatchCaseCSV());
    }
}
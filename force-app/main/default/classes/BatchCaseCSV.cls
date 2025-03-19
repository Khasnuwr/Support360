/**
 * @description       : Batch class to generate a CSV of cases due yesterday and send it as an attachment to the project owner.
 * @author            : Arif Mahmud
 * @group             : 
 * @last modified on  : 02-07-2025
 * @last modified by  : Arif Mahmud
 **/
global class BatchCaseCSV implements Database.Batchable<sObject>, Database.Stateful {
    
    private Map<Id, List<Case>> ownerCasesMap = new Map<Id, List<Case>>();
    private Set<Id> projectIds = new Set<Id>();

    /**
    * @description This Method starts the batch job.
    * @author Arif Mahmud | 02-07-2025 
    * @param context 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, Subject, Status, ProjectId__c, ProjectId__r.Name, Due_Date__c
            FROM Case 
            WHERE Due_Date__c = LAST_N_DAYS:1 
            AND ProjectId__c != NULL
        ]);
    }

    /**
    * @description This Method executes the batch job and groups cases by project owner.
    * @author Arif Mahmud | 02-07-2025 
    * @param context 
    * @param caseList 
    **/
    global void execute(Database.BatchableContext context, List<Case> caseList) {
        for (Case c : caseList) {
            projectIds.add(c.ProjectId__c);
        }

        // Query Project Owners
        Map<Id, Id> projectOwnerMap = new Map<Id, Id>();
        for (Project__c project : [SELECT Id, OwnerId FROM Project__c WHERE Id IN :projectIds]) {
            projectOwnerMap.put(project.Id, project.OwnerId);
        }

        // Group Cases by Project Owner
        for (Case c : caseList) {
            Id ownerId = projectOwnerMap.get(c.ProjectId__c);
            if (ownerId != null) {
                if (!ownerCasesMap.containsKey(ownerId)) {
                    ownerCasesMap.put(ownerId, new List<Case>());
                }
                ownerCasesMap.get(ownerId).add(c);
            }
        }
    }

    /**
    * @description This Method finishes the batch job and sends emails to project owners with the CSV attachment.
    * @author Arif Mahmud | 02-07-2025 
    * @param context 
    **/
    global void finish(Database.BatchableContext context) {
        // Fetch emails of all Project Owners
        Map<Id, String> ownerEmailMap = new Map<Id, String>();
        for (User userRecord : [SELECT Id, Email FROM User WHERE Id IN :ownerCasesMap.keySet()]) {
            ownerEmailMap.put(userRecord.Id, userRecord.Email);
        }

        // Send emails grouped by Project Owner
        for (Id ownerId : ownerCasesMap.keySet()) {
            String ownerEmail = ownerEmailMap.get(ownerId);
            if (ownerEmail != null) {
                List<Case> cases = ownerCasesMap.get(ownerId);
                String csvData = generateCSV(cases);
                
                System.debug('Sending Email to: ' + ownerEmail);
                System.debug('CSV Data: \n' + csvData);

                // Send Email Notification
                EmailHelper.sendEmailWithCSV(ownerEmail, 'Greetings,\nCases attached in csv file Crosssed Due Dates Yesterday', 'Please find attached the list of cases.\n\nBest Regards\nSupport 360', csvData);
            }
        }
    }

    /**
    * @description This Method generates a CSV string from the list of cases.
    * @author Arif Mahmud | 02-07-2025 
    * @param cases 
    * @return String 
    **/
    private String generateCSV(List<Case> cases) {

        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        String csvData = 'Case Number,Subject,Status,Project,Due Date,Case Link\n';
        
        for (Case c : cases) {
            String caseLink = baseUrl + '/lightning/r/Case/' + c.Id + '/view';
            csvData += c.CaseNumber + ',' + c.Subject + ',' + c.Status + ',' + c.ProjectId__r.Name  + ',' + c.Due_Date__c + ',' + caseLink + '\n';
        }

        return csvData;
    }
}
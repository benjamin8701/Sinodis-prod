@isTest
public class CN_Case_Upsert_To_Mg_Handler_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    static void testBeforeUpdateHandle() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
        account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
        update account;

        Case casetest = new Case();
        casetest.CN_MG_Case_Id__c = '1';
        casetest.accountId = account.Id;
        
        insert casetest;

        Case cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status from Case WHERE CN_MG_Case_Id__c = '1'];
        cases.Status = 'Assigned';
        cases.Origin = 'E-Commerce';
        update cases;

        Id CSQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'CN_CS_Queue'].Id;
        cases.OwnerId = CSQueueId;
        update cases;
    }
}
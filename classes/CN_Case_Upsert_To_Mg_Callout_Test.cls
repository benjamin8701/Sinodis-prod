@isTest
public class CN_Case_Upsert_To_Mg_Callout_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    static void testSendMgCaseStatus() {
        TestDataFactory testDataFactory = new TestDataFactory();
        testDataFactory.makeTalendSetting();
        Case casetest = new Case();
        casetest.CN_MG_Case_Id__c = '1';
        casetest.Status = 'Closed';
        casetest.CN_Need_Send_MG_Flag__c = 1;
        casetest.CN_Actual_Return_Consistent_Status__c = true;
        casetest.CN_CS_Feedback__c = 'test';
        insert casetest;

        Case casetest1 = new Case();
        casetest1.CN_MG_Case_Id__c = '2';
        casetest1.Status = 'Closed';
        casetest1.CN_Need_Send_MG_Flag__c = 1;
        casetest1.CN_Actual_Return_Consistent_Status__c = false;
        casetest1.CN_CS_Feedback__c = 'test';
        insert casetest1;

        List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_Need_Send_MG_Flag__c = 1]; 

        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        
        Test.startTest();
        CN_Case_Upsert_To_Mg_Callout.sendMgCaseStatus(cases);
        Test.stopTest();
        Database.executeBatch(new CN_Case_Upsert_To_Mg_Batch());   
        
        // System.assertEquals(1, sendSuccess.size());
    }

    @isTest
    static void testSendMgCaseStatus503() {
        TestDataFactory testDataFactory = new TestDataFactory();
        Case casetest = new Case();
        casetest.CN_MG_Case_Id__c = '1';
        casetest.Status = 'Closed';
        casetest.CN_Need_Send_MG_Flag__c = 1;
        casetest.CN_Actual_Return_Consistent_Status__c = true;
        casetest.CN_CS_Feedback__c = 'test';
        insert casetest;

        List<Case> cases = [select Id,CaseNumber,CN_MG_Case_Id__c,Status,CN_Actual_Return_Consistent_Status__c,CN_CS_Feedback__c from Case WHERE CN_Need_Send_MG_Flag__c = 1]; 
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        
        Test.startTest();
        CN_Case_Upsert_To_Mg_Callout.sendMgCaseStatus(cases);
        Test.stopTest();
        Database.executeBatch(new CN_Case_Upsert_To_Mg_Batch());   
    }
}
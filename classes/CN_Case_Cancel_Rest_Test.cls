@isTest
public class CN_Case_Cancel_Rest_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
        Case casetest = new Case();
        casetest.CN_MG_Case_Id__c = '1';
        casetest.Status = 'New';
        casetest.CN_Need_Send_MG_Flag__c = 1;
        casetest.CN_Actual_Return_Consistent_Status__c = true;
        casetest.CN_CS_Feedback__c = 'test';
        insert casetest;
    }
    @isTest
    static void testPostMethod() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CancelComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": "1"}]}');
        RestContext.request = request;
        RestContext.response= res;
        Test.startTest();
        CN_Case_Cancel_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostEmptyData() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CancelComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{}');
        RestContext.request = request;
        RestContext.response= res;
        Test.startTest();
        CN_Case_Cancel_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CancelComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": null}]}');
        RestContext.request = request;
        RestContext.response= res;
        Test.startTest();
        CN_Case_Cancel_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase1() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CancelComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{}]}');
        RestContext.request = request;
        RestContext.response= res;
        Test.startTest();
        CN_Case_Cancel_Rest.post();
        Test.stopTest();
    }
}
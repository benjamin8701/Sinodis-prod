@isTest
public with sharing class CN_Case_NP_Insert_Rest_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    static void testPostMethod() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/NPComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas":[{"mgCaseId":"123458","complaintDate":"2023-08-14 04:00:00.000 0000","origin" : "E-Commerce","accountId": "95","recordType": "Order Dependent","contactId": "371","description" : "description"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_NP_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostEmptyData() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/NPComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_NP_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/NPComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas":[{"complaintDate":"2023-08-14 04:00:00.000 0000","origin" : "E-Commerce","accountId": "95","recordType": "Order Dependent","contactId": "371","description" : "description"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_NP_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase1() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/NPComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas":[{"mgCaseId":null,"complaintDate":"2023-08-14 04:00:00.000 0000","origin" : "E-Commerce","accountId": "95","recordType": "Order Dependent","contactId": "371","description" : "description"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_NP_Insert_Rest.post();
        Test.stopTest();
    }
}
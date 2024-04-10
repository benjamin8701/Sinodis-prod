@isTest
public class CN_Case_Insert_Rest_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    static void testPostMethod() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": "213","complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": "Other","productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","otherProblemImages": "https://dev2-magento.sinodis.com/media/payment_certificate/files/71851705053539_cat.jpg","sapBatch":"12345&67890","sapBatchNumbers": [{"sapBatchNumber": "12345","number": "0.88","unit": "kg","productionDate": "2023-08-21","expiryDate":"2023-09-21"}],"wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostEmptyData() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": "999","complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": null,"productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","otherProblemImages": "https://dev2-magento.sinodis.com/media/payment_certificate/files/71851705053539_cat.jpg","sapBatch":"12345&67890","sapBatchNumbers": [{"sapBatchNumber": "12345","number": "0.88","unit": "kg","productionDate": "2023-08-21","expiryDate":"2023-09-21"}],"wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase1() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": "Other","productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","otherProblemImages": "https://dev2-magento.sinodis.com/media/payment_certificate/files/71851705053539_cat.jpg","sapBatch":"12345&67890","sapBatchNumbers": [{"sapBatchNumber": "12345","number": "0.88","unit": "kg","productionDate": "2023-08-21","expiryDate":"2023-09-21"}],"wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        // request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": "213","complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": "Other","productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","sapBatch":"12345&67890","wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase2() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": null,"complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": "Other","productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","otherProblemImages": "https://dev2-magento.sinodis.com/media/payment_certificate/files/71851705053539_cat.jpg","sapBatch":"12345&67890","sapBatchNumbers": [{"sapBatchNumber": "12345","number": "0.88","unit": "kg","productionDate": "2023-08-21","expiryDate":"2023-09-21"}],"wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase3() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": "999","complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": null,"productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","otherProblemImages": "https://dev2-magento.sinodis.com/media/payment_certificate/files/71851705053539_cat.jpg","sapBatch":"12345&67890","sapBatchNumbers": [{"sapBatchNumber": null,"number": "0.88","unit": "kg","productionDate": "2023-08-21","expiryDate":"2023-09-21"}],"wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase4() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": "999","complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": null,"productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","otherProblemImages": "https://dev2-magento.sinodis.com/media/payment_certificate/files/71851705053539_cat.jpg","sapBatch":"12345&67890","sapBatchNumbers": [{"number": "0.88","unit": "kg","productionDate": "2023-08-21","expiryDate":"2023-09-21"}],"wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
    @isTest
    static void testPostMethodErrorCase5() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PComplaintsUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas": [{"mgCaseId": "999","complaintDate": "2024-01-12 17:59:07","origin": "E-Commerce","reason": "121","accountId": 124,"contactId": 555,"skuCode": "ELV0036B-01","skuQuantity": 13,"dn": "0","package": null,"product": null,"productIssueImage": "https://img1.baidu.com/it/u=3213028832,2848109658&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=750","packagingIssueImage": "https://dev2-magento.sinodis.com/media/payment_certificate/files/39521705053536_cat.jpg","otherProblemImages": "https://dev2-magento.sinodis.com/media/payment_certificate/files/71851705053539_cat.jpg","sapBatch":"12345&67890","sapBatchNumbers": null,"wsCompanyName": "ws","wsContactPhone": " 13900000025"}]}');
        RestContext.request = request;
        RestContext.response= res;
        System.debug('123');
        Test.startTest();
        CN_Case_Insert_Rest.post();
        Test.stopTest();
    }
}
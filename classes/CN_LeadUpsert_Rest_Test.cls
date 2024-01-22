/*
 * ************************************************************************************************
 * Name : CN_LeadUpsert_Rest_Zzh_Test
 * Object :
 * Requirement :LD-001
 * Target :
 * Refer classes :
 * Author : Zzh
 * Create Date :
 * Modify History :
 * ************************************************************************************************
 */
@isTest
public class CN_LeadUpsert_Rest_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    static void testPostMethod() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/LeadUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas":[{"uniqueId":"1","company":"\u6210\u90fd\u534e\u5ddd\u7535\u88c5\u6709\u9650\u8d23\u4efb\u516c\u53f8","firstName":"","lastName":"\u6ce8\u518c\u624b\u673a","category":"BAPA","leadSource":"E-Commerce","wechatId":"13858692233","mobilePhone":"13858692233","province":"230","city":"510100","street":"19","zip":"000000","companyId":"291","email":"13858692233@163.com","country":"CN","mgContactID":"1017","mgAccountID":"291","businessLicense":"https:\\/\\/dev-magento.sinodis.com\\/media\\/customerdocument\\/c5c15e509dfeb5bb086560add98fab2f.jpeg","bankInformation":"","foodExperienceLicense":"","salutation":null,"phone":null,"website":null,"businessVolume":0,"companyDescription":null,"invitationCode":null,"storeNumber":"12","invitatorName":null,"invitatorPhoneNumber":null},{"uniqueId":"2","company":"\u6210\u90fd\u534e\u5ddd\u7535\u88c5\u6709\u9650\u8d23\u4efb\u516c\u53f8","firstName":"","lastName":"\u6ce8\u518c\u624b\u673a","category":"BAPA","leadSource":"E-Commerce","wechatId":"13858692233","mobilePhone":"13858692233","province":"230","city":"510100","street":"19","zip":"000000","companyId":"291","email":"13858692233@163.com","country":"CN","mgContactID":"1017","mgAccountID":"291","businessLicense":"","bankInformation":"","foodExperienceLicense":"","salutation":null,"phone":null,"website":null,"businessVolume":0,"companyDescription":null,"invitationCode":"Test0001","storeNumber":"12","invitatorName":null,"invitatorPhoneNumber":null},{"uniqueId":"3","company":"\u6210\u90fd\u534e\u5ddd\u7535\u88c5\u6709\u9650\u8d23\u4efb\u516c\u53f8","firstName":"","lastName":"\u6ce8\u518c\u624b\u673a","category":"BAPA","leadSource":"E-Commerce","wechatId":"13858692233","mobilePhone":"13858692233","province":"230","city":"510100","street":"19","zip":"000000","companyId":"291","email":"13858692233@163.com","country":"CN","mgContactID":"1017","mgAccountID":"291","businessLicense":"","bankInformation":"","foodExperienceLicense":"","salutation":null,"phone":null,"website":null,"businessVolume":0,"companyDescription":null,"invitationCode":"Test000100000000000","storeNumber":"12","invitatorName":null,"invitatorPhoneNumber":null}]}');
        RestContext.request = request;
        RestContext.response= res;
        
        // Perform the callout
        Test.startTest();
        CN_LeadUpsert_Rest.post();
        List<Lead> leads = [SELECT Id,FirstName,LastName,OwnerId FROM Lead];
        CN_LeadUpsert_Rest.notifyUsers(leads);
        List<Lead> leads2 = [SELECT FirstName,LastName,OwnerId FROM Lead];
        for(Lead l:leads2){
            l.Id = null;
        }
        CN_LeadUpsert_Rest.notifyUsers(leads2);
        Test.stopTest();
        // Add more log asserts as needed
    }

    @isTest
    static void testPostMethodErrorCase() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/LeadUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"datas":[{"uniqueId":"1","company":"\u6210\u90fd\u534e\u5ddd\u7535\u88c5\u6709\u9650\u8d23\u4efb\u516c\u53f8","firstName":"","lastName":"","category":"BAPA","leadSource":"E-Commerce","wechatId":"13858692233","province":"230","city":"510100","street":"19","zip":"000000","companyId":"291","email":"13858692233@163.com","country":"CN","mgContactID":"1017","mgAccountID":"291","businessLicense":"","bankInformation":"","foodExperienceLicense":"","salutation":null,"phone":null,"website":null,"businessVolume":0,"companyDescription":null,"invitationCode":null,"storeNumber":"12","invitatorName":null,"invitatorPhoneNumber":null},{"uniqueId":"1","company":"\u6210\u90fd\u534e\u5ddd\u7535\u88c5\u6709\u9650\u8d23\u4efb\u516c\u53f8","firstName":"","lastName":"\u6ce8\u518c\u624b\u673a","category":"BAPA","leadSource":"E-Commerce","wechatId":"13858692233","mobilePhone":"13858692233","province":"230","city":"510100","street":"19","zip":"000000","companyId":"291","email":"@","country":"CN","mgContactID":"1017","mgAccountID":"291","businessLicense":"","bankInformation":"","foodExperienceLicense":"","salutation":null,"phone":null,"website":null,"businessVolume":0,"companyDescription":null,"invitationCode":"2023","storeNumber":"12","invitatorName":null,"invitatorPhoneNumber":null}]}');
        RestContext.request = request;
        RestContext.response= res;
        
        // Perform the callout
        Test.startTest();
        CN_LeadUpsert_Rest.post();

        Test.stopTest();
        // Add more log asserts as needed
    }

    @isTest
    static void testPostMethodNoneData() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/LeadUpsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{}');
        RestContext.request = request;
        RestContext.response= res;

        // Perform the callout
        Test.startTest();
        CN_LeadUpsert_Rest.post();

        Test.stopTest();
        // Add more log asserts as needed
    }

}
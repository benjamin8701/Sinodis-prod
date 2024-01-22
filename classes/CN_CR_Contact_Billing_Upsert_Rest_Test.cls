/*
 * ************************************************************************************************
 * Name : CN_CR_Contact_Billing_Upsert_Rest_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/12/28
 * Modify History :
 * ************************************************************************************************
 */
@isTest
public class CN_CR_Contact_Billing_Upsert_Rest_Test {
	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}

    @IsTest
	private static void handleContact(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/BillingAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"newContactTitle":"Title","newContactNameCNLastName":"example2-1213V2","newContactNameCNFirstName":"U1692156286-1213","newContactNameEN":"EN name","newContactLicenseName":"1","newContactType":"01;02","newDepartmentOfContactPerson":"0015","newContactPhoneNumber":"18516071021","newContactMobile":"15202121020","newContactWechatID":"15202121020","newContactEmail":"peggy.liu@savencia-test.com","mgContactID":"1","newContactBillingToAddress":"\u5317\u4eac\u4e07\u53e4\u79d1\u6280\u80a1\u4efd\u6709\u9650\u516c\u53f8test1455","newContactBirthday":"2000-01-01","newContactReportsTo":"","newContactFamilyInfo":"","newContactOpenFieldToComment":"","mgBillingToAddressID":"1","billingToAddressId":"1","newShipToIndirectAccount":""}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_Contact_Billing_Upsert_Rest.post();
		Test.stopTest();
	}

	@IsTest
	private static void handleContactFieldError(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/BillingAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"newContactMobile":"15202121020","newContactWechatID":"15202121020","newContactEmail":"peggy.liu@savencia-test.com","mgContactID":"1","newContactBillingToAddress":"\u5317\u4eac\u4e07\u53e4\u79d1\u6280\u80a1\u4efd\u6709\u9650\u516c\u53f8test1455","newContactBirthday":"2000-01-01","newContactReportsTo":"","newContactFamilyInfo":"","newContactOpenFieldToComment":"","mgBillingToAddressID":"1","billingToAddressId":"1","newShipToIndirectAccount":""}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_Contact_Billing_Upsert_Rest.post();
		Test.stopTest();
	}

	@IsTest
	private static void handleContacNoneData(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/BillingAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_Contact_Billing_Upsert_Rest.post();
		Test.stopTest();
	}

	@IsTest
	private static void handleContactInsertError(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/BillingAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"newContactTitle":"Title","newContactNameCNLastName":"example2-1213V2","newContactNameCNFirstName":"U1692156286-1213","newContactNameEN":"EN name","newContactLicenseName":"1","newContactType":"01;02","newDepartmentOfContactPerson":"0015","newContactPhoneNumber":"18516071021","newContactMobile":"15202121020","newContactWechatID":"15202121020","newContactEmail":"com","newContactBillingToAddress":"\u5317\u4eac\u4e07\u53e4\u79d1\u6280\u80a1\u4efd\u6709\u9650\u516c\u53f8test1455","newContactBirthday":"2000-01-01","newContactReportsTo":"","newContactFamilyInfo":"","newContactOpenFieldToComment":"","mgBillingToAddressID":"1","billingToAddressId":"1","newShipToIndirectAccount":""}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_Contact_Billing_Upsert_Rest.post();
		Test.stopTest();
	}

	@IsTest
	private static void handleContactNoneMgContactId(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/BillingAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"newContactTitle":"Title","newContactNameCNLastName":"example2-1213V2","newContactNameCNFirstName":"U1692156286-1213","newContactNameEN":"EN name","newContactLicenseName":"1","newContactType":"01;02","newDepartmentOfContactPerson":"0015","newContactPhoneNumber":"18516071021","newContactMobile":"15202121020","newContactWechatID":"15202121020","newContactEmail":"peggy.liu@savencia-test.com","mgContactID":"1000","newContactBillingToAddress":"\u5317\u4eac\u4e07\u53e4\u79d1\u6280\u80a1\u4efd\u6709\u9650\u516c\u53f8test1455","newContactBirthday":"2000-01-01","newContactReportsTo":"","newContactFamilyInfo":"","newContactOpenFieldToComment":"","mgBillingToAddressID":"1","billingToAddressId":"1","newShipToIndirectAccount":""}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_Contact_Billing_Upsert_Rest.post();
		Test.stopTest();
	}
}
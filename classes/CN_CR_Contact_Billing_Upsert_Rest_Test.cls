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



	@IsTest
	private static void handleWithAutoSubmit(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
		Contact contactId = [SELECT Id FROM Contact WHERE CN_MG_Contact_ID__c = '1'][0];

		CN_Change_Request__c cr = new CN_Change_Request__c();
		RecordType recordTypeAPPD = [SELECT ID FROM RecordType WHERE DeveloperName = :Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT].get(0);
		cr.recordtypeId = recordTypeAPPD.id;
		cr.CN_CR_Source__c = 'E-Commerce';
		cr.New_CN_Contact_Type__c = '04';
		cr.New_CN_Contact_Title__c = 'contact title';
		cr.CN_Is_Generate_From_Action__c = true;
		cr.New_CN_Contact_CN_First_Name__c = 'Test';
		cr.New_CN_Contact_CN_Last_Name__c = 'Test CR_update';
		cr.New_CN_Contact_Dept_Of_Contact_Person__c = '0001';
		cr.New_CN_Contact_Name_EN__c = 'Contact Name EN';
		cr.New_CN_Contact_Mobile__c = '15755555555';
		cr.New_CN_Contact_Billing_To_Address__c = '1';
		cr.CN_Change_Request_Status__c = 'Approved' ;
		cr.CN_External_Id__c  = contactId.id ;
		cr.CN_Contact__c=contactId.id;
            
        insert cr;

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

	
}
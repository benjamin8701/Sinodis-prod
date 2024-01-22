/*
 * ************************************************************************************************
 * Name : CN_CR_ShipTo_Address_Upsert_Rest_Test
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
public class CN_CR_ShipTo_Address_Upsert_Rest_Test {

	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}

	@isTest
	private static void handleNewShipTo(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"flag":"01","newMGAccountID":"1","shipToContactName":"TestName","soldToPartyCustomer":"1","newCityCN":"310100","newShipToContactName":"新收货方联系人姓名Text(35)","newShipToDeliveryAddressCN":"新收货方交货地址（CN）Text(140)","newShipToDeliveryAddressEN":"新收货方交货地址（EN）Text(220)","newShipToIndirectAccount":"1","newShipToMobilePhone":"13077776666","newProvinceCN":"010","newShipToTelephone":"13266667777","newSoldToPartyCustomer":"1","shipToCard":"http://www.test.com/media/customerdocument/bcb7483971fb94ef87da6cca2fc5c720.png","shipToAddressID":"1"}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleNewShipToFieldError(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"flag":"01","newCityCN":"310100","newShipToContactName":"新收货方联系人姓名Text(35)","newShipToDeliveryAddressCN":"新收货方交货地址（CN）Text(140)","newShipToDeliveryAddressEN":"新收货方交货地址（EN）Text(220)","newShipToIndirectAccount":"1","newShipToMobilePhone":"13077776666","newProvinceCN":"010","newShipToTelephone":"13266667777","newSoldToPartyCustomer":"1","shipToCard":"http://www.test.com/media/customerdocument/bcb7483971fb94ef87da6cca2fc5c720.png","shipToAddressID":"1"}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleUpdateShipTo(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account account = [SELECT Id,CN_MG_Account_ID__c FROM Account WHERE  CN_MG_Account_ID__c = '1'];
		account.CN_Sync_Status__c = 'Success';
		update account;
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"flag":"02","mgAccountID":"1","newMGAccountID":"1","shipToContactName":"TestName","soldToPartyCustomer":"1","newCityCN":"310100","newShipToContactName":"新收货方联系人姓名Text(35)","newShipToDeliveryAddressCN":"新收货方交货地址（CN）Text(140)","newShipToDeliveryAddressEN":"新收货方交货地址（EN）Text(220)","newShipToIndirectAccount":"1","newShipToMobilePhone":"13077776666","newProvinceCN":"010","newShipToTelephone":"13266667777","newSoldToPartyCustomer":"1","shipToCard":"/media/customerdocument/bcb7483971fb94ef87da6cca2fc5c720.png","shipToAddressID":"1"}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleInactiveShipTo(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account account = [SELECT Id,CN_MG_Account_ID__c FROM Account WHERE  CN_MG_Account_ID__c = '1'];
		account.CN_Sync_Status__c = 'Success';
		update account;
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"shipToAddressID":"1","inactive":false,"flag":"03"}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleInactiveShipToAccountNotSuccess(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"shipToAddressID":"1","inactive":false,"flag":"03"}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleFlagError(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"shipToAddressID":"1","inactive":false,"flag":"04"}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleInactiveNoneShipTo(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[{"shipToAddressID":"0","inactive":false,"flag":"03"}]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleInactiveNoneDatas(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

	@isTest
	private static void handleInactiveEmptyDatas(){
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
		request.requestURI = '/services/apexrest/AccountShipToAddressUpsert';
		request.httpMethod = 'POST';
		String body = '{"datas":[]}';
		request.requestBody = Blob.valueOf(body);
		RestContext.request = request;
		RestContext.response= res;
		Test.startTest();
		CN_CR_ShipTo_Address_Upsert_Rest.post();
		Test.stopTest();
	}

}
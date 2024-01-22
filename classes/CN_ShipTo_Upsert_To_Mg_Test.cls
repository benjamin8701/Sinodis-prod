/*
 * ************************************************************************************************
 * Name : CN_ShipTo_Upsert_To_Mg_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/12/29
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_ShipTo_Upsert_To_Mg_Test {

	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}

	@IsTest
	private static void handleUpdate() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Need_Send_MG__c = true;
		shipToParty.CN_UP_Code__c = 'UPTEST';
		update shipToParty;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_ShipTo_Upsert_To_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate503() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Need_Send_MG__c = true;
		shipToParty.CN_UP_Code__c = 'UPTEST';
		shipToParty.CN_ShipTo_Address_ID__c = '503';
		update shipToParty;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_ShipTo_Upsert_To_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate500() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Need_Send_MG__c = true;
		shipToParty.CN_UP_Code__c = 'UPTEST';
		shipToParty.CN_ShipTo_Address_ID__c = '500';
		update shipToParty;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_ShipTo_Upsert_To_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate404() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Need_Send_MG__c = true;
		shipToParty.CN_UP_Code__c = 'UPTEST';
		shipToParty.CN_ShipTo_Address_ID__c = '404';
		update shipToParty;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_ShipTo_Upsert_To_Mg_Batch());
	}

	@IsTest
	private static void handleUpdateErr() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Need_Send_MG__c = true;
		shipToParty.CN_UP_Code__c = 'UPTEST';
		shipToParty.CN_ShipTo_Address_ID__c = 'Err';
		update shipToParty;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_ShipTo_Upsert_To_Mg_Batch());
	}

	@IsTest
	private static void handleSCHTest() {
		System.schedule('CN_ShipTo_Upsert_To_Mg_SCH', '0 0 * * * ?', new CN_ShipTo_Upsert_To_Mg_SCH());
	}
}
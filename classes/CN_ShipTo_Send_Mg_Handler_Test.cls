/*
 * ************************************************************************************************
 * Name : CN_ShipTo_Send_Mg_Handler_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2024/1/2
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_ShipTo_Send_Mg_Handler_Test {
	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}


	@isTest
	static void testHandleBeforeInsert1() {

		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account acc = [SELECT Id,CN_Invoicing_Address_and_Phone__c,CN_Delivery_Plant__c,CN_Province_CN__c,CN_City_CN__c, Name,CN_Invoicing_Address_EN__c, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];

		CN_Ship_to_Party__c shipTo = new CN_Ship_to_Party__c(
				CN_Sold_To_Party_Customer__c = acc.Id,
				CN_Customer_Type__c = '0002',
				CN_Delivery_Address_CN__c = acc.CN_Invoicing_Address_and_Phone__c + 1,
				CN_Delivery_Plant__c = acc.CN_Delivery_Plant__c,
				CN_Province_CN__c = acc.CN_Province_CN__c,
				CN_City_CN__c = acc.CN_City_CN__c,
				CN_Delivery_Address_EN__c = acc.CN_Invoicing_Address_EN__c + 1,
				CN_ShipTo_Address_ID__c = acc.CN_MG_Account_ID__c + 1
		);
		insert shipTo;

	}

	@isTest
	static void testHandleBeforeInsert2() {

		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account acc = [SELECT Id,CN_Invoicing_Address_and_Phone__c,CN_Delivery_Plant__c,CN_Province_CN__c,CN_City_CN__c, Name,CN_Invoicing_Address_EN__c, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
		acc.CN_Account_Source__c = 'Customer Service Hotline';
		update acc;

		CN_Ship_to_Party__c shipTo = new CN_Ship_to_Party__c(
				CN_Sold_To_Party_Customer__c = acc.Id,
				CN_Customer_Type__c = '0002',
				CN_Delivery_Address_CN__c = acc.CN_Invoicing_Address_and_Phone__c + 1,
				CN_Delivery_Plant__c = acc.CN_Delivery_Plant__c,
				CN_Province_CN__c = acc.CN_Province_CN__c,
				CN_City_CN__c = acc.CN_City_CN__c,
				CN_Delivery_Address_EN__c = acc.CN_Invoicing_Address_EN__c + 1,
				CN_ShipTo_Address_ID__c = acc.CN_MG_Account_ID__c + 1
		);
		insert shipTo;

	}

	@isTest
	static void testHandleBeforeInsert3() {

		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account acc = [SELECT Id,CN_Invoicing_Address_and_Phone__c,CN_Delivery_Plant__c,CN_Province_CN__c,CN_City_CN__c, Name,CN_Invoicing_Address_EN__c, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
		acc.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update acc;

		CN_Ship_to_Party__c shipTo = new CN_Ship_to_Party__c(
				CN_Sold_To_Party_Customer__c = acc.Id,
				CN_Customer_Type__c = '0002',
				CN_Delivery_Address_CN__c = acc.CN_Invoicing_Address_and_Phone__c + 1,
				CN_Delivery_Plant__c = acc.CN_Delivery_Plant__c,
				CN_Province_CN__c = acc.CN_Province_CN__c,
				CN_City_CN__c = acc.CN_City_CN__c,
				CN_Delivery_Address_EN__c = acc.CN_Invoicing_Address_EN__c + 1,
				CN_ShipTo_Address_ID__c = acc.CN_MG_Account_ID__c + 1
		);
		insert shipTo;
	}

	@isTest
	static void testHandleBeforeUpdate1() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account acc = [SELECT Id,CN_Invoicing_Address_and_Phone__c,CN_Delivery_Plant__c,CN_Province_CN__c,CN_City_CN__c, Name,CN_Invoicing_Address_EN__c, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
		acc.CN_Account_Source__c = null;
		update acc;

		CN_Ship_to_Party__c shipToParty =  [select id,Name  from CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Delivery_Address_CN__c = 'TestUpdate';
		update shipToParty;
	}

	@isTest
	static void testHandleBeforeUpdate2() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account acc = [SELECT Id,CN_Invoicing_Address_and_Phone__c,CN_Delivery_Plant__c,CN_Province_CN__c,CN_City_CN__c, Name,CN_Invoicing_Address_EN__c, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
		acc.CN_Account_Source__c = 'Customer Service Hotline';
		update acc;

		CN_Ship_to_Party__c shipToParty =  [select id,Name  from CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Delivery_Address_CN__c = 'TestUpdate';
		update shipToParty;
	}

	@isTest
	static void testHandleBeforeUpdate3() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();

		CN_Ship_to_Party__c shipToParty =  [select id,Name  from CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Delivery_Address_CN__c = 'TestUpdate';
		update shipToParty;
	}

	@isTest
	static void testHandleBeforeUpdate4() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		Account acc = [SELECT Id,CN_Invoicing_Address_and_Phone__c,CN_Delivery_Plant__c,CN_Province_CN__c,CN_City_CN__c, Name,CN_Invoicing_Address_EN__c, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
		acc.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update acc;

		CN_Ship_to_Party__c shipToParty =  [select id,Name  from CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		shipToParty.CN_Delivery_Address_CN__c = 'TestUpdate';
		update shipToParty;
	}
}
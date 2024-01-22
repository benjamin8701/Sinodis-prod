/*
 * ************************************************************************************************
 * Name : CN_CR_Approved_Result_To_Mg_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2024/1/1
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_CR_Approved_Result_To_Mg_Test {
	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}

	@IsTest
	private static void handleUpdate() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();

		CN_Ship_to_Party__c cnShipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		cnShipToParty.CN_Need_Send_MG__c = false;
		update cnShipToParty;

		Id crRTIdNewAppd = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
		CN_Change_Request__c cnChangeRequest = new CN_Change_Request__c();
		cnChangeRequest.RecordTypeId = crRTIdNewAppd;
		cnChangeRequest.CN_Need_Send_MG_Flag__c = 1;
		cnChangeRequest.CN_ShipTo_Address_ID__c = '1';
		cnChangeRequest.CN_Approved_Status__c = 1;
		cnChangeRequest.CN_CR_Source__c = Constants.CN_CR_SOURCE_ECOMMERCE;
		cnChangeRequest.CN_Ship_to_Party__c  = cnShipToParty.Id;
		insert cnChangeRequest;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_CR_Approved_Result_To_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate500() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();

		CN_Ship_to_Party__c cnShipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		cnShipToParty.CN_Need_Send_MG__c = false;
		cnShipToParty.CN_ShipTo_Address_ID__c = '500';
		update cnShipToParty;

		Id crRTIdNewAppd = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
		CN_Change_Request__c cnChangeRequest = new CN_Change_Request__c();
		cnChangeRequest.RecordTypeId = crRTIdNewAppd;
		cnChangeRequest.CN_Need_Send_MG_Flag__c = 1;
		cnChangeRequest.CN_ShipTo_Address_ID__c = '500';
		cnChangeRequest.CN_Approved_Status__c = 1;
		cnChangeRequest.CN_CR_Source__c = Constants.CN_CR_SOURCE_ECOMMERCE;
		cnChangeRequest.CN_Ship_to_Party__c  = cnShipToParty.Id;
		insert cnChangeRequest;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_CR_Approved_Result_To_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate404() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();

		CN_Ship_to_Party__c cnShipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		cnShipToParty.CN_Need_Send_MG__c = false;
		cnShipToParty.CN_ShipTo_Address_ID__c = '404';
		update cnShipToParty;

		Id crRTIdNewAppd = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
		CN_Change_Request__c cnChangeRequest = new CN_Change_Request__c();
		cnChangeRequest.RecordTypeId = crRTIdNewAppd;
		cnChangeRequest.CN_Need_Send_MG_Flag__c = 1;
		cnChangeRequest.CN_ShipTo_Address_ID__c = '404';
		cnChangeRequest.CN_Approved_Status__c = 1;
		cnChangeRequest.CN_CR_Source__c = Constants.CN_CR_SOURCE_ECOMMERCE;
		cnChangeRequest.CN_Ship_to_Party__c  = cnShipToParty.Id;
		insert cnChangeRequest;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_CR_Approved_Result_To_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate503() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();

		CN_Ship_to_Party__c cnShipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		cnShipToParty.CN_Need_Send_MG__c = false;
		cnShipToParty.CN_ShipTo_Address_ID__c = '503';
		update cnShipToParty;

		Id crRTIdNewAppd = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
		CN_Change_Request__c cnChangeRequest = new CN_Change_Request__c();
		cnChangeRequest.RecordTypeId = crRTIdNewAppd;
		cnChangeRequest.CN_Need_Send_MG_Flag__c = 1;
		cnChangeRequest.CN_ShipTo_Address_ID__c = '503';
		cnChangeRequest.CN_Approved_Status__c = 1;
		cnChangeRequest.CN_CR_Source__c = Constants.CN_CR_SOURCE_ECOMMERCE;
		cnChangeRequest.CN_Ship_to_Party__c  = cnShipToParty.Id;
		insert cnChangeRequest;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_CR_Approved_Result_To_Mg_Batch());
	}
}
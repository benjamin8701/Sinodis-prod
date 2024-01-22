/*
 * ************************************************************************************************
 * Name : CN_Account_Send_MG_Mark_Batch_Test
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
public class CN_Account_Send_MG_Mark_Batch_Test {
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
		account.CN_Need_Send_MG_Flag__c = 3;
		account.CN_Customer_Code__c = '1';
		account.CN_Block_Sales_Support__c = true;
		update account;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Account_Send_MG_Mark_Batch());
	}

	@IsTest
	private static void handleUpdate503() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		account.CN_Need_Send_MG_Flag__c = 3;
		account.CN_Customer_Code__c = '1';
		account.CN_Block_Sales_Support__c = true;
		account.CN_MG_Account_ID__c = '503';
		update account;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Account_Send_MG_Mark_Batch());
	}

	@IsTest
	private static void handleUpdate500() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		account.CN_Need_Send_MG_Flag__c = 3;
		account.CN_Customer_Code__c = '1';
		account.CN_Block_Sales_Support__c = true;
		account.CN_MG_Account_ID__c = '500';
		update account;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Account_Send_MG_Mark_Batch());
	}

	@IsTest
	private static void handleUpdate404() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		account.CN_Need_Send_MG_Flag__c = 3;
		account.CN_Customer_Code__c = '1';
		account.CN_Block_Sales_Support__c = true;
		account.CN_MG_Account_ID__c = '404';
		update account;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Account_Send_MG_Mark_Batch());
	}
}
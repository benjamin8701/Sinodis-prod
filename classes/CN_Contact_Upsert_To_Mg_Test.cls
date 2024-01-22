/*
 * ************************************************************************************************
 * Name : CN_Contact_Upsert_To_Mg_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/12/31
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_Contact_Upsert_To_Mg_Test {

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
		account.CN_Customer_Code__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		Contact contact = [SELECT Id FROM Contact WHERE CN_MG_Contact_ID__c = '1'];
		contact.CN_Need_Send_MG__c = true;
		contact.CN_UP_Code__c = 'UPTEST';
		update contact;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Contact_Send_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate503() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		account.CN_Customer_Code__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		Contact contact = [SELECT Id FROM Contact WHERE CN_MG_Contact_ID__c = '1'];
		contact.CN_Need_Send_MG__c = true;
		contact.CN_MG_Contact_ID__c = '503';
		contact.CN_UP_Code__c = 'UPTEST';
		update contact;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Contact_Send_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate500() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		account.CN_Customer_Code__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		Contact contact = [SELECT Id FROM Contact WHERE CN_MG_Contact_ID__c = '1'];
		contact.CN_Need_Send_MG__c = true;
		contact.CN_UP_Code__c = 'UPTEST';
		contact.CN_MG_Contact_ID__c = '500';
		update contact;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Contact_Send_Mg_Batch());
	}

	@IsTest
	private static void handleUpdate404() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeFactoryAccount();
		testFactory.makeTalendSetting();
		Account account = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		account.CN_Customer_Code__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		Contact contact = [SELECT Id FROM Contact WHERE CN_MG_Contact_ID__c = '1'];
		contact.CN_Need_Send_MG__c = true;
		contact.CN_UP_Code__c = 'UPTEST';
		contact.CN_MG_Contact_ID__c = '404';
		update contact;

		Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_Contact_Send_Mg_Batch());
	}

}
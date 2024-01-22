/*
 * ************************************************************************************************
 * Name : CN_Account_Send_MG_Mark_Handler_Test
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
public class CN_Account_Send_MG_Mark_Handler_Test {
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
		account.CN_Account_Source__c = 'Customer Recommend';
		update account;
		account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		update account;
		account.CN_Customer_Code__c = '999';
		update account;
		account.CN_MG_Account_ID__c = '999';
		update account;
		account.CN_Payment_Terms__c = '999';
		update account;
		account.CN_Block_Sales_Support__c = true;
		update account;

	}

	@IsTest
	private static void handleNewAccount() {
		User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
		CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
		CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
		CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
		CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];

		Account acc = new Account();
		acc.CN_License_Name_EN__c = 'TestAccount';
		acc.CN_Store_Name_EN__c = 'TestAccount';
		acc.CN_Store_Name_CN__c = 'TestAccount';
		acc.CN_Sales_District__c = '001';
		acc.Name = '01';
		acc.CN_Litigation_City__c = 'Dalian大连';
		acc.CN_Category__c = 'BAPA';
		acc.CN_Subcategory__c = 'Access Bakery';
		acc.CN_Province_CN__c = province.Id;
		acc.CN_City_CN__c = city.Id;
		acc.CN_Post_Code__c = '100000';
		acc.CN_Delivery_Plant__c = 'P011';
		acc.CN_Payment_Terms__c = 'D000';
		acc.CN_Invoicing_Name_Bill_To_Party__c = 'D000';
		acc.CN_Tax_Registration_No__c = '10000000';
		acc.CN_Invoice_Type__c = 'General Invoice';
		acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
		acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
		acc.CN_Business_Unit_UI__c = businessUnit.Id;
		acc.CN_Sales_Team_UI__c = salesTeam.Id;
		acc.CN_Visit_Addr_CN__c = 'Visit Address';
		insert acc;
	}

	@IsTest
	private static void handleNewECAccount() {
		User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
		CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
		CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
		CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
		CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];

		Account acc = new Account();
		acc.CN_License_Name_EN__c = 'TestAccount';
		acc.CN_Store_Name_EN__c = 'TestAccount';
		acc.CN_Store_Name_CN__c = 'TestAccount';
		acc.CN_Sales_District__c = '001';
		acc.Name = '01';
		acc.CN_Litigation_City__c = 'Dalian大连';
		acc.CN_Category__c = 'BAPA';
		acc.CN_Subcategory__c = 'Access Bakery';
		acc.CN_Province_CN__c = province.Id;
		acc.CN_City_CN__c = city.Id;
		acc.CN_Post_Code__c = '100000';
		acc.CN_Delivery_Plant__c = 'P011';
		acc.CN_Payment_Terms__c = 'D000';
		acc.CN_Invoicing_Name_Bill_To_Party__c = 'D000';
		acc.CN_Tax_Registration_No__c = '10000000';
		acc.CN_Invoice_Type__c = 'General Invoice';
		acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
		acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
		acc.CN_Business_Unit_UI__c = businessUnit.Id;
		acc.CN_Sales_Team_UI__c = salesTeam.Id;
		acc.CN_Visit_Addr_CN__c = 'Visit Address';
		acc.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
		insert acc;
	}
}
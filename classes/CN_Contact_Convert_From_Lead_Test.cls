/*
 * ************************************************************************************************
 * Name : CN_Contact_Convert_From_Lead_Handler_Test
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
public class CN_Contact_Convert_From_Lead_Test {
	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}


	@isTest
	static void testHandleBeforeInsert1() {

		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeAccounts(10,false);

		Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
				SetupOwnerId = UserInfo.getOrganizationId(),
				EnableFlow__c = true,
				EnableTrigger__c = true,
				EnableValidationRule__c = false
		);
		insert setting;

		System.debug(Untils.isTriggerEnabled());
		System.debug(Constants.CONTACT_TRIGGER_ON);

		Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '2'];

		Contact oldContact = [SELECT Id,CN_MG_Contact_ID__c,CN_Is_Converted_From_Lead__c FROM Contact WHERE CN_MG_Contact_ID__c = '1'];

		Contact con = new Contact();
		con.AccountId = account.Id;
		con.CN_Is_Converted_From_Lead__c = true;
		con.CN_Contact_Type__c = '02';
		con.Title = 'CEO';
		con.CN_Department_Of_Contact_Person__c = '0001';
		con.CN_Contact_Name_EN__c = account.Name + 'Test Contact1';
		con.LastName = 'Contact1';
		con.MobilePhone = '13013001301';
		con.CN_Bill_To_Address__c = 'ABCDE1';
		con.CN_MG_Contact_ID__c = '1';
		insert con;

	}
}
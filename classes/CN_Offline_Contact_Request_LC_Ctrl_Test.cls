/*
 * ************************************************************************************************
 * Name : CN_Offline_Contact_Request_LC_Ctrl_Test
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
@isTest
public class CN_Offline_Contact_Request_LC_Ctrl_Test {
	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}
	@isTest
	private static void handleTest() {
		TestDataFactory testDataFactory = new TestDataFactory();
		testDataFactory.makeAccounts(10,false);
		List<User> userList = [SELECT Id, LastName FROM User];
		Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
		for(User usr: userList) {
			lastNameUserIdMap.put(usr.LastName, usr.Id);
		}

		Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
		User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
		CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
		CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
		Lead l1 = new Lead(
				CN_UniqueId__c ='400',
				recordTypeId = cnLeadRTId,
				Company = 'Test Class Lead',
				LastName  = 'Lead last Name_l2',
				FirstName = 'Lead First Name',
				LeadSource = 'E-Commerce',
				CN_Customer_Category__c = 'Restaurant',
				Status = 'Open',
				MobilePhone = '15748484848',
				CN_Province__c = province.Id,
				CN_City__c = city.Id,
				CN_Street__c = 'Lead Visit Address',
				CN_Zip_Postal_Code__c = '123456',
				OwnerId = salesRep.Id
		);
		insert l1;

		Test.startTest();
		List<Lead> leads = [SELECT Id,FirstName,LastName,OwnerId FROM Lead];
		Lead lead = leads.get(0);
		lead.Status = Constants.CN_LEAD_STATUS_SALES_QUALIFIED;
		update leads;

		Contact contact = [SELECT  Id,AccountId FROM Contact LIMIT 1];
		Account account = new Account();
		account.Id = contact.AccountId;
		account.CN_Sync_Status__c = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
		update account;
		CN_Offline_Contact_Request_LC_Ctrl.getContact(contact.Id,lead.Id);
		Test.stopTest();
	}
}
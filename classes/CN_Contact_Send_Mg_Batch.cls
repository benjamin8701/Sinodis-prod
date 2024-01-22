/*
 * ************************************************************************************************
 * Name : CN_Contact_Send_Mg_Batch
 * Object :
 * Requirement :CT-014
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/25
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Contact_Send_Mg_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
	public Iterable<SObject> start(Database.BatchableContext bc) {
		List<Contact> contactList = [
				SELECT ID, Birthdate, LastName,FirstName,CN_Bill_To_Address__c,
						CN_Department_Of_Contact_Person__c,Email,MobilePhone,
						Phone,ReportsTo.CN_MG_Contact_ID__c,
						CN_Contact_Name_EN__c,
						Title,CN_Contact_Type__c,
						CN_Wechat_ID__c,CN_Family_Info__c,CN_Open_Field_To_Comment__c,CN_Decision_Maker__c,
						Account.CN_MG_Account_ID__c,
						CN_MG_Billing_To_Address_ID__c,CN_Billing_To_Address_ID__c,CN_UP_Code__c,
						CN_Lead_MG_Account_ID__c,Account.CN_Customer_Code__c,CN_MG_Contact_ID__c
				FROM Contact
				where CN_Need_Send_MG__c = true
				AND Account.CN_Account_Source__c = :Constants.CN_ACCOUNT_SOURCE_ECOMMERCE
				AND Account.CN_Customer_Code__c != null
				AND CN_UP_Code__c != null
				AND CN_Has_CR_Need_Sync__c = false
				ORDER BY LastModifiedDate DESC
		];

		return contactList;
	}

	public void execute(Database.BatchableContext bc, List<SObject> contactList){

		Map<String,Contact> sendSuccess =  CN_Contact_Upsert_To_Mg_Callout.upsertContact((List<Contact>)contactList);

		update sendSuccess.values();

	}

	public void finish(Database.BatchableContext bc) {

	}
}
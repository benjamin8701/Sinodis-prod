/*
 * ************************************************************************************************
 * Name : CN_Account_Send_MG_Mark_Batch
 * Object :
 * Requirement :AC-017 | AC-018
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/24
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Account_Send_MG_Mark_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

	public Iterable<SObject> start(Database.BatchableContext bc) {
		List<Account> accountList = [SELECT
			ID,
			Name,
			CN_License_Name_EN__c,
			CN_Store_Name_CN__c,
			CN_Store_Name_EN__c,
			CN_Customer_Code__c,
//			CN_Sales_Person_Name__r.Name,
//			CN_Sales_Person_Name__r.CN_User_Email__c,
			Owner.Email,
			Owner.Name,
			CN_MG_Account_ID__c,
			CN_Sales_Team_UI__r.Name,
			CN_Payment_Terms__c,
			CN_Inactive__c,
			CN_Invoice_Type__c,
			CN_Bank_Account_Name__c,
			CN_Tax_Registration_No__c,
			CN_Bank_Account__c,
			CN_Payment_Bank_Account__c,
			CN_Payment_Bank_Name__c,
			CN_Invoicing_Address_and_Phone__c,
			CN_Sales_Office__c,
			CN_Billing_Block__c,
			CN_Delivery_Block__c,
			CN_Order_Block__c,
			CN_Block_Sales_Support__c,
			CN_Closed__c,
			CN_Need_Send_MG_Flag__c,
			CN_Invoicing_Name_Bill_To_Party__c,
			CN_Sales_Org__c,
			CN_Sales_District__c,
			CN_Finance_AR__r.Username
		FROM Account
		WHERE ( CN_Need_Send_MG_Flag__c != 0 and CN_Need_Send_MG_Flag__c != null )
		AND (CN_Customer_Code__c != null OR CN_Inactive__c = true)
		AND CN_Account_Source__c = :Constants.CN_ACCOUNT_SOURCE_ECOMMERCE
		ORDER BY LastModifiedDate DESC ];

		return accountList;
	}

	public void execute(Database.BatchableContext bc, List<SObject> accountList){

		List<Account> inactiveList = new List<Account>();
		List<Account> setCustomerList = new List<Account>();

		for(Account account:(List<Account>) accountList){
			if(((Integer)account.CN_Need_Send_MG_Flag__c & 1) == 1){
				inactiveList.add(account);
			}
			if (((Integer)account.CN_Need_Send_MG_Flag__c & 1 << 1) == 1 << 1){
				setCustomerList.add(account);
			}
		}

		System.debug(JSON.serialize(inactiveList));
		System.debug(JSON.serialize(setCustomerList));

		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();

		Map<String,Account> sendSuccessInactiveId =  CN_Account_Inactive_To_Mg_Callout.upsertInactiveToMg(inactiveList,listLog);
		Map<String,Account> sendSuccessSetCustomerId =  CN_Account_Customer_Code_To_Mg_Callout.upsertCustomerCodeToMg(setCustomerList,listLog);

		List<Account> needUpdateList = new List<Account>();

		for(Account account:(List<Account>) accountList){
			String id = account.Id;
			Integer old = (Integer)account.CN_Need_Send_MG_Flag__c;
			if(sendSuccessInactiveId.containsKey(id)){
				account.CN_Need_Send_MG_Flag__c = (Integer)account.CN_Need_Send_MG_Flag__c ^ 1;
			}
			if(sendSuccessSetCustomerId.containsKey(id)){
				account.CN_Need_Send_MG_Flag__c = (Integer)account.CN_Need_Send_MG_Flag__c ^ 1 << 1;
			}

			if(account.CN_Need_Send_MG_Flag__c == old){
				continue;
			}

			Account needUpdate =  new Account();
			needUpdate.Id = id;
			needUpdate.CN_Need_Send_MG_Flag__c = account.CN_Need_Send_MG_Flag__c;
			needUpdateList.add(needUpdate);

		}
		insert listLog;
		update needUpdateList;

	}

	public void finish(Database.BatchableContext bc) {

	}
}
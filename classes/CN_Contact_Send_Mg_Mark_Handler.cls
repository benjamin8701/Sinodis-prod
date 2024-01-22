/*
 * ************************************************************************************************
 * Name : CN_Contact_Send_Mg_Mark_Handler
 * Object :
 * Requirement :CT-014
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/6
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Contact_Send_Mg_Mark_Handler implements Triggers.Handler{
	public void handle() {

		List<Contact> newList = (List<Contact>)Trigger.new;
		List<String> accountIds = new List<String>();
		for (Contact next : newList) {
			accountIds.add(next.AccountId);
		}

		List<Account> accountList = [SELECT ID,CN_Account_Source__c FROM Account WHERE ID in : accountIds];
		Map<String,Account> accountMap = new Map<String, Account>();
		for (Account next : accountList) {
			accountMap.put(next.Id,next);
		}

		for (Contact next : newList) {
			Account acc =  accountMap.get(next.AccountId);
			if(acc != null){
				next.Account =  acc;
			}

		}

		if (Trigger.isBefore && Trigger.isInsert) {
			handleBeforeInsert();
		} else if (Trigger.isBefore && Trigger.isUpdate) {
			handleBeforeUpdate();
		}
	}

	private void handleBeforeInsert() {
		for(Contact contact : (List<Contact>)Trigger.new){

			if(contact.Account == null
					|| contact.Account.CN_Account_Source__c == null
					|| contact.Account.CN_Account_Source__c != Constants.CN_ACCOUNT_SOURCE_ECOMMERCE  ){
				continue;
			}

			contact.CN_Need_Send_MG__c = true;
		}

	}

	private void handleBeforeUpdate() {
		for(Contact contact : (List<Contact>)Trigger.new){

			if(contact.Account == null
					|| contact.Account.CN_Account_Source__c == null
					|| contact.Account.CN_Account_Source__c != Constants.CN_ACCOUNT_SOURCE_ECOMMERCE  ){
				continue;
			}

			Contact old = (Contact)Trigger.oldMap.get(contact.Id);
			//如果是同步后修改flag，不进行标记
			if(old.CN_Need_Send_MG__c == contact.CN_Need_Send_MG__c){
				contact.CN_Need_Send_MG__c = true;
			}
		}
	}

}
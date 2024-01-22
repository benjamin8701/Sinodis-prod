/*
 * ************************************************************************************************
 * Name : CN_ShipTo_Send_Mg_Handler
 * Description :
 * Object :
 * Requirement : AC-007 | AC-009
 * Target :
 * Refer classes : 
 * Author : Leo Dicaprio
 * Create Date : 2023/8/7
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_ShipTo_Send_Mg_Handler implements Triggers.Handler{

	public void handle() {
		List<CN_Ship_to_Party__c> newList = (List<CN_Ship_to_Party__c>)Trigger.new;
		List<String> accountIds = new List<String>();
		for (CN_Ship_to_Party__c next : newList) {
			System.debug('next.CN_Sold_To_Party_Customer__c==>'+next.CN_Sold_To_Party_Customer__c);
			accountIds.add(next.CN_Sold_To_Party_Customer__c);
		}

		List<Account> accountList = [SELECT ID,CN_Account_Source__c FROM Account WHERE ID in : accountIds];
		Map<String,Account> accountMap = new Map<String, Account>();
		for (Account next : accountList) {
			System.debug('next.Id==>'+next.Id);
			accountMap.put(next.Id,next);
		} 

		for (CN_Ship_to_Party__c next : newList) {
			Account acc =  accountMap.get(next.CN_Sold_To_Party_Customer__c);
 			if(acc != null){
				next.CN_Sold_To_Party_Customer__r =  acc;
				System.debug('next.CN_Sold_To_Party_Customer__r=>'+next.CN_Sold_To_Party_Customer__r);
			}

		}


		if(Trigger.isBefore && Trigger.isUpdate) {
			handleBeforeUpdate();
		}else if(Trigger.isBefore && Trigger.isInsert){
			handleBeforeInsert();
		}
	}

	private void handleBeforeInsert() {
		for(CN_Ship_to_Party__c shipTo:(List<CN_Ship_to_Party__c>)Trigger.new){

			if(shipTo.CN_Sold_To_Party_Customer__r == null
					|| shipTo.CN_Sold_To_Party_Customer__r.CN_Account_Source__c == null
					|| shipTo.CN_Sold_To_Party_Customer__r.CN_Account_Source__c != Constants.CN_ACCOUNT_SOURCE_ECOMMERCE  ){
				continue;
			}

			shipTo.CN_Need_Send_MG__c = true;
		}
	}

	private void handleBeforeUpdate() {
		for(CN_Ship_to_Party__c shipTo:(List<CN_Ship_to_Party__c>)Trigger.new){

			if(shipTo.CN_Sold_To_Party_Customer__r == null
					|| shipTo.CN_Sold_To_Party_Customer__r.CN_Account_Source__c == null
					|| shipTo.CN_Sold_To_Party_Customer__r.CN_Account_Source__c != Constants.CN_ACCOUNT_SOURCE_ECOMMERCE  ){
				continue;
			}

			CN_Ship_to_Party__c old = (CN_Ship_to_Party__c)Trigger.oldMap.get(shipTo.Id);
			System.debug('old.CN_Need_Send_MG__c==>'+old.CN_Need_Send_MG__c);
			System.debug('shipTo.CN_Need_Send_MG__c==>'+shipTo.CN_Need_Send_MG__c);
			if(old.CN_Need_Send_MG__c == shipTo.CN_Need_Send_MG__c){
				shipTo.CN_Need_Send_MG__c = true;
			}
		}
	}

}
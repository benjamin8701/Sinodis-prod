/*
 * ************************************************************************************************
 * Name : CN_Account_Send_MG_Mark_Handler
 * Object :
 * Requirement :  Insert and Update Mark (Use To AC-017 AND AC-018)
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/24
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Account_Send_MG_Mark_Handler implements Triggers.Handler{
	public void handle() {
		if (Trigger.isBefore && Trigger.isInsert) {
			handleBeforeInsert();
		} else if (Trigger.isBefore && Trigger.isUpdate) {
			handleBeforeUpdate(); //get Customer or Inactive
		}
	}

	private void handleBeforeInsert() {
		for (Account newAcc : (List<Account>)Trigger.new) {
			//only handle EC Record
			if(newAcc.CN_Account_Source__c != Constants.CN_ACCOUNT_SOURCE_ECOMMERCE){
				continue;
			}
			newAcc.CN_Need_Send_MG_Flag__c = (Integer)newAcc.CN_Need_Send_MG_Flag__c | 1 << 1;
		}
	}

	private void handleBeforeUpdate() {
		Map<Id, Account> oldMap = (Map<Id, Account>)Trigger.oldMap;
		for (Account newAcc : (List<Account>)Trigger.new) {
			if(newAcc.CN_Account_Source__c != Constants.CN_ACCOUNT_SOURCE_ECOMMERCE){
				continue;
			}
			Account oldAcc = oldMap.get(newAcc.Id);
			if (newAcc.CN_Inactive__c != oldAcc.CN_Inactive__c) {
				newAcc.CN_Need_Send_MG_Flag__c = (Integer)newAcc.CN_Need_Send_MG_Flag__c | 1;
			}


			if (newAcc.CN_Customer_Code__c != oldAcc.CN_Customer_Code__c) {
				newAcc.CN_Need_Send_MG_Flag__c = (Integer)newAcc.CN_Need_Send_MG_Flag__c | 1 << 1;
				continue;
			} else if (newAcc.CN_MG_Account_ID__c != oldAcc.CN_MG_Account_ID__c) {
				newAcc.CN_Need_Send_MG_Flag__c = (Integer)newAcc.CN_Need_Send_MG_Flag__c | 1 << 1;
				continue;
			} else if (newAcc.CN_Payment_Terms__c != oldAcc.CN_Payment_Terms__c) {
				newAcc.CN_Need_Send_MG_Flag__c = (Integer)newAcc.CN_Need_Send_MG_Flag__c | 1 << 1;
				continue;
			}
			//add by ZhangZhiHao owner changes to push to EC
			
			else if (newAcc.OwnerId != oldAcc.OwnerId) {
				newAcc.CN_Need_Send_MG_Flag__c = (Integer)newAcc.CN_Need_Send_MG_Flag__c | 1 << 1;
				continue;
			}
			//add by ZhangZhiHao owner changes to push to EC

			//add by ZhangZhiHao owner changes to push to EC 2024/4/14
			else if (newAcc.CN_Invoicing_Name_Bill_To_Party__c != oldAcc.CN_Invoicing_Name_Bill_To_Party__c) {
				newAcc.CN_Need_Send_MG_Flag__c = (Integer)newAcc.CN_Need_Send_MG_Flag__c | 1 << 1;
				continue;
			}
			//add by ZhangZhiHao owner changes to push to EC 2024/4/14

		}

	}

}
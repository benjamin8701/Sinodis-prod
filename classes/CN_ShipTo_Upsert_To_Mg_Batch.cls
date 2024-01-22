/*
 * ************************************************************************************************
 * Name : CN_ShipTo_Upsert_To_Mg_Batch
 * Object :
 * Requirement : AC-009
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/24
 * Modify History :
 * ************************************************************************************************
 */
public class CN_ShipTo_Upsert_To_Mg_Batch  implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

	public Iterable<SObject> start(Database.BatchableContext bc) {
		List<CN_Ship_to_Party__c> newList = [SELECT ID,CN_ShipTo_Address_ID__c,CN_City_CN__r.CN_City_Code__c,
		CN_Contact_Name__c,CN_Customer_Name_EN__c,CN_Delivery_Address_EN__c,CN_Delivery_Address_CN__c,CN_Delivery_Plant__c,
		CN_Indirect_Account__r.CN_MG_Account_ID__c,
		CN_Mobile_Phone__c,CN_Province_CN__r.CN_Province_EN__c,CN_Province_CN__r.Province_Code__c,CN_Customer_Name__c,
		CN_Sold_To_Party_Customer__r.CN_MG_Account_ID__c,
		CN_Sold_To_Party_Customer__r.CN_Lead_MG_Contact_Id__c,
		CN_UP_Code__c,CN_Post_Code__c,
		CN_Telephone__c,CN_Inactive__c FROM CN_Ship_to_Party__c
		WHERE CN_Need_Send_MG__c = true
		AND CN_Sold_To_Party_Customer__r.CN_Account_Source__c = :Constants.CN_ACCOUNT_SOURCE_ECOMMERCE
		AND CN_UP_Code__c != null
		ORDER BY LastModifiedDate DESC
		];

		return newList;
	}

	public void execute(Database.BatchableContext bc, List<SObject> shipToList){
		List<CN_Ship_to_Party__c> sendSuccess =  CN_ShipTo_Upsert_To_Mg_Callout.upsertShipToAddress((List<CN_Ship_to_Party__c>) shipToList);
		if(sendSuccess.size() > 0){
			try {
				update sendSuccess;
			} catch (Exception e){
				CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
				log.SetResult(0,'DML Exception' + e.getMessage(),e.getStackTraceString() + e.getCause());
				log.Save();
			}
		}
	}

	public void finish(Database.BatchableContext bc) {

	}
}
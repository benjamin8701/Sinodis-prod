/*
 * ************************************************************************************************
 * Name : CN_Campaign_Upsert_To_Mg_Batch
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/17
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Campaign_Upsert_To_Mg_Batch implements Database.batchable<SObject>, Database.AllowsCallouts{

	public Iterable<SObject> start(Database.BatchableContext bc) {
		return [
				SELECT
						Id,CN_Product_Type__c,
						CN_Brand__c,CN_Product_Category__c,
						Type,Name,StartDate,EndDate,Status,CN_Execution_Type__c,
						Description,CN_New_Product_Launch__c,
						CN_Number_of_Audiences__c,ParentId,CN_Channel__c,CN_Customer_Category__c,
						OwnerId
				FROM Campaign
				WHERE CN_Need_Send_MG_Flag__c != 0
				ORDER BY LastModifiedDate ASC ];
	}

	public void execute(Database.BatchableContext bc, List<SObject> batchObjects) {
		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();
		Map<String,Campaign> ltCampaigns = CN_Campaign_Upsert_To_Mg_Callout.sendMgCampaign((List<Campaign>)batchObjects,listLog );
		// add by Zhange ZhiHao Insert log 2024/4/2
        //update listLog;
        upsert listLog;
        // add by Zhange ZhiHao Insert log 2024/4/2
		update ltCampaigns.values();
	}

	public void finish(Database.BatchableContext bc) {
	}

}
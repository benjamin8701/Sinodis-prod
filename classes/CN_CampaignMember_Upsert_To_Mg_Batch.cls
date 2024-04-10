/*
 * ************************************************************************************************
 * Name : CN_CampaignMember_Upsert_To_Mg_Batch
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
public class CN_CampaignMember_Upsert_To_Mg_Batch implements Database.batchable<SObject>, Database.AllowsCallouts{

	public Iterable<SObject> start(Database.BatchableContext bc) {
		return [SELECT Id FROM Campaign WHERE CN_Need_Send_Childrens_MG_Flag__c = 1 ORDER BY LastModifiedDate ASC];
	}

	public void execute(Database.BatchableContext bc, List<SObject> batchObjects) {
		Set<Id> setPIds = new Set<Id>();
		for (SObject item : batchObjects) {
			setPIds.add(item.Id);
		}
		List<CampaignMember> ltChildrens = [SELECT Id, CampaignId, Account.CN_Customer_Code__c, Campaign.Owner.Name FROM CampaignMember WHERE CampaignId IN :setPIds];
		CN_CampaignMember_Upsert_To_Mg_Callout.sendMgCampaignMember(ltChildrens);
	}

	public void finish(Database.BatchableContext bc) {

	}
}
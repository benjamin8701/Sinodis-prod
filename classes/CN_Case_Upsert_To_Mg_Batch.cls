/*
 * ************************************************************************************************
 * Name : CN_Case_Upsert_To_Mg_Batch
 * Description :
 * Object :
 * Requirement : CP-003
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/17
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Case_Upsert_To_Mg_Batch implements Database.batchable<SObject>, Database.AllowsCallouts{

	public Iterable<SObject> start(Database.BatchableContext bc) {
		return [SELECT Id, Status,CN_Actual_Return_Consistent_Status__c, CN_MG_Case_Id__c,CN_CS_Feedback__c FROM Case WHERE CN_Need_Send_MG_Flag__c != NULL AND CN_Need_Send_MG_Flag__c != 0 AND CN_MG_Case_Id__c != NULL ORDER BY LastModifiedDate ASC];
	}

	public void execute(Database.BatchableContext bc, List<SObject> batchObjects) {
		CN_Case_Upsert_To_Mg_Callout.sendMgCaseStatus((List<Case>)batchObjects);
	}

	public void finish(Database.BatchableContext bc) {
	}

}
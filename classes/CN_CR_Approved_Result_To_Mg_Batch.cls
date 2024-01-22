/*
 * ************************************************************************************************
 * Name : CN_CR_Approved_Result_To_Mg_Batch
 * Object :
 * Requirement : AC-010 Only synchronous ShipTo CR when ShipTo Information synchronous succeed
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/27
 * Modify History :
 * ************************************************************************************************
 */
public class CN_CR_Approved_Result_To_Mg_Batch
	implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{

	public Iterable<SObject> start(Database.BatchableContext bc) {
		List<String> idList = new List<String>();
		Id crRTIdNewAppd = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
		Id crRTIdNew = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();
		Id crRTIdUpdateAppd = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_SHIPTO).getRecordTypeId();
		Id crRTIdUpdate = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
		Id crRTIdInactiveAppd = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_INACTIVE_SHIPTO).getRecordTypeId();
		Id crRTIdInactive = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_INACTIVE_SHIPTO).getRecordTypeId();
		idList.add(crRTIdNew);
		idList.add(crRTIdNewAppd);
		idList.add(crRTIdUpdate);
		idList.add(crRTIdUpdateAppd);
		idList.add(crRTIdInactive);
		idList.add(crRTIdInactiveAppd);
		List<CN_Change_Request__c> newList = [
				SELECT ID,
				CN_ShipTo_Address_ID__c,
				CN_Approved_Status__c,
				CN_Ship_To_Party__r.CN_Need_Send_MG__c
				FROM CN_Change_Request__c
				WHERE CN_Need_Send_MG_Flag__c = 1
				AND CN_ShipTo_Address_ID__c != NULL
				AND CN_Approved_Status__c != 2
				AND CN_CR_Source__c = :Constants.CN_CR_SOURCE_ECOMMERCE
				AND RecordTypeId IN :idList
				AND CN_Ship_to_Party__c != null
				AND CN_Ship_To_Party__r.CN_Need_Send_MG__c = false
				AND CN_Change_Request_Status__c != :Constants.CN_CR_STATUS_READY_FOR_APPROVAL
				ORDER BY LastModifiedDate DESC
		];
		List<CN_Change_Request__c> rejList = [
				SELECT ID,
						CN_ShipTo_Address_ID__c,
						CN_Approved_Status__c,
						CN_Ship_To_Party__r.CN_Need_Send_MG__c
				FROM CN_Change_Request__c
				WHERE CN_Need_Send_MG_Flag__c = 1
				AND CN_ShipTo_Address_ID__c != NULL
				AND CN_CR_Source__c = :Constants.CN_CR_SOURCE_ECOMMERCE
				AND RecordTypeId IN :idList
				AND CN_Approved_Status__c = 2
				AND CN_Change_Request_Status__c != :Constants.CN_CR_STATUS_READY_FOR_APPROVAL
				ORDER BY LastModifiedDate DESC
		];
		newList.addAll(rejList);

		return newList;
	}

	public void execute(Database.BatchableContext bc, List<SObject> shipToList){
		System.debug(shipToList);
		List<CN_Change_Request__c> sendSuccess =  CN_CR_Approved_Result_To_Mg_Callout.sendResultToMg((List<CN_Change_Request__c>) shipToList);
		if(sendSuccess.size() > 0){
			update sendSuccess;
		}
	}

	public void finish(Database.BatchableContext bc) {

	}
}
/*
 * ************************************************************************************************
 * Name : CN_Lead_Upsert_To_Mg_Batch
 * Object :
 * Requirement : LD-003
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/7/4
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Lead_Upsert_To_Mg_Batch implements Database.batchable<SObject>, Database.AllowsCallouts{
	public Iterable<SObject> start(Database.BatchableContext bc) {
		List<Lead> leads = [SELECT Id,Status,
		CN_UniqueId__c,
		CN_Status_Change_Records__c,
		CN_Owner_Employee_Number__c,
		OwnerId,
		CN_MG_Account_ID__c,
		Owner.Email,
		CN_Field_Lock__r.CN_Need_Send_MG_Flag__c
		FROM Lead
		WHERE CN_Field_Lock__r.CN_Need_Send_MG_Flag__c = 1
		AND LeadSource = :Constants.CN_LEAD_SOURCE_ECOMMERCE
		// add by  Zhang Zhihao 2023.12.31 Cancels the filter state transition
		//AND IsConverted = false
		// add by  Zhang Zhihao 2023.12.31 Cancels the filter state transition
		// AND Status != 'Closed - Dead'
		ORDER BY LastModifiedDate DESC ];

		return leads;
	}

	public void execute(Database.BatchableContext bc, List<SObject> leadList) {
		// add by  Zhang Zhihao 2023.11.03 Update tag status and lead old status	
		List<Lead> leads = (List<Lead>)leadList;
		// add by  Zhang Zhihao 2023.11.03 Update tag status and lead old status	
		List<Map<String,Object>> mapList = new List<Map<String, Object>>();
		for(Lead item:leads){
			Map<String,Object> paramMap = new Map<String, Object>();
			paramMap.put('id',item.Id);
			paramMap.put('uniqueId',item.CN_UniqueId__c);
			paramMap.put('owner',item.CN_Owner_Employee_Number__c);
			paramMap.put('status',item.Status);
			paramMap.put('sale_email',item.Owner.Email);

			List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg> lists = (List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>)JSON.deserialize(
					String.valueOf(item.CN_Status_Change_Records__c),
							List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>.class
			);

			// add by  Zhang Zhihao 2023.12.14 customer status
			if(item.Status == Constants.CN_LEAD_STATUS_CLOSED_CONVERTED) {
				paramMap.put('transition_status','已转换');
				List<CN_Change_Request__c> changeLists = [SELECT id,New_CN_Contact_License_Name__c FROM CN_Change_Request__c WHERE CN_From_Lead__c = :item.Id LIMIT 1];
				if(changeLists.size() > 0) {
					paramMap.put('account_status','老客户');
					String newCNContactLicenseName = changeLists[0].New_CN_Contact_License_Name__c;		
					if(String.isNotBlank(newCNContactLicenseName)) {
						List<Account> accountList = [SELECT id,CN_MG_Account_ID__c FROM Account WHERE id = :newCNContactLicenseName LIMIT 1];	
						if(accountList.size() > 0) {
							paramMap.put('mgAccountID', accountList[0].CN_MG_Account_ID__c);
						}
					}
				} else {
					paramMap.put('account_status','新客户');
					paramMap.put('mgAccountID', item.CN_MG_Account_ID__c);
				}
			} else {
				paramMap.put('transition_status','未转换');
			}
			// add by  Zhang Zhihao 2023.12.14 customer status

			paramMap.put('oldStatus',lists);
			mapList.add(paramMap);
		}
		// add by  Zhang Zhihao 2023.11.03 Update tag status and lead old status	
		if(mapList.size()>0){
			List<Lead> sendSuccess = CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatus(mapList);
			Set<Id> fieldLockIds = new Set<Id>();
			List<CN_Field_Lock__c>  fieldLockList =new List<CN_Field_Lock__c>();
			Set<Id> leadIds = new Set<Id>();
			if(sendSuccess.size() > 0){
				for (Lead next : sendSuccess) {
					next.CN_Status_Change_Records__c = '';
					// next.CN_Need_Send_MG_Flag__c = 0;
					leadIds.add(next.id);
				}
				List<CN_Field_Lock__c> CN = [SELECT id,name FROM 	CN_Field_Lock__c  ];
				List<Lead> leadFieldLockId = [SELECT CN_Field_Lock__c FROM 	Lead   where id in :leadIds];
				for(Lead lead :leadFieldLockId){
					if(lead.CN_Field_Lock__c!=null){
						fieldLockIds.add(lead.CN_Field_Lock__c);
					}
				}	
				for(String id: fieldLockIds){
					CN_Field_Lock__c fieldLock = new CN_Field_Lock__c();
					fieldLock.id=id;
					fieldLock.CN_Need_Send_MG_Flag__c=0;
					fieldLockList.add(fieldLock);
				}
				if(fieldLockList.size()>0){
					update fieldLockList;
				}
				 //update sendSuccess;
			}
		// add by  Zhang Zhihao 2023.11.03 Update tag status and lead old status	
		}
	}

	public void finish(Database.BatchableContext param1) {

	}



}
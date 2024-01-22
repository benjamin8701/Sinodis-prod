/*
 * ************************************************************************************************
 * Name : CN_Lead_Status_Send_Mg_Handler
 * Description : 1：Notify E-Commerce Status Change
 * Object :
 * Requirement :LD-003
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/8/1
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_Lead_Status_Send_Mg_Handler implements Triggers.Handler{
	public void handle() {
		if(Trigger.isBefore && Trigger.isUpdate) {
			beforeUpdateHandle();
		}
		if(Trigger.isBefore && Trigger.isInsert) {
			beforeInsertHandle();
		}
		//add by  Zhang Zhihao 2023.11.03 trigger
		if(Trigger.isAfter && Trigger.isUpdate) {
			afterUpdateHandle();
		}
		if(Trigger.isAfter && Trigger.isInsert){
			afterInsertHandle();
		}
		//add by  Zhang Zhihao 2023.11.03 trigger
	}

	private void beforeInsertHandle() {
		List<Lead> needSendLead = new List<Lead>();
		List<CN_Field_Lock__c> fieldLocks = new List<CN_Field_Lock__c>();
		for(Lead lead: (List<Lead>)Trigger.new) {
			//only mark E-Commerce Lead
			if (lead.LeadSource != Constants.CN_LEAD_SOURCE_ECOMMERCE){
				continue;
			}
			needSendLead.add(lead);
		}
		//add by  Zhang Zhihao 2023.11.03 Assign a tag object to the lead
		for(Lead item : needSendLead){
			CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
			fieldLocks.add(fieldLock);
		}
		if(!fieldLocks.isEmpty()){
			insert fieldLocks;
			for (Integer i = 0; i < needSendLead.size(); i++) {
				if (i < fieldLocks.size()) {
					needSendLead[i].CN_Field_Lock__c = fieldLocks[i].Id;
				}
			}
		}
		//add by  Zhang Zhihao 2023.11.03 Assign a tag object to the lead

		//add by  Zhang Zhihao 2023.11.03 current state
		for (Lead item:needSendLead){
			List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg> lists = new List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>();
			CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg leadStatusMsg = new CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg();
			leadStatusMsg.status = null;
			leadStatusMsg.owner = item.CN_Owner_Employee_Number__c;
			leadStatusMsg.uniqueId = item.CN_UniqueId__c;
			leadStatusMsg.updateDate = String.valueOf(Datetime.now());
			lists.add(leadStatusMsg);
			item.CN_Status_Change_Records__c = JSON.serialize(lists);
		}
		//add by  Zhang Zhihao 2023.11.03 current state
	}



	private void beforeUpdateHandle() {
		Set<Id> needSendId = new Set<Id>();
		for(Lead lead: (List<Lead>)Trigger.new) {
			if (lead.LeadSource != Constants.CN_LEAD_SOURCE_ECOMMERCE){
				continue;
			}
			Lead oldLead = (Lead)Trigger.oldMap.get(lead.Id);
			//add by  Zhang Zhihao 2023.11.03 Push condition
			if (lead.Status == oldLead.Status&&lead.OwnerId==oldLead.OwnerId){
				continue;
			}
			//add by  Zhang Zhihao 2023.11.03 Push condition
			needSendId.add(lead.Id);

		}
		List<Lead> needSend = [SELECT Id,CN_Owner_Employee_Number__c,CN_Status_Change_Records__c,Owner.Email, CN_Field_Lock__c FROM Lead WHERE Id in :needSendId];
		//add by  Zhang Zhihao 2023.11.03 Tag object id
		Set<Id> fieldLockIds =  new Set<Id>();
		List<Lead> emptyFieldLockLead =  new List<Lead>();
		List<CN_Field_Lock__c> fieldLocks = new List<CN_Field_Lock__c>();
		//add by  Zhang Zhihao 2023.11.03 Tag object id
		for (Lead item:needSend){
			List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg> lists;
			if (String.isEmpty(item.CN_Status_Change_Records__c)){
				lists = new List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>();
			} 
			else{
				lists = (List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>)JSON.deserialize(
					String.valueOf(item.CN_Status_Change_Records__c),
							List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>.class
				);
			}
			CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg leadStatusMsg = new CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg();
			Lead newLead = (Lead)Trigger.newMap.get(item.Id);
			Lead oldLead = (Lead)Trigger.oldMap.get(item.Id);

			leadStatusMsg.status = newLead.Status;
			leadStatusMsg.oldStatus = oldLead.Status;
			leadStatusMsg.owner = item.CN_Owner_Employee_Number__c;
			leadStatusMsg.uniqueId = newLead.CN_UniqueId__c;
			leadStatusMsg.updateDate = String.valueOf(Datetime.now());
			//add by  Zhang Zhihao 2023.11.03 Sales email
			leadStatusMsg.sale_email = item.Owner.Email;
			//add by  Zhang Zhihao 2023.11.03 Sales email
			lists.add(leadStatusMsg);
			newLead.CN_Status_Change_Records__c = JSON.serialize(lists);			
			//add by  Zhang Zhihao 2023.11.03 Tag object id
			if(item.CN_Field_Lock__c != null){
				fieldLockIds.add(item.CN_Field_Lock__c);
			}else{
				emptyFieldLockLead.add(item);
				CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
				fieldLocks.add(fieldLock);
			}
			//add by  Zhang Zhihao 2023.11.03 Tag object id

		}

		//add by  Zhang Zhihao 2023.11.03 modify the mark

		if(fieldLockIds.size()>0){
			List<CN_Field_Lock__c> fieldLockList = [SELECT Id, CN_Need_Send_MG_Flag__c FROM CN_Field_Lock__c  where id in :fieldLockIds];
				for(CN_Field_Lock__c item :fieldLockList){
					item.CN_Need_Send_MG_Flag__c= 1;
				}
			update fieldLockList;
		}


		if(!fieldLocks.isEmpty()){
			insert fieldLocks;
			for (Integer i = 0; i < emptyFieldLockLead.size(); i++) {
				if (i < fieldLocks.size()) {
					Lead leadRecord = (Lead)Trigger.newMap.get(emptyFieldLockLead[i].Id);
					leadRecord.CN_Field_Lock__c = fieldLocks[i].Id;
				}
			}
		}
		//add by  Zhang Zhihao 2023.11.03 modify the mark

	}


	// add by  Zhang Zhihao 2023.11.03 Real-time push
	private void  afterUpdateHandle(){

		if(System.IsBatch()|| System.isFuture()){
			return ;
		 }

		Set<Id> needSendId = new Set<Id>();
		for(Lead lead: (List<Lead>)Trigger.new) {
			if (lead.LeadSource != Constants.CN_LEAD_SOURCE_ECOMMERCE){
				continue;
			}	
			Lead oldLead = (Lead)Trigger.oldMap.get(lead.Id);
			if (lead.Status == oldLead.Status&&lead.OwnerId==oldLead.OwnerId){
				continue;
			}
			needSendId.add(lead.Id);
		}



		List<Lead> leads = [SELECT Id,Status,Name,
		CN_UniqueId__c,
		CN_Status_Change_Records__c,
		CN_Owner_Employee_Number__c,
		OwnerId,
		Owner.Email,
		CN_MG_Account_ID__c,
		CN_Field_Lock__c,
		CN_Field_Lock__r.CN_Need_Send_MG_Flag__c
		FROM Lead
		WHERE id in :needSendId
		ORDER BY LastModifiedDate DESC ];

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
		if(mapList.size()>0){
			CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatusRealTime(JSON.serialize(mapList));
		}
	}
	// add by  Zhang Zhihao 2023.11.03 Real-time push


	
	// add by  Zhang Zhihao 2023.11.03 Real-time push
	private void  afterInsertHandle(){
		if(System.IsBatch()|| System.isFuture()){
			return ;
		 }
		Set<Id> needSendId = new Set<Id>();
		for(Lead lead: (List<Lead>)Trigger.new) {
			if (lead.LeadSource != Constants.CN_LEAD_SOURCE_ECOMMERCE){
				continue;
			}
			needSendId.add(lead.Id);
		}

		
		List<User> adminUsers = [SELECT Id, Name
		FROM User
		WHERE Profile.Name IN ('系统管理员', 'System Integration')];

		Set<Id> adminUserIds = new Set<Id>();
		for(User user : adminUsers) {
			adminUserIds.add(user.Id);
		}

		List<Lead> leads = new List<Lead>();
		for(Lead lead : [SELECT Id, Status, Name, CN_UniqueId__c, CN_Status_Change_Records__c, CN_Owner_Employee_Number__c, OwnerId, Owner.Email, CN_Field_Lock__r.CN_Need_Send_MG_Flag__c
						FROM Lead
						WHERE Id IN :needSendId
						ORDER BY LastModifiedDate DESC]) {
			if(!(adminUserIds.contains(lead.OwnerId))) {
			 	leads.add(lead);
			}
		}

		List<Map<String,Object>> mapList = new List<Map<String, Object>>();
		for(Lead item:leads){	
			Map<String,Object> paramMap = new Map<String, Object>();
			paramMap.put('id',item.Id);
			paramMap.put('uniqueId',item.CN_UniqueId__c);
			paramMap.put('owner',item.CN_Owner_Employee_Number__c);
			paramMap.put('status',item.Status);
			paramMap.put('sale_email',item.Owner.Email);
			// add by  Zhang Zhihao 2023.12.14 customer status
			paramMap.put('transition_status','未转换');
			// add by  Zhang Zhihao 2023.12.14 customer status
			List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg> lists;
			if (String.isEmpty(item.CN_Status_Change_Records__c)){
				lists = new List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>();
			} 
			else{
				lists = (List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>)JSON.deserialize(
						String.valueOf(item.CN_Status_Change_Records__c),
								List<CN_Lead_Upsert_To_Mg_Callout.LeadStatusMsg>.class
				);
			}
			
			paramMap.put('oldStatus',lists);
			mapList.add(paramMap);
		}		
		if(mapList.size()>0){
			CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatusRealTime(JSON.serialize(mapList));
		}
	}
	// add by  Zhang Zhihao 2023.11.03 Real-time push

}
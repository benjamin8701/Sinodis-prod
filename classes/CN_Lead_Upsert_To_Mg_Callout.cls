/*
 * ************************************************************************************************
 * Name : CN_Lead_Upsert_To_Mg_Callout
 * Object :
 * Requirement : LD-003
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/7/4
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Lead_Upsert_To_Mg_Callout {
	public static List<Lead> sendMgLeadStatus(List<Map<String,Object>> mapList){

		Talend_Setting__c setting = Talend_Setting__c.getInstance();

		Http http = new Http();
		// HttpRequest request = new HttpRequest();
		HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
				setting.Sandbox_MG_Update_Lead_Status__c,
				setting.MG_Update_Lead_Status__c);

		List<Lead> sendSuccess = new List<Lead>();
		//Callout portion
		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();

		for(Map<String,Object> item:mapList){
			CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
			try {
				String body = JSON.serialize(item);
				log.SetRequest(body);

				String id = String.valueOf(item.get('id'));
				request.setBody(body);
				System.debug(request.getEndpoint());
				System.debug(body);
				HttpResponse response = http.send(request);
				// Parse the JSON response
				String data = Json.serialize(response.getBody());
				log.SetResponse(data);
				Integer resCode = response.getStatusCode();

				String errorMsg = '';
				String errorMessage = '';
				Lead lead = new Lead();
				lead.ID = id;

				if(resCode == 200) {
					sendSuccess.add(lead);
					//Successful call

				}else {
					if(resCode == 503) {
						errorMessage = 'Service Unavailable';
					}else if(resCode == 500) {
						errorMessage = 'Server Error';
					} else if(resCode == 404) {
						errorMessage = 'API Path Error';
					}else{
						errorMessage = 'Others Error';
					}
				}

				errorMsg = resCode + ':' + errorMessage + ':' + data;
				log.SetResult(resCode, JSON.serialize(lead), errorMsg);
				listLog.add(log.getLog());
			} catch (Exception e){
				System.debug('error=============='+e.getMessage());
				log.SetResult(0,null,e.getMessage());
				listLog.add(log.getLog());
			}

		}
		insert listLog;

		return sendSuccess;
	}



	// add by  Zhang Zhihao 2023.11.03 Update tag status and lead old status	
	@Future(callout=true)
    public static void sendMgLeadStatusRealTime(String args){
		List<Object> objectList = (List<Object>) JSON.deserializeUntyped(args);
		List<Map<String, Object>> mapList = new List<Map<String, Object>>();
		for (Object obj : objectList) {
			mapList.add((Map<String, Object>) obj);
		}

		List<Lead> sendSuccess = CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatus(mapList);
		Set<Id> fieldLockIds = new Set<Id>();
		List<CN_Field_Lock__c>  fieldLockList =new List<CN_Field_Lock__c>();
		Set<Id> leadIds = new Set<Id>();
		if(sendSuccess.size() > 0){
			for (Lead next : sendSuccess) {
				next.CN_Status_Change_Records__c = '';
				leadIds.add(next.id);
			}
			List<Lead> leadFieldLockId = [SELECT CN_Field_Lock__c FROM 	Lead   where id in :leadIds];
			for(Lead lead :leadFieldLockId){
				if(lead.CN_Field_Lock__c!=null){
					fieldLockIds.add(lead.CN_Field_Lock__c);
				}
			}
				for(String id : fieldLockIds){
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
}
	// add by  Zhang Zhihao 2023.11.03 Update tag status and lead old status	




	public class LeadStatusMsg{
//		public String leadId;
		public String status;
		public String oldStatus;
		public String owner;
		public String sale_email;
		public String uniqueId;
		public String updateDate;
	}
}
/*
 * ************************************************************************************************
 * Name : CN_Arrival_Reminder_to_Mg_Callout
 * Object :
 * Requirement : AR-002
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/7/28
 * Modify History :
 * ************************************************************************************************
 */
public without sharing class CN_Arrival_Reminder_to_Mg_Callout {
	@AuraEnabled
	public static String sendMgArrivalStatus(String arrivalReminderIdString) {
		System.debug(arrivalReminderIdString);
		Id arrivalReminderId = (arrivalReminderIdString != null) ? (Id.valueOf(arrivalReminderIdString)) : null;
		List<CN_Arrival_Reminder__c> reminders = [SELECT Id, CN_SKU_ID__c, CN_Contact__r.CN_MG_Contact_ID__c, CN_Warehouse__c, CN_Area__c, CN_Email_Send__c
		FROM CN_Arrival_Reminder__c
		WHERE Id = :arrivalReminderId
		LIMIT 1];

		CN_Arrival_Reminder__c reminder = reminders[0];
		if (reminder.CN_Email_Send__c == 'Y') {
			return 'Already notified';
		}
		String cnSkuId = reminder.CN_SKU_ID__c;
		String cnContact = reminder.CN_Contact__r.CN_MG_Contact_ID__c;
		String cnWarehouse = reminder.CN_Warehouse__c;
		String cnArea = reminder.CN_Area__c;

		Talend_Setting__c setting = Talend_Setting__c.getInstance();

		List<CN_Arrival_Reminder__c> sendSuccess = new List<CN_Arrival_Reminder__c>();
		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();

		Map<String, Object> requestBody = new Map<String, Object>();

		requestBody.put('sku', cnSkuId);
		requestBody.put('customerId', cnContact);
		requestBody.put('warehouse', cnWarehouse);
		requestBody.put('area', cnArea);

		String requestBodyJson = JSON.serialize(requestBody);
		System.debug('requestBodyJson:' + requestBodyJson);
		Http http = new Http();
		// HttpRequest request = new HttpRequest();
		HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
				setting.Sandbox_MG_Send_WeChat_Message__c,
				setting.MG_Send_WeChat_Message__c);

		String id = arrivalReminderIdString;
		String notifyTriggered = 'Y';
		CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
		String errorMessage = '';
		System.debug(request.getEndpoint());
		System.debug('requestBodyJson:' + requestBodyJson);
		request.setBody(requestBodyJson);
		HttpResponse response = http.send(request);
		System.debug(response);
		System.debug(response.getBody());
		// Parse the JSON response
		String data = Json.serialize(response.getBody());
		Integer resCode = response.getStatusCode();
		String errorMsg = '';
		String jsonResponse = '';
		String responseBody = response.getBody();
		System.debug('responseBody:' + responseBody);

		Map<String, Object> resultMap = new Map<String, Object>();
		if (response.getStatusCode() == 200) {
			Integer code = CN_HelperClass_WS.getRetDataCode(responseBody);
			if (code == 1) {
				System.debug(response.getBody());
				CN_Arrival_Reminder__c arrred = new CN_Arrival_Reminder__c();
				arrred.ID = id;
				arrred.CN_Email_Send__c = notifyTriggered;
				sendSuccess.add(arrred);
				update sendSuccess;
				resultMap.put('code', code);
				resultMap.put('msg', 'OK');
				jsonResponse += JSON.serialize(resultMap);
			} else {

				ResponseWrapper responseWrapper =
						(ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
				System.debug('responseWrapper:' + responseWrapper);
				resultMap.put('code', responseWrapper.message[0].code);
				resultMap.put('msg', responseWrapper.message[0].msg);
				resultMap.put('retData', responseWrapper.message[0].retData);
				jsonResponse += JSON.serialize(resultMap);
			}
		} else {
			if (resCode == 503) {
				System.debug(resCode + ':' + data);
			} else {
				if (resCode == 500) {
					errorMessage = 'Server Error';
				} else if (resCode == 404) {
					errorMessage = 'API Path Error';
				}
				errorMsg = resCode + ':' + errorMessage + ':' + data;
			}
		}
		System.debug(errorMsg);
		System.debug('jsonResponse:' + jsonResponse);
		log.SetRequest(requestBodyJson);
		log.SetResult(resCode, data, errorMessage);
		log.SetResponse(data);
		listLog.add(log.getLog());

		insert listLog;

		return jsonResponse;

	}


	@AuraEnabled(cacheable = true)
	public static List<CN_Arrival_Reminder__c> sendMgArrivalStatusList(List<String> mapList) {
		System.debug('maplist' + maplist);
		List<CN_Arrival_Reminder__c> reminders = [SELECT Id, Name,
		CN_SKU_ID__c, CN_Contact__r.CN_MG_Contact_ID__c,
		CN_Warehouse__c, CN_Area__c, CN_feedback__c, CN_Email_Send__c
		FROM CN_Arrival_Reminder__c
		WHERE Id IN :mapList];

		Talend_Setting__c setting = Talend_Setting__c.getInstance();

		List<CN_Arrival_Reminder__c> sendSuccess = new List<CN_Arrival_Reminder__c>();

		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();

		String jsonResponse = '';
		for (CN_Arrival_Reminder__c reminder : reminders) {
			if (reminder.CN_Email_Send__c == 'Y') {
				reminder.CN_ArName__c = reminder.Name;
				reminder.CN_feedback__c = 'Already notified';
				sendSuccess.add(reminder);
				continue;
			}
			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('sku', reminder.CN_SKU_ID__c);
			requestBody.put('customerId', reminder.CN_Contact__r.CN_MG_Contact_ID__c);
			requestBody.put('warehouse', reminder.CN_Warehouse__c);
			requestBody.put('area', reminder.CN_Area__c);
			try {
				String requestBodyJson = JSON.serialize(requestBody);
				Http http = new Http();
				HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
						setting.Sandbox_MG_Send_WeChat_Message__c,
						setting.MG_Send_WeChat_Message__c);

				request.setBody(requestBodyJson);
				HttpResponse response = http.send(request);

				CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
				String errorMessage = '';
				System.debug(request.getEndpoint());
				System.debug('requestBodyJson:' + requestBodyJson);
				System.debug(response);
				System.debug(response.getBody());
				// Parse the JSON response
				String data = Json.serialize(response.getBody());
				Integer resCode = response.getStatusCode();
				String errorMsg = '';
				String responseBody = response.getBody();
				System.debug('responseBody:' + responseBody);

				if (response.getStatusCode() == 200) {

					Integer code = CN_HelperClass_WS.getRetDataCode(responseBody);

					CN_Arrival_Reminder__c arrRed = new CN_Arrival_Reminder__c();
					arrRed.ID = reminder.Id;
					arrRed.CN_ArName__c = reminder.Name;
					if (code == 0) {
						ResponseWrapper responseWrapper =
								(ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
						System.debug('responseWrapper:' + responseWrapper);
						arrRed.CN_feedback__c = responseWrapper.message[0].msg;
						arrRed.CN_Email_Send__c = 'N';
						sendSuccess.add(arrRed);
					} else {
						arrRed.CN_feedback__c = 'OK';
						arrRed.CN_Email_Send__c = 'Y';
						sendSuccess.add(arrRed);
					}


				} else if (resCode == 503) {
					System.debug(resCode + ':' + data);
				} else {
					if (resCode == 500) {
						errorMessage = 'Server Error';
					} else if (resCode == 404) {
						errorMessage = 'API Path Error';
					}
					errorMsg = resCode + ':' + errorMessage + ':' + data;
				}
				System.debug(errorMsg);
				log.SetRequest(requestBodyJson);
				log.SetResult(resCode, data, errorMessage);
				log.SetResponse(data);
				listLog.add(log.getLog());

				System.debug('sendSuccess:' + sendSuccess);
			} catch (Exception e) {
				System.debug('Exception occurred during iteration: ' + e.getMessage());
			}
		}
		//add by He Peng insert logs Future
        insertLogFuture(JSON.serialize(listLog));

		System.debug(sendSuccess.size());
		if(sendSuccess.size()>0){
		    updateRecordsMethod(JSON.serialize(sendSuccess));
		    }
		return sendSuccess;
	}

	@Future
	public static void updateRecordsMethod(String remindersToUpdate) {
		List<CN_Arrival_Reminder__c> reminderList =
				(List<CN_Arrival_Reminder__c>)JSON.deserialize(remindersToUpdate, List<CN_Arrival_Reminder__c>.class);
		update reminderList;
	}

    @Future
    public static void insertLogFuture(String listLogStr) {
        List<CN_API_Call_Logger__c> listLog =
                (List<CN_API_Call_Logger__c>)JSON.deserialize(listLogStr, List<CN_API_Call_Logger__c>.class);
        insert listLog;
    }

	class ResponseData{
		Integer code;
		String msg;
		Map<String, Object> retData;
		// List<Object> retData;
	}

	class ResponseWrapper {
		Integer code;
		List<ResponseData> message;
	}

}
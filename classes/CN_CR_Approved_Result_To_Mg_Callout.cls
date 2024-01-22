/*
 * ************************************************************************************************
 * Name : CN_CR_Approved_Result_To_Mg_Callout
 * Object :
 * Requirement :AC-010
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/27
 * Modify History :
 * ************************************************************************************************
 */
public class CN_CR_Approved_Result_To_Mg_Callout {

	public static List<CN_Change_Request__c> sendResultToMg(List<CN_Change_Request__c> crList){

		//handleDataList
		List<Map<String, Object>> maps = handleData(crList);

		//Necessary parameters for assembly request
		Talend_Setting__c setting = Talend_Setting__c.getInstance();
		Http http = new Http();
		HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
				setting.Sandbox_MG_Approval_Lead__c,
				setting.MG_Approval_Lead__c);

		List<CN_Change_Request__c> sendSuccess = new List<CN_Change_Request__c>();
		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();
		for(Map<String,Object> bodyObj:maps){

			CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
			try {

				String id = bodyObj.get('ID').toString();
				bodyObj.remove('ID');
				String body = Json.serialize(bodyObj);
				request.setBody(body);
				log.SetRequest(body);

				HttpResponse response = http.send(request);
				log.SetResponse(response.getBody());

				// Parse the JSON response
				Integer resCode = response.getStatusCode();

				String errorMsg = '';
				String errorMessage = '';
				if(resCode == 200) {
					Integer code = CN_HelperClass_WS.getRetDataCode(response.getBody());
					System.debug(JSON.serialize(code));

					if( code == 1){
						CN_Change_Request__c cr = new CN_Change_Request__c();
						cr.ID = id;
						cr.CN_Need_Send_MG_Flag__c = 0;
						sendSuccess.add(cr);
					}

//					CN_Change_Request__c cr = new CN_Change_Request__c();
//					cr.ID = id;
//					cr.CN_Need_Send_MG_Flag__c = 0;
//					sendSuccess.add(cr);

				}else {
					if(resCode == 500) {
						errorMessage = 'Server Error';
					} else if(resCode == 404) {
						errorMessage = 'API Path Error';
					} else if(resCode == 503) {
						errorMessage = 'Server Error';
					}
						errorMsg = resCode + ':' + errorMessage + ':' + response.getBody();
				}
				log.SetResult(resCode, response.getBody(), errorMessage);
				listLog.add(log.getLog());
			} catch (Exception e){
				System.debug(e.getCause());
				System.debug(e.getMessage());
				System.debug(e.getStackTraceString());
				System.debug(e.getLineNumber());
				log.SetResult(0, '', e.getMessage());
				listLog.add(log.getLog());
			}

		}

		insert listLog;
		return sendSuccess;
	}

	private static List<Map<String, Object>> handleData(List<CN_Change_Request__c> crList) {
		List<Map<String,Object>> maps = new List<Map<String,Object>>();
		System.debug(JSON.serialize(crList));
		for(CN_Change_Request__c cr : crList){
			Map<String,Object> mapItem= new Map<String,Object>();


			mapItem.put('union_id' ,Integer.valueOf(cr.get('CN_ShipTo_Address_ID__c')));
			mapItem.put('status'   ,cr.get('CN_Approved_Status__c'));
			mapItem.put('type'     ,'ship_to');//business key

			Map<String,Object> body = new Map<String,Object>();
			body.put('data',mapItem);
			body.put('ID',cr.Id); //转换后获得Map的Key，用于返回sendSuccess

			maps.add(body);
		}
		return maps;
	}
}
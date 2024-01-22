/*
 * ************************************************************************************************
 * Name : CN_ShipTo_Upsert_To_Mg_Callout
 * Object :
 * Requirement : AC-009
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/4
 * Modify History :
 * ************************************************************************************************
 */
public class CN_ShipTo_Upsert_To_Mg_Callout {

	public static List<CN_Ship_to_Party__c> upsertShipToAddress(List<CN_Ship_to_Party__c> shipToList){

		//handleDataList
		List<Map<String, Object>> maps = handleData(shipToList);

		//Necessary parameters for assembly request
		Talend_Setting__c setting = Talend_Setting__c.getInstance();
		Http http = new Http();
		HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
				setting.Sandbox_MG_Update_Shipping_Address__c,
				setting.MG_Update_Shipping_Address__c);

		List<CN_Ship_to_Party__c> sendSuccess = new List<CN_Ship_to_Party__c>();
		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();
		for(Map<String,Object> item:maps){
			CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
			try {
				String body = JSON.serialize(item);
				log.SetRequest(body);
				System.debug(body);
				String id = String.valueOf(item.get('MAP_ID'));

				String errorMessage = '';
				request.setBody(body);

				HttpResponse response = http.send(request);
				String data = response.getBody();
				log.SetResponse(data);

				System.debug(data);


				Integer resCode = response.getStatusCode();
				String errorMsg = '';

				if(resCode == 200) {
					CN_HelperClass_WS.Message  cs = CN_HelperClass_WS.getRetData(data);
					System.debug(JSON.serialize(cs));


					if(cs != null && cs.code == 1){

						Map<String,Object> retData = cs.retData;
						if (retData != null && retData.containsKey('address_id')){
							CN_Ship_to_Party__c cnShipToParty = new CN_Ship_to_Party__c();
							cnShipToParty.ID = id;
							cnShipToParty.CN_Need_Send_MG__c = false;
							cnShipToParty.CN_ShipTo_Address_ID__c = String.valueOf(retData.get('address_id'));
							sendSuccess.add(cnShipToParty);
						}

					}

				}else  {
					if(resCode == 503) {
						errorMessage = 'Service Unavailable';
					}else if(resCode == 500) {
						errorMessage = 'Server Error';
					} else if(resCode == 404) {
						errorMessage = 'API Path Error';
					}
				}
				errorMsg = resCode + ':' + errorMessage + ':' + data;

				log.SetResult(resCode, data, errorMsg);
				listLog.add(log.getLog());
			} catch (Exception e){
				System.debug(e.getLineNumber() + ' : ' + e.getCause());
				System.debug(e.getMessage());
				System.debug(e.getStackTraceString());
				log.SetResult(0,'Error',e.getMessage());
				listLog.add(log.getLog());
			}

		}
		insert listLog;

		return sendSuccess;
	}

	private static List<Map<String, Object>> handleData(List<CN_Ship_to_Party__c> shipToList) {

		List<Map<String,Object>> maps = new List<Map<String,Object>>();
		for(CN_Ship_to_Party__c shipTo : shipToList){
			Map<String,Object> mapItem= new Map<String,Object>();

			mapItem.put('MAP_ID',shipTo.Id); //转换后获得Map的Key，用于返回sendSuccess

			mapItem.put('ship_to_address_id',shipTo.CN_ShipTo_Address_ID__c);
			mapItem.put('city',shipTo.CN_City_CN__r.CN_City_Code__c);
			mapItem.put('contact_name',shipTo.CN_Contact_Name__c);
			mapItem.put('delivery_address_en',shipTo.CN_Delivery_Address_EN__c);
			mapItem.put('delivery_address_cn',shipTo.CN_Delivery_Address_CN__c);
			mapItem.put('delivery_plant',shipTo.CN_Delivery_Plant__c);
			mapItem.put('indirect_account',shipTo.CN_Indirect_Account__r.CN_MG_Account_ID__c);
			mapItem.put('mobile_phone',shipTo.CN_Mobile_Phone__c);
			mapItem.put('province_cn',shipTo.CN_Province_CN__r.Province_Code__c);
			mapItem.put('ship_to_name_cn',shipTo.CN_Customer_Name__c);
			mapItem.put('ship_to_name_en',shipTo.CN_Customer_Name_EN__c);
			mapItem.put('sold_to_party_customer',shipTo.CN_Sold_To_Party_Customer__r.CN_MG_Account_ID__c);
			mapItem.put('contact_id',shipTo.CN_Sold_To_Party_Customer__r.CN_Lead_MG_Contact_Id__c);
			mapItem.put('telephone',shipTo.CN_Telephone__c);
			mapItem.put('up_code',shipTo.CN_UP_Code__c);
			mapItem.put('post_code',shipTo.CN_Post_Code__c);
			mapItem.put('inactive',shipTo.CN_Inactive__c?'1':'0');
			maps.add(mapItem);
		}
		return maps;
	}


}
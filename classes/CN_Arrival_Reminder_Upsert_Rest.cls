/*
 * ************************************************************************************************
 * Name : CN_Arrival_Reminder_Upsert_Rest
 * Object :
 * Requirement : AR-001
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/7/28
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping = '/ArrivalReminderUpsert')
global class CN_Arrival_Reminder_Upsert_Rest {
        private static Set<String> SET_RequireFields = new Set<String> {
        	'customerSubmitTime',
        	'quantityWantBuy',
        	'skuCode',
        	'mgContactId',
        	'mgArrivalReminderId',
        	'warehouse',
        	'area'
        };
        private static Map<String, String> MAP_Fields = new Map<String, String> {
        	'customerSubmitTime'  => 'CN_Customer_Submit_Time__c',
        	'quantityWantBuy'     => 'CN_Quantity_Want_Buy__c',
        	'skuCode'             => 'CN_SKU_ID__c',
		    'skuName'             => 'CN_Product__c',
        	'mgContactId'         => 'CN_Contact__c',
        	'mgArrivalReminderId' => 'CN_MG_Arrival_Reminder_Id__c',
        	'warehouse'	          => 'CN_Warehouse__c',
        	'area'	              => 'CN_Area__c'
        };
        private static Map<String, Map<String, String>> MAP_ConvertFields = new Map<String, Map<String, String>> {
        	'skuName'     => new Map<String, String>{'targetField' => 'ID', 'object'=>'Product2', 'field'=>'CN_SKU_Code__c'},
        	'mgContactId' => new Map<String, String>{'targetField' => 'ID', 'object'=>'Contact', 'field'=>'CN_MG_Contact_ID__c'}
        };
    
        @HttpPost
        global static void post() {
        	Map<String, Object> result = new Map<String, Object>();
        	CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
        	System.debug(JSON.serialize(RestContext.request));
        	String strBody;
        	// --------------- 接受存储传递来的json字符串 ------------------
        	try {
        		strBody = RestContext.request.requestBody.toString();
        		log.SetRequest(strBody);
    
        		Map<String, Object> mapBody = (Map<String, Object>)JSON.deserializeUntyped(strBody);
        		if (mapBody.containsKey('datas') == false) {
        			throw new JSONException('[datas] cannot be null or empty');
        		}
        		List<Map<String, Object>> ltDatas = new List<Map<String, Object>>();
    
        		for (Object item : (List<Object>)mapBody.get('datas')) {
        			ltDatas.add((Map<String, Object>)item);
        		}
        		// ---------------大小不超过2000条 ------------------
        		if (ltDatas.size() > 2000) {
        			throw new JSONException('data size cannot be greater than 2000');
        		}
    
        		String errorMsg = '';
        		for (Map<String, Object> item : ltDatas) {
        			for (string requireField : SET_RequireFields) {
        				if (item.containsKey(requireField) == false) {
        					errorMsg += 'date must have require field [' + requireField + ']; ';
        				} else if (String.isBlank(String.valueOf(item.get(requireField)))) {
        					errorMsg += 'require field [' + requireField + '] can not be null; ';
        				}
        			}
        		}
    
        		if (errorMsg != '') {
        			throw new JSONException(errorMsg);
        		}
    
        		for (Map<String, Object> item : ltDatas) {
        			item.put('skuName', item.get('skuCode'));
        		}

				System.debug(JSON.serialize(ltDatas));
    
        		List<CN_Arrival_Reminder__c> ltDealData =
        				(List<CN_Arrival_Reminder__c>)CN_HelperClass_WS.convertAPIMapToSObject('CN_Arrival_Reminder__c', MAP_Fields,
        						MAP_ConvertFields, ltDatas);
    
        		for (CN_Arrival_Reminder__c item : ltDealData) {
        			item.CN_Email_Send__c = 'N';
        		}
    
        		List<Database.UpsertResult> databaseResult = Database.upsert(ltDealData,CN_Arrival_Reminder__c.CN_MG_Arrival_Reminder_Id__c, false);
    
        		System.debug('databaseResult == > ' + databaseResult);
        		list<Map<String, Object>> ltRet = new list<Map<String, Object>>();
        		Map<String, String> reMAP_Fields = new Map<String, String>();
        		for (String item : MAP_Fields.keySet()) {
        			reMAP_Fields.put(MAP_Fields.get(item), item);
        		}
    
        		for (Integer index = 0; index < databaseResult.size(); index++) {
        			Database.UpsertResult item = databaseResult[index];
        			System.debug('Database.UpsertResult :' + Json.serialize(item));
    
        			Object uniqueId = ltDealData[index].get('CN_MG_Arrival_Reminder_Id__c');
    
        			System.debug('uniqueId==>' + uniqueId);
        			System.debug('item.id==>' + item.id);
        			System.debug('ltDealData[index].Id==>' + ltDealData[index].Id);
    
        			if (item.id != null && ltDealData[index].Id != item.id) {
        				System.debug('ltDealData :' + ltDealData.toString());
        				throw new JSONException('Database.Result map ERROR, Please contact development.');
        			}
        			Map<String, Object> mapRet =
        					CN_HelperClass_WS.convertDatabaseResultToMap(item.id, item.success, item.errors, uniqueId,
        							reMAP_Fields);
        			ltRet.add(mapRet);
        		}
        		System.debug('ltRet==>' + ltRet);
        		result.put('retData', ltRet);
        		result.put('message', '操作成功');
        		result.put('code', 1);
        		log.SetResult(1, JSON.serialize(ltRet), '');
    
        	} catch (Exception ex) {
        		result.put('retData', null);
        		result.put('message', ex.getMessage());
        		result.put('code', 0);
        		log.SetResult(0, '', ex.getMessage());
        	}
        	System.debug('result==>' + result);
        	log.SetResponse(JSON.serialize(result));
        	log.Save();
    
        	RestResponse res = RestContext.response;
        	res.addHeader('Content-Type', 'application/json');
        	Blob responseBody = Blob.valueOf(JSON.serialize(result));
        	res.responseBody = responseBody;
        }
}
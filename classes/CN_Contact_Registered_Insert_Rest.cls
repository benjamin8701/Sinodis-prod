/*
 * ************************************************************************************************
 * Name : CN_Contact_Registered_Insert_Rest
 * Object :
 * Requirement :CT-016
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/3/27
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping='/ContactRegisteredInsert')
global class CN_Contact_Registered_Insert_Rest {

	private static Set<String> SET_RequireFields = new Set<String> {
		'firstName',
		'lastName',
//		'email',
		'mgContactID'
	};

	private static Set<String> SET_RequireFields_Inactive = new Set<String> {
		'inactive',
		'mgContactID'
	};

	private static Map<String,String> MAP_Fields = new Map<String,String> {
		'firstName'     => 'FirstName',
		'lastName'      => 'LastName',
		'email'         => 'Email',
//		'mobile'		=> 'MobilePhone',
		'mgContactID'   => 'CN_MG_Contact_ID__c',
		'mgAccountID'   => 'AccountId',
		'contactOwner'  => 'OwnerId',
		'inactive'      => 'CN_Inactive__c'
	};


	@HttpPost
	global static void post() {
		Map<String, Object> result = new Map<String, Object>();
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
		String strBody;
		try {
			strBody = RestContext.request.requestBody.toString();
			System.debug('CT-016:' + strBody);
			log.SetRequest(strBody);
			Map<String,Object> mapBody = (Map<String,Object>)JSON.deserializeUntyped(strBody);
			if (mapBody.containsKey('datas') == false) {
				throw new JSONException('[datas] cannot be null or empty');
			}
			List<Map<String,Object>> ltDatas = new List<Map<String,Object>>();

			for (Object item : (List<Object>)mapBody.get('datas')) {
				ltDatas.add((Map<String,Object>)item);
			}
			if (ltDatas.size() > 2000) {
				throw new JSONException('date size cannot be greater than 2000');
			}


			//不同业务单独处理
			List<Map<String, Object>> ltDatas_Insert = new List<Map<String, Object>>();
			List<Map<String, Object>> ltDatas_Inactive = new List<Map<String, Object>>();

			//flag区分和校验
			for (Object item : (List<Object>)mapBody.get('datas')) {
				Map<String, Object> ltData = (Map<String, Object>)item;
				if(ltData.containsKey('flag')){
					switch on ltData.get('flag').toString() {
						when '01'{
							ltDatas_Insert.add((Map<String, Object>)item);
						}
						when '02'{
							ltDatas_Inactive.add((Map<String, Object>)item);
						}
						when else {
							throw new JSONException('[flag] only can be 01 02 (Text)');
						}
					}
				}
			}
			String error = '';
			//必填内容校验
			error += checkData(ltDatas_Insert,SET_RequireFields);
			error += checkData(ltDatas_Inactive,SET_RequireFields_Inactive);
			if (error != ''){
				throw new JSONException(error);
			}

			//未添加默认值
			setBaseSetting(ltDatas_Insert);
			setBaseSetting(ltDatas_Inactive);

			//数据转换
			List<SObject> ltDealData = CN_HelperClass_WS.convertAPIMapToSObject('Contact', MAP_Fields, ltDatas);

			//数据存储
			List<Database.UpsertResult> databaseResult = Database.upsert(ltDealData, Contact.Fields.CN_MG_Contact_ID__c , false);//TODO 缺少唯一外部ID


			//处理返回结果集
			list<Map<String,Object>> ltRet = new list<Map<String,Object>>();

			Map<String,String> reMAP_Fields = new Map<String,String>();
			for (String item : MAP_Fields.keySet()) {
				reMAP_Fields.put(MAP_Fields.get(item), item);
			}

			for (Integer index = 0; index < databaseResult.size(); index++) {
				Database.UpsertResult item = databaseResult[index];
				System.debug('Database.UpsertResult :' + Json.serialize(item));
				Object uniqueId = ltDealData[index].get('CN_MG_Contact_ID__c');
				if (item.id != null && ltDealData[index].Id != item.id) {
					System.debug('ltDealData :' + ltDealData.toString());
					throw new JSONException('Database.Result map ERROR, Please contact development.');
				}
				Map<String,Object> mapRet = CN_HelperClass_WS.convertDatabaseResultToMap(item.id, item.success, item.errors, uniqueId, reMAP_Fields);
				ltRet.add(mapRet);
			}

			result.put('retData', ltRet);
			result.put('message', '操作成功');
			result.put('code', 1);
			log.SetResult(1, JSON.serialize(ltRet), '操作成功');

		} catch (Exception ex) {
			result.put('retData', null);
			result.put('message', ex.getMessage());
			result.put('code', 0);
			log.SetResult(0, '', ex.getMessage());
		}

		//日志处理
        log.SetResponse(JSON.serialize(result));
        log.Save();

		RestResponse res = RestContext.response;

		res.addHeader('Content-Type', 'application/json');
		Blob responseBody = Blob.valueOf(JSON.serialize(result));
		res.responseBody = responseBody;
	}

	/*
	 * 校验字段完整性
	 */
	private static String checkData(List<Map<String, Object>> ltDatas, Set<String> setRequireFields){
		string errorMsg = '';
		for (Map<String,Object> item : ltDatas) {
			for (string requireField : setRequireFields) {
				if (item.containsKey(requireField) == false) {
					errorMsg += 'date must have require field [' + requireField + ']; ';
				}
				else if (String.isBlank(String.valueOf(item.get(requireField)))) {
					errorMsg += 'require field [' + requireField + '] can not be null; ';
				}
			}
		}
		return errorMsg;
	}

	/*
	 * 其他通用设置
	 */
	private static void setBaseSetting(List<Map<String, Object>> ltDealData) {
		CN_MG_Customer_Settings__c settings = CN_MG_Customer_Settings__c.getInstance();
		for(Map<String, Object> item : ltDealData){
			item.put('mgAccountID',settings.CN_Contact_Auto_Account_Id__c);
			item.put('contactOwner',settings.CN_Contact_Auto_Owner_Id__c);
		}
	}

}
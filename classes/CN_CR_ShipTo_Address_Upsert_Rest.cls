/*
 * ************************************************************************************************
 * Name : CN_CR_ShipTo_Address_Upsert_Rest
 * Object :
 * Requirement :AC-007
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/3/24
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping = '/AccountShipToAddressUpsert')
global without sharing class CN_CR_ShipTo_Address_Upsert_Rest {

	//add by ZhangZhihao Modify Required check newShipToIndirectAccount  2024/1/24
	private static Set<String> SET_RequireFields_ShipTo_Address_Create = new Set<String> {
		'newMGAccountID',
		'newCityCN',
		'newShipToContactName',
		//'newShipToIndirectAccount',
		'newShipToMobilePhone',
		'newProvinceCN',
		'newShipToTelephone',
		'shipToAddressID',
		'shipToCard'
	};
	//add by ZhangZhihao Modify Required check newShipToIndirectAccount 2024/1/24
	//add by ZhangZhihao Modify Required check  newShipToIndirectAccount 2024/1/24
	private static Set<String> SET_RequireFields_ShipTo_Address_Update = new Set<String> {
		'newMGAccountID',
		'mgAccountID',
		'newCityCN',
		'newShipToContactName',
		//'newShipToIndirectAccount',
		'newShipToMobilePhone',
		'newProvinceCN',
		'newShipToTelephone',
		//'newSoldToPartyCustomer',
		'shipToAddressID',
		'shipToCard'
	};
	//add by ZhangZhihao Modify Required check newShipToIndirectAccount  2024/1/24
	private static Set<String> SET_RequireFields_ShipTo_Address_Inactive = new Set<String> {
		'shipToAddressID',
		'inactive'
	};

	private static Map<String, String> MAP_Fields = new Map<String, String> {
		'mgAccountID'                   => 'CN_Account_MG_Account_ID__c',
		'newMGAccountID'                => 'New_CN_Account_MG_Account_ID__c',
		'soldToPartyCustomer'           => 'CN_ShipTo_Sold_To_Party_Customer__c',
		'newCityCN'                     => 'New_CN_ShipTo_City_CN__c',
		'newShipToContactName'          => 'New_CN_ShipTo_Contact_Name__c',
		'shipToContactName'             => 'CN_ShipTo_Contact_Name__c',
		'newShipToDeliveryAddressCN'    => 'New_CN_ShipTo_Delivery_Address_CN__c',
		'newShipToDeliveryAddressEN'    => 'New_CN_ShipTo_Delivery_Address_EN__c',
		'newShipToIndirectAccount'      => 'New_CN_ShipTo_Indirect_Account__c',
		'newShipToMobilePhone'          => 'New_CN_ShipTo_Mobile_Phone__c',
		'newProvinceCN'                 => 'New_CN_ShipTo_Province_CN__c',
		'newShipToTelephone'            => 'New_CN_ShipTo_Telephone__c',
		'newSoldToPartyCustomer'        => 'New_CN_ShipTo_Sold_To_Party_Customer__c',
		'shipToAddressID'               => 'CN_ShipTo_Address_ID__c',
		'newShipToAddressID'            => 'New_CN_ShipTo_Address_ID__c',
		'mgContactID'                   => 'CN_Contact_MG_Contact_ID__c',
		'inactive'                      => 'CN_Inactive__c',
		'recordType'                    => 'RecordTypeId',
		'shipToCard'                    => 'CN_ShipTo_Card__c',
		'shipToParty'                    => 'CN_Ship_To_Party__c'
	};

	private static Map<String, Map<String,String>> MAP_ConvertFields = new Map<String, Map<String,String>> {
		'soldToPartyCustomer'	    => new Map<String,String>{'targetField' => 'ID','object'=>'Account','field'=>'CN_MG_Account_ID__c'},
		'newCityCN'	                => new Map<String,String>{'targetField' => 'ID','object'=>'CN_City__c','field'=>'CN_City_Code__c'},
		'newShipToIndirectAccount'	=> new Map<String,String>{'targetField' => 'ID','object'=>'Account','field'=>'CN_MG_Account_ID__c'},
		'newProvinceCN'	            => new Map<String,String>{'targetField' => 'ID','object'=>'CN_Province__c','field'=>'Province_Code__c'},
		'shipToParty'	            => new Map<String,String>{'targetField' => 'ID','object'=>'CN_Ship_To_Party__c','field'=>'CN_ShipTo_Address_ID__c'},
		'newSoldToPartyCustomer'	=> new Map<String,String>{'targetField' => 'ID','object'=>'Account','field'=>'CN_MG_Account_ID__c'}
	};
	private static Map<String,String> MAP_NeedCopyFields = new Map<String, String>{
		//key:needField     value:targetField
		'soldToPartyCustomer' => 'mgAccountID',
		'shipToParty'  => 'shipToAddressID', //复制shipToAddressID，用于changRequest关联
		'newShipToAddressID'  => 'shipToAddressID' //复制shipToAddressID，用于保存ShipTo的shipToAddressID字段
	};
	private static Map<String,String> MAP_NeedCopyFieldsInsert = new Map<String, String>{
		//key:needField     value:targetField
		'soldToPartyCustomer' => 'mgAccountID',
		'newShipToAddressID'  => 'shipToAddressID'
	};

	private static Map<String,String> MAP_UrlConvertFields = new Map<String,String> {
		'CN_ShipTo_Card__c'    =>   'Ship To Card'
	};

	@HttpPost
	global static void post() {
		Map<String, Object> result = new Map<String, Object>();
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
		String strBody;
		try {
			strBody = RestContext.request.requestBody.toString();
			Map<String, Object> mapBody = (Map<String, Object>)JSON.deserializeUntyped(strBody);
			if (mapBody.containsKey('datas') == false) {
				throw new JSONException('[datas] cannot be null or empty');
			}

			if(((List<Object>)mapBody.get('datas')).isEmpty()){
				throw new JSONException('[datas] cannot be null or empty');
			}

			List<Map<String, Object>> ltDatas_Insert = new List<Map<String, Object>>();
			List<Map<String, Object>> ltDatas_Update = new List<Map<String, Object>>();
			List<Map<String, Object>> ltDatas_Inactive = new List<Map<String, Object>>();

			for (Object item : (List<Object>)mapBody.get('datas')) {
				Map<String, Object> ltData = (Map<String, Object>)item;
				if(ltData.containsKey('flag')){
					switch on ltData.get('flag').toString() {
						when '01'{
							ltDatas_Insert.add((Map<String, Object>)item);
						}
						when '02'{
							ltDatas_Update.add((Map<String, Object>)item);
						}
						when '03'{
							ltDatas_Inactive.add((Map<String, Object>)item);
						}
						when else {
							throw new JSONException('[flag] only can be 01 02 03 (Text)');
						}
					}
				}
			}

			checkDataUpsert(ltDatas_Insert,SET_RequireFields_ShipTo_Address_Create);
			checkDataUpsert(ltDatas_Update,SET_RequireFields_ShipTo_Address_Update);
			checkDataInactive(ltDatas_Inactive,SET_RequireFields_ShipTo_Address_Inactive);

			RecordType recordTypeInsert = [SELECT ID FROM RecordType WHERE DeveloperName = :Constants.CN_CR_RT_API_NAME_NEW_SHIPTO].get(0);
			List<Map<String,Object>> insertList = crShipToAddressInsert(ltDatas_Insert,MAP_NeedCopyFieldsInsert, recordTypeInsert.Id);

			RecordType recordTypeUpdate = [SELECT ID FROM RecordType WHERE DeveloperName = :Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO].get(0);
			List<Map<String,Object>> updateList = crShipToAddressUpdate(ltDatas_Update,MAP_NeedCopyFields, recordTypeUpdate.Id);

			RecordType recordTypeInactive = [SELECT ID FROM RecordType WHERE DeveloperName = :Constants.CN_CR_RT_API_NAME_INACTIVE_SHIPTO].get(0);
			List<Map<String,Object>> inactiveList = crShipToAddressInactive(ltDatas_Inactive,MAP_NeedCopyFields, recordTypeInactive.Id);

			insertList.addAll(updateList);
			insertList.addAll(inactiveList);

			result.put('retData', insertList);
			result.put('message', 'success');
			result.put('code', 1);

		}catch (Exception ex){
			System.debug(ex.getLineNumber() + ':' + ex.getMessage()  + ':' + ex.getStackTraceString());
			result.put('retData', null);
			result.put('message', ex.getMessage());
			result.put('code', 0);
		}
        log.SetRequest(strBody);
		if('1'.equals(result.get('code'))){
			log.SetResult(Integer.valueOf(result.get('code')), String.valueOf(result.get('retData')), String.valueOf(result.get('message')));
		}else{

		}
        log.SetResponse(JSON.serialize(result));
        log.Save();
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		Blob responseBody = Blob.valueOf(JSON.serialize(result));
		res.responseBody = responseBody;
	}


	private static List<Map<String,Object>> crShipToAddressInsert(List<Map<String, Object>> ltDatas, Map<String,String> needCopyFields, String recordTypeId){
		if (ltDatas.isEmpty()){
			return new List<Map<String,Object>>();
		}
		copyFields(ltDatas,needCopyFields);
		List<CN_Change_Request__c> ltDealData = (List<CN_Change_Request__c>)CN_HelperClass_WS.convertAPIMapToSObject('CN_Change_Request__c', MAP_Fields, MAP_ConvertFields, ltDatas);
		setOwnerByAccount(ltDealData);
		setBaseSetting(ltDealData,recordTypeId);
		Database.DMLOptions dmlOptionsInvite = new Database.DMLOptions();
		dmlOptionsInvite.assignmentRuleHeader.useDefaultRule = false;
		dmlOptionsInvite.OptAllOrNone = false;
		List<Database.SaveResult> databaseResult = Database.insert(ltDealData, dmlOptionsInvite);
		sendNotifications(ltDealData);
		List<CN_Download_By_Url_Info__c> dInfoList = new List<CN_Download_By_Url_Info__c>();

		for (CN_Change_Request__c next : ltDealData) {
			if(next == null){
				continue;
			}
			for(String field:MAP_UrlConvertFields.keySet()){
				if(next.get(field) == null || String.isEmpty(next.get(field).toString())){
					continue;
				}
				CN_Download_By_Url_Info__c dInfo = CN_Download_By_Url_Helper.convert(next.Id,next.New_CN_ShipTo_Contact_Name__c + '-' + MAP_UrlConvertFields.get(field), next.get(field).toString(),'CN_Change_Request__c',field);
				dInfoList.add(dInfo);
			}
		}

		insert dInfoList;
		list<Map<String,Object>> ltRet = dealRes(ltDealData,databaseResult);
		return ltRet;

	}

	private static List<Map<String,Object>> crShipToAddressUpdate(List<Map<String, Object>> ltDatas, Map<String,String> needCopyFields, String recordTypeId){

		if (ltDatas.isEmpty()){
			return new List<Map<String,Object>>();
		}

		copyFields(ltDatas,needCopyFields);

		List<CN_Change_Request__c> ltDealData = (List<CN_Change_Request__c>)CN_HelperClass_WS.convertAPIMapToSObject('CN_Change_Request__c', MAP_Fields, MAP_ConvertFields, ltDatas);

		setOwnerByShipTo(ltDealData);

		setBaseSetting(ltDealData,recordTypeId);

		setOldData(ltDealData);

		Database.DMLOptions dmlOptionsInvite = new Database.DMLOptions();
		dmlOptionsInvite.assignmentRuleHeader.useDefaultRule = false;
		dmlOptionsInvite.OptAllOrNone = false;
		System.debug(JSON.serialize(ltDealData));
		List<Database.SaveResult> databaseResult = Database.insert(ltDealData, dmlOptionsInvite);
		sendNotifications(ltDealData);

		 System.debug(Json.serialize(databaseResult));

		List<CN_Download_By_Url_Info__c> dInfoList = new List<CN_Download_By_Url_Info__c>();

		for (CN_Change_Request__c next : ltDealData) {
			if(next == null){
				continue;
			}
			for(String field:MAP_UrlConvertFields.keySet()){
				if(next.get(field) == null || String.isEmpty(next.get(field).toString())){
					continue;
				}
				CN_Download_By_Url_Info__c dInfo = CN_Download_By_Url_Helper.convert(next.Id,next.New_CN_ShipTo_Contact_Name__c + '-' + MAP_UrlConvertFields.get(field), next.get(field).toString(),'CN_Change_Request__c',field);
				dInfoList.add(dInfo);
			}
		}
		insert dInfoList;
		list<Map<String,Object>> ltRet = dealRes(ltDealData,databaseResult);
		return ltRet;
	}

	private static void setOldData(List<CN_Change_Request__c> ltDatas) {
		String selectFields = String.join(new List<String>(Schema.CN_Ship_To_Party__c.sObjectType.getDescribe().fields.getMap().keyset()), ',');
		String soql = 'SELECT ' + selectFields + ' FROM CN_Ship_To_Party__c WHERE CN_ShipTo_Address_ID__c in (';

		Boolean isEdit = false;
		for(CN_Change_Request__c item : ltDatas){
			soql += '\'' + item.CN_ShipTo_Address_ID__c + '\',';
			isEdit = true;
		}
		if(isEdit){
			soql = soql.substring(0,soql.length()-1) + ')';
		}else{
			return ;
		}


		System.debug(soql);

		List<CN_Ship_To_Party__c> accList = Database.query(soql);

		Map<String,CN_Ship_To_Party__c> shipToPartyMap = new Map<String, CN_Ship_to_Party__c>();
		for (CN_Ship_to_Party__c item : accList) {
			shipToPartyMap.put(item.CN_ShipTo_Address_ID__c,item);
		}


		for (CN_Change_Request__c item : ltDatas) {

			CN_Ship_to_Party__c shipTo = shipToPartyMap.get(item.CN_ShipTo_Address_ID__c);
			if (shipTo == null){
				continue;
			}
			if(!Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(shipTo.CN_Account_Sync_Status__c)) {
				throw new JSONException(System.Label.CN_Account_Not_Synced);
			}

			Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();


			for(String crmSettingId : crmSettingMap.keyset()) {
				CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
				if('CN_Ship_to_Party__c'.equals(crmSetting.CN_Object_Name__c)) {
					String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
					String fieldNameNew = 'New_' + fieldNameOld;
					System.debug(fieldNameNew + ' : ' + String.valueOf(item.get(fieldNameNew)));
					item.put(fieldNameOld, shipTo.get(crmSetting.CN_Field_Name__c));
				}
			}
			//zzh add by 2024/1/4
			item.put('New_CN_ShipTo_Customer_Name__c', shipTo.get('CN_Customer_Name__c'));
			item.put('New_CN_ShipTo_Customer_Name_EN__c', shipTo.get('CN_Customer_Name_EN__c'));
			item.put('New_CN_ShipTo_Delivery_Plant__c', shipTo.get('CN_Delivery_Plant__c'));
			//zzh add by 2024/1/4
			System.debug(JSON.serialize(item));
		}
	}

	private static List<Map<String,Object>> crShipToAddressInactive(List<Map<String, Object>> ltDatas, Map<String,String> needCopyFields, String recordTypeId){

		list<Map<String,Object>> ltRet = new list<Map<String,Object>>();

		 List<CN_Change_Request__c> crDatas = new List<CN_Change_Request__c>();

		if (ltDatas.isEmpty()){
			return new List<Map<String,Object>>();
		}

		String selectFields = String.join(new List<String>(Schema.CN_Ship_To_Party__c.sObjectType.getDescribe().fields.getMap().keyset()), ',');
		String soql = 'SELECT ' + selectFields + ' FROM CN_Ship_To_Party__c WHERE CN_ShipTo_Address_ID__c in (';
		Boolean isEdit = false;
		for(Map<String,Object> item : ltDatas){
			soql += '\'' + item.get('shipToAddressID') + '\',';
			isEdit = true;
		}

		if(isEdit){
			soql = soql.substring(0,soql.length()-1) + ')';
		}
		System.debug('soql' + soql);
		List<CN_Ship_To_Party__c> accList = Database.query(soql);

		System.debug('result' + JSON.serialize(accList));
		Map<String,CN_Ship_To_Party__c> shipToPartyMap = new Map<String, CN_Ship_to_Party__c>();
		for (CN_Ship_to_Party__c item : accList) {
			shipToPartyMap.put(item.CN_ShipTo_Address_ID__c,item);
		}

		for ( Integer i = 0; i< ltDatas.size() ;i++) {
			Map<String,Object> item = ltDatas[i];
			CN_Ship_to_Party__c shipTo = shipToPartyMap.get(String.valueOf(item.get('shipToAddressID')));
			System.debug('ltDatas' + JSON.serialize(shipTo));

			if (shipTo == null){
				Map<String,Object> mapRet = new Map<String,Object>();
				Map<String,Object> errData = ltDatas.remove(i);
				mapRet.put('sfid', null);
				mapRet.put('errors', 'Can not find shipTo');
				mapRet.put('success', false);
				mapRet.put('uniqueid', errData.get('shipToAddressID'));
				ltRet.add(mapRet);
				i --;
				continue;
			}

			if(!Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(shipTo.CN_Account_Sync_Status__c)) {
				throw new JSONException(System.Label.CN_Account_Not_Synced);
			}

			Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();

			CN_Change_Request__c cr = new CN_Change_Request__c();

			for(String crmSettingId : crmSettingMap.keyset()) {
				CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
				if('CN_Ship_to_Party__c'.equals(crmSetting.CN_Object_Name__c)) {
					String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
					String fieldNameNew = 'New_' + fieldNameOld;
					cr.put(fieldNameOld, shipTo.get(crmSetting.CN_Field_Name__c));//获取字段名错误
					cr.put(fieldNameNew, shipTo.get(crmSetting.CN_Field_Name__c));//获取字段名错误
				}
			}
			cr.CN_Ship_To_Party__c = shipTo.Id;
			cr.New_CN_ShipTo_Inactive__c = String.valueOf(item.get('inactive')) == 'true'? true:false;
			crDatas.add(cr);
		}

		setOwnerByShipTo(crDatas);
		setBaseSetting(crDatas,recordTypeId);

		Database.DMLOptions dmlOptions = new Database.DMLOptions();
		dmlOptions.OptAllOrNone = false;
		List<Database.SaveResult> databaseResult = Database.insert(crDatas, dmlOptions);
		setStatus(crDatas);
		Database.update(crDatas, dmlOptions);

		System.debug(JSON.serialize(databaseResult));
		System.debug(JSON.serialize(crDatas));

		sendNotifications(crDatas);
		submitAndProcessApprovalRequest(crDatas);
		ltRet.addAll(dealRes(crDatas,databaseResult));
		return ltRet;

	}

	private static void checkDataUpsert(List<Map<String, Object>> ltDatas, Set<String> setRequireFields) {
		String errorMsg =checkData(ltDatas,setRequireFields);

		for(Map<String,Object> item : ltDatas){
			if (  (!item.containsKey('newShipToDeliveryAddressCN') || String.isBlank(String.valueOf(item.get('newShipToDeliveryAddressCN')))) &&
					(!item.containsKey('newShipToDeliveryAddressEN') || String.isBlank(String.valueOf(item.get('newShipToDeliveryAddressEN'))))
			){
				errorMsg += 'date must have require field [newShipToDeliveryAddressCN] or [newShipToDeliveryAddressEN]';
			}
		}

		if (errorMsg != '') {
			throw new JSONException(errorMsg);
		}
	}

	private static void checkDataInactive(List<Map<String, Object>> ltDatas, Set<String> setRequireFields) {
		String errorMsg =checkData(ltDatas,setRequireFields);
		if (errorMsg != '') {
			throw new JSONException(errorMsg);
		}
	}

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

	private static void copyFields(List<Map<String, Object>> ltDatas, Map<String,String> needCopyFields){
		for (Map<String, Object> data:ltDatas){
			for(String needField:needCopyFields.keySet()){
				String targetField = needCopyFields.get(needField);
				if(data.containsKey(targetField)){
					data.put(needField,data.get(targetField));
				}
			}
		}
		System.debug(Json.serialize(ltDatas));
	}

	private static void setOwnerByAccount(List<CN_Change_Request__c> ltDealData) {
		List<String> mgAccountIds = new List<String>();
		for (CN_Change_Request__c next : ltDealData) {
			mgAccountIds.add(next.New_CN_Account_MG_Account_ID__c);
		}

		Map<String,String> ownerMap = new Map<String, String>();
		List<Account> accounts = [SELECT ID,
		CN_MG_Account_ID__c,
		OwnerId  FROM Account
		WHERE CN_MG_Account_ID__c IN :mgAccountIds];
		for (Account next : accounts) {
			ownerMap.put(next.CN_MG_Account_ID__c,next.OwnerId);
		}
		System.debug(JSON.serialize(ownerMap));

		for(CN_Change_Request__c item : ltDealData){
			System.debug(JSON.serialize(item.New_CN_Account_MG_Account_ID__c));
			String owner = ownerMap.get(item.New_CN_Account_MG_Account_ID__c);
			System.debug('owner::' + owner);
			if(String.isEmpty(owner)){
				CN_MG_Customer_Settings__c settings = CN_MG_Customer_Settings__c.getInstance();
				item.OwnerId = settings.CN_CR_ShipTo_Owner__c;
			}else{
				item.OwnerId = owner;
			}
		}
	}

	private static void setOwnerByShipTo(List<CN_Change_Request__c> ltDealData) {
		List<String> mgShipToId = new List<String>();
		for (CN_Change_Request__c next : ltDealData) {
			mgShipToId.add(next.CN_ShipTo_Address_ID__c);
		}

		Map<String,String> ownerMap = new Map<String, String>();
		List<CN_Ship_to_Party__c> shipToPartyList = [SELECT CN_ShipTo_Address_ID__c, CN_Sold_To_Party_Customer__r.OwnerId FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c IN :mgShipToId];
		for (CN_Ship_to_Party__c next : shipToPartyList) {
			ownerMap.put(next.CN_ShipTo_Address_ID__c,next.CN_Sold_To_Party_Customer__r.OwnerId);
		}

		for(CN_Change_Request__c item : ltDealData){
			String owner = ownerMap.get(item.CN_ShipTo_Address_ID__c);
			System.debug(owner);
			if(String.isEmpty(owner)){
				CN_MG_Customer_Settings__c settings = CN_MG_Customer_Settings__c.getInstance();
				item.OwnerId = settings.CN_CR_ShipTo_Owner__c;
			}else{
				item.OwnerId = owner;
			}
			System.debug(item.OwnerId);
		}
	}

	private static void sendNotifications(List<CN_Change_Request__c> crs){

		Set <String> recipientsIds = new Set <String>();
		String cnCustomNotifyType = Constants.CN_Custom_Notification_API_NAME;

		// Get the Id for our custom notification type
		CustomNotificationType notificationType =
		[SELECT Id, DeveloperName
		FROM CustomNotificationType
		WHERE DeveloperName = :cnCustomNotifyType];

		// Create a new custom notification
		Messaging.CustomNotification notification = new Messaging.CustomNotification();

		// Set the contents for the notification
		notification.setTitle(System.Label.CN_ShipTo_Changed_Notification_Title);

		// Set the notification type and target
		notification.setNotificationTypeId(notificationType.Id);

		for (CN_Change_Request__c cr : crs) {
			if (cr.Id == null){
				continue;
			}
			// Actually send the notification
			notification.setBody(System.Label.CN_ShipTo_Changed_Notification_Body);
			notification.setTargetId(cr.Id );
			recipientsIds.add(cr.OwnerId);
			notification.send(recipientsIds);
		}


	}

	private static void  submitAndProcessApprovalRequest(List<CN_Change_Request__c> crs) {
		// Insert an account
		System.debug(JSON.serialize(crs));
		List<CN_Change_Request__c> crs2 = [SELECT ID,OwnerId  FROM CN_Change_Request__c WHERE ID IN :crs];

		for (CN_Change_Request__c cr : crs2) {
			if (cr.Id == null){
				continue;
			}

			// Create an approval request for the account
			Approval.ProcessSubmitRequest req =
					new Approval.ProcessSubmitRequest();
			req.setComments('Auto submitting request for approval.');
			req.setObjectId(cr.id);

			// Submit the record to specific process and skip the criteria evaluation
			req.setProcessDefinitionNameOrId('CN_CR_Approve_Process');
			req.setSkipEntryCriteria(true);
			req.setSubmitterId(cr.OwnerId);
			Approval.ProcessResult result = Approval.process(req);
			System.debug(JSON.serialize(result));

			Approval.ProcessWorkitemRequest approve = new Approval.ProcessWorkitemRequest();
			approve.setComments('Auto submitting request for approval.');
			approve.setWorkitemId(result.getNewWorkitemIds()[0]);
			approve.setAction('Approve');
			Approval.ProcessResult result2 = Approval.process(approve);
			System.debug(JSON.serialize(result2));

		}

	}


	private static void setBaseSetting(List<CN_Change_Request__c> ltDealData, String recordTypeId) {
		for(CN_Change_Request__c item : ltDealData){
			item.RecordTypeId = recordTypeId;
			item.CN_Is_Auto_Approved__c = false;
			item.CN_Is_Generate_From_Action__c = true;
			item.CN_CR_Source__c = Constants.CN_CR_SOURCE_ECOMMERCE;
		}
	}

	private static void setStatus(List<CN_Change_Request__c> ltDealData) {
		for(CN_Change_Request__c item : ltDealData){
			item.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
			item.CN_External_Id__c = item.CN_Ship_To_Party__c;
		}
	}

	private static List<Map<String,Object>> dealRes(List<CN_Change_Request__c> ltDealData,List<Database.SaveResult> databaseResult){
		List<Map<String,Object>> ltRet = new List<Map<String,Object>>();

		Map<String,String> reMAP_Fields = new Map<String,String>();
		for (String item : MAP_Fields.keySet()) {
			reMAP_Fields.put(MAP_Fields.get(item), item);
		}

		for (Integer index = 0; index < databaseResult.size(); index++) {
			Database.SaveResult item = databaseResult[index];
			Object uniqueId = ltDealData[index].get('CN_ShipTo_Address_ID__c');
			if (item.id != null && ltDealData[index].Id != item.id) {
				throw new JSONException('Database.Result map ERROR, Please contact development.');
			}
			Map<String,Object> mapRet = CN_HelperClass_WS.convertDatabaseResultToMap(item.id, item.success, item.errors, uniqueId, reMAP_Fields);
			ltRet.add(mapRet);
		}
		return ltRet;
	}

}
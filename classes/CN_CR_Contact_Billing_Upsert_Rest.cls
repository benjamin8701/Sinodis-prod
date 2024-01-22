/*
 * ************************************************************************************************
 * Name : CN_CR_Contact_Billing_Upsert_Rest
 * Object :
 * Requirement :CT-012
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/3/27
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping = '/BillingAddressUpsert')
global without sharing class CN_CR_Contact_Billing_Upsert_Rest {

	private static Set<String> SET_RequireFields = new Set<String> {
		'newContactTitle',
		'newContactNameCNLastName',
//		'newContactNameCNFirstName',
		'newContactNameEN',
		'newContactLicenseName',
		'newContactType',
		'newDepartmentOfContactPerson',
		'newContactMobile',
		'mgContactID',
		'mgBillingToAddressID'
	};

	private static Map<String, String> MAP_Fields = new Map<String, String> {
		'contact'                        => 'CN_Contact__c',
		'newContactTitle'                => 'New_CN_Contact_Title__c',
		'newContactNameCNLastName'       => 'New_CN_Contact_CN_Last_Name__c',
		'newContactNameCNFirstName'      => 'New_CN_Contact_CN_First_Name__c',
		'newContactNameEN'               => 'New_CN_Contact_Name_EN__c',
		'newContactLicenseName'          => 'New_CN_Contact_License_Name__c',
		'newContactType'                 => 'New_CN_Contact_Type__c',
		'contactType'                    => 'CN_Contact_Type__c',
		'newDepartmentOfContactPerson'   => 'New_CN_Contact_Dept_Of_Contact_Person__c',
		'newContactPhoneNumber'          => 'New_CN_Contact_Phone_Number__c',
		'newContactWechatID'             => 'New_CN_Contact_Wechat_ID__c',
		'newContactEmail'                => 'New_CN_Contact_Email__c',
		'newDecisionMaker'               => 'New_CN_Contact_Decision_Maker__c',
		'newContactMobile'               => 'New_CN_Contact_Mobile__c',
		'newContactBillingToAddress'     => 'New_CN_Contact_Billing_To_Address__c',
		'newContactBirthday'             => 'New_CN_Contact_Birthday__c',
		'newContactReportsTo'            => 'New_CN_Contact_Reports_To__c',
		'newContactFamilyInfo'           => 'New_CN_Contact_Family_Info__c',
		'newContactOpenFieldToComment'   => 'New_CN_Contact_Open_Field_To_Comment__c',
		'mgContactID'                    => 'New_CN_Contact_MG_Contact_ID__c',
		'mgBillingToAddressID'           => 'New_CN_Contact_MG_Billing_ID__c',
		'sfBillingToAddressID'           => 'CN_Contact_Billing_To_Address_ID__c'
	};

	private static Map<String, Map<String,String>> MAP_ConvertFields = new Map<String, Map<String,String>> {
		'contact'	                => new Map<String,String>{'object'=>'Contact','field'=>'CN_MG_Contact_ID__c','targetField' => 'ID'},
		'contactType'	            => new Map<String,String>{'object'=>'Contact','field'=>'CN_MG_Contact_ID__c','targetField' => 'CN_Contact_Type__c'},
		'newContactLicenseName'	    => new Map<String,String>{'object'=>'Account','field'=>'CN_MG_Account_ID__c','targetField' => 'ID'},
		'newContactReportsTo'	    => new Map<String,String>{'object'=>'Contact','field'=>'CN_MG_Contact_ID__c','targetField' => 'ID'}
	};

	// 用于复制特殊属性
	private static Map<String,String> MAP_NeedCopyFields = new Map<String, String>{
		'contact'      => 'mgContactID',
		'contactType'  => 'mgContactID'
	};

	@HttpPost
	global static void post() {
		Map<String, Object> result = new Map<String, Object>();
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
		String strBody;
		try {
			strBody = RestContext.request.requestBody.toString();
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

			string errorMsg = '';
			for (Map<String,Object> item : ltDatas) {
				for (string requireField : SET_RequireFields) {
					if (item.containsKey(requireField) == false) {
						errorMsg += 'date must have require field [' + requireField + ']; ';
					}
					else if (String.isBlank(String.valueOf(item.get(requireField)))) {
						errorMsg += 'require field [' + requireField + '] can not be null; ';
					}
				}
			}
			for (Map<String,Object> item : ltDatas) {
				if(item.get('newContactReportsTo') == item.get('mgContactID')){
					errorMsg += ' field [newContactReportsTo] Error:  A contact must report to a different contact.; ';
				}
			}
			if (errorMsg != '') {
				throw new JSONException(errorMsg);
			}

			//copy field
			for (Map<String, Object> data:ltDatas){
				for(String needField:MAP_NeedCopyFields.keySet()){
					String targetField = MAP_NeedCopyFields.get(needField);
					if(data.containsKey(targetField)){
						data.put(needField,data.get(targetField));
					}
				}
			}
			//copy field
			for (Map<String, Object> data:ltDatas){
				for(String key:data.keySet()){
					if(data.get(key) == null || data.get(key) == ''){
						data.remove(key);
					}
				}
			}

			List<CN_Change_Request__c> ltDealData = (List<CN_Change_Request__c>)CN_HelperClass_WS.convertAPIMapToSObject('CN_Change_Request__c', MAP_Fields, MAP_ConvertFields, ltDatas);

			//RecordType
			RecordType recordTypeInsert = [SELECT ID FROM RecordType WHERE DeveloperName = :Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT].get(0);
			System.debug(recordTypeInsert);
			for(CN_Change_Request__c dealData : ltDealData){
				dealData.RecordTypeId = recordTypeInsert.Id;
				dealData.CN_Is_Generate_From_Action__c = true;
				dealData.CN_CR_Source__c = Constants.CN_CR_SOURCE_ECOMMERCE;
				System.debug(JSON.serialize(dealData));
			}

			//add old field
			setOldData(ltDealData);

			List<CN_Change_Request__c> checkedDealData = new List<CN_Change_Request__c>();
			List<CN_Change_Request__c> errorDealData = new List<CN_Change_Request__c>();

			for(CN_Change_Request__c dealData : ltDealData){
				System.debug(JSON.serialize(dealData));
				if(dealData.CN_Contact_MG_Contact_ID__c == NULL){
					dealData.addError('no contact');
					errorDealData.add(dealData);
				}else{
					checkedDealData.add(dealData);
				}
			}

			//create CR
			List<Database.SaveResult> databaseResult = Database.insert(checkedDealData, false);

			//auto submit field
			List<CN_Change_Request__c> insertList = new List<CN_Change_Request__c>();
			for (CN_Change_Request__c next : checkedDealData) {
				if(next.Id != null) {
					insertList.add(next);
				}
			}
			addBasicData(insertList);
			List<Database.SaveResult> databaseResultNeedApprove = new List<Database.SaveResult>();

			try {
				databaseResultNeedApprove = Database.update(insertList, false);
			} catch (Exception e){
				//needn't deal
			}

			//batch submit to approval
			CN_CR_Contact_Auto_Processing_Batch batch = new CN_CR_Contact_Auto_Processing_Batch();
			Id batchId = Database.executeBatch(batch,10);

			list<Map<String,Object>> ltRet = new list<Map<String,Object>>();

			Map<String,String> reMAP_Fields = new Map<String,String>();
			for (String item : MAP_Fields.keySet()) {
				reMAP_Fields.put(MAP_Fields.get(item), item);
			}

			for (Integer index = 0; index < databaseResult.size(); index++) {
				Database.SaveResult item = databaseResult[index];
				System.debug(JSON.serialize(checkedDealData[index]));
				Object uniqueId = checkedDealData[index].get('CN_Contact_MG_Contact_ID__c');
				if (item.id != null && checkedDealData[index].Id != item.id) {
					throw new JSONException('Database.Result map ERROR, Please contact development.');
				}
				Boolean bFlag = item.success;
				List<Database.Error> allErrors = new List<Database.Error>();
				allErrors.addAll(item.errors);
				Map<String,Object> mapRet = CN_HelperClass_WS.convertDatabaseResultToMap(item.id, bFlag, allErrors, uniqueId, reMAP_Fields);
				ltRet.add(mapRet);
			}

			for (CN_Change_Request__c c:errorDealData) {
				Map<String,Object> mapRet = new Map<String,Object>();
				String err = '';
				for (Integer index = 0; index < c.getErrors().size(); index++) {
					Database.Error error = c.getErrors()[index];
					err += error.getMessage() + ',';
				}
				mapRet.put('sfid', null);
				mapRet.put('errors', err);
				mapRet.put('success', false);
				mapRet.put('uniqueid', c.New_CN_Contact_MG_Contact_ID__c);
				ltRet.add(mapRet);
			}

			result.put('retData', ltRet);
			result.put('message', 'success');
			result.put('code', 1);
			log.SetResult(1, JSON.serialize(ltRet), 'success');
		} catch (Exception ex) {
			System.debug(ex.getMessage() + ' : ' + ex.getStackTraceString() + ' : ' + ex.getLineNumber());
			result.put('retData', null);
			result.put('message', ex.getMessage());
			result.put('code', 0);
			log.SetResult(0, '', ex.getMessage());
		}
        log.SetResponse(JSON.serialize(result));
        log.Save();

		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		Blob responseBody = Blob.valueOf(JSON.serialize(result));
		res.responseBody = responseBody;
	}

	private static void addBasicData(List<CN_Change_Request__c> ltDealData) {
		for(CN_Change_Request__c dealData : ltDealData) {
			dealData.CN_External_Id__c = dealData.CN_Contact__c;
			dealData.CN_Change_Request_Status__c = 'ready for approval';
		}
	}

	private static void setOldData(List<CN_Change_Request__c> ltDealData) {

		Map<String,CN_Change_Request__c> conIdCRMap = new Map<String,CN_Change_Request__c>();
		for (CN_Change_Request__c item : ltDealData) {
			if(item.CN_Contact__c == null){
				continue;
			}
			conIdCRMap.put(item.CN_Contact__c,item);
		}
		Boolean isEdit = false;
		String selectFields = String.join(new List<String>(Schema.Contact.sObjectType.getDescribe().fields.getMap().keyset()), ',');
		String soql = 'SELECT ' + selectFields + ' FROM Contact WHERE Id in (';
		for(String item : conIdCRMap.keySet()){
			soql += '\'' + item + '\',';
			isEdit = true;
		}
		if(isEdit){
			soql = soql.substring(0,soql.length()-1) + ')';
		}else{
			return ;
		}
		List<Contact> accList = Database.query(soql);
		System.debug(accList);
		Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();

		for(Contact con: accList) {
			CN_Change_Request__c cr = conIdCRMap.get(con.Id);
			for (String crmSettingId : crmSettingMap.keyset()) {
				CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
				if ('Contact'.equals(crmSetting.CN_Object_Name__c)) {
					String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
					String fieldNameNew = 'New_' + fieldNameOld;
					cr.put(fieldNameOld, con.get(crmSetting.CN_Field_Name__c));

				}
			}
			System.debug(JSON.serialize(cr));
		}
	}
}
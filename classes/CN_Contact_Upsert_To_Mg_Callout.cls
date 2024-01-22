/*
 * ************************************************************************************************
 * Name : CN_Contact_Upsert_To_Mg_Callout
 * Object :
 * Requirement :CT-014
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/6
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Contact_Upsert_To_Mg_Callout {

	public static Map<String, Contact> upsertContact(List<Contact> lists) {

		//handleDataList
		List<Map<String, Object>> maps = handleData(lists);

		//Necessary parameters for assembly request
		Talend_Setting__c setting = Talend_Setting__c.getInstance();
		Http http = new Http();
		HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
				setting.Sandbox_MG_Save_Company_Contact__c,
				setting.MG_Save_Company_Contact__c);

		//Successful Requests Records
		Map<String, Contact> needUpdateMap = new Map<String, Contact>();

		//logs
		List<CN_API_Call_Logger__c> listLog = new List<CN_API_Call_Logger__c>();

		//Loop processing requests
		for (Map<String, Object> item : maps) {
			CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
			try {
				String body = JSON.serialize(item);
				String id = String.valueOf(item.get('MAP_ID'));
				request.setBody(body);
				log.SetRequest(request.getBody());

				HttpResponse response = http.send(request);
				log.SetResponse(response.getBody());

				Integer resCode = response.getStatusCode();

				String errorMsg = '';
				String errorMessage = '';
				if (resCode == 200) {
					System.debug(response.getBody());
					//成功调用
					CN_HelperClass_WS.Message  cs = CN_HelperClass_WS.getRetData(response.getBody());
					System.debug(JSON.serialize(cs));

					if(cs != null && cs.code == 1){

						Map<String,Object> retData = cs.retData;
						if (retData != null && retData.containsKey('mg_billing_id')){

							String contact_id = String.valueOf(retData.get('contact_id'));
							String mg_billing_id = String.valueOf(retData.get('mg_billing_id'));

							//handle successful record
							Contact contact = new Contact();
							contact.Id = id;
							contact.CN_MG_Contact_ID__c = contact_id;
							contact.CN_MG_Billing_To_Address_ID__c = mg_billing_id;
							contact.CN_Need_Send_MG__c = false;
							needUpdateMap.put(id, contact);
						}

					}

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
			} catch (Exception e) {

				log.SetResult(0,'',e.getMessage());
				listLog.add(log.getLog());
			}
		}

		insert listLog;
		return needUpdateMap;
	}

	private static List<Map<String, Object>> handleData(List<Contact> lists) {
		List<Map<String, Object>> maps = new List<Map<String, Object>>();
		for (Contact contact : lists) {
			Map<String, Object> mapItem = new Map<String, Object>();
			mapItem.put('MAP_ID', contact.Id);
			mapItem.put('birthday', contact.Birthdate);
			mapItem.put('contact_person_address', contact.CN_Bill_To_Address__c);
			mapItem.put('id', contact.Id);
			mapItem.put('lastname', contact.LastName);
			mapItem.put('firstname', contact.FirstName);
			mapItem.put('contact_person', contact.CN_Department_Of_Contact_Person__c);
			mapItem.put('email', contact.Email);
			mapItem.put('mobile', contact.MobilePhone);
			mapItem.put('telephone', contact.Phone);
			mapItem.put('reports_to', contact.ReportsTo.CN_MG_Contact_ID__c);
			mapItem.put('contact_name', contact.CN_Contact_Name_EN__c);
			mapItem.put('prefix', contact.Title);
			mapItem.put('contact_type', contact.CN_Contact_Type__c);
			mapItem.put('wechat_id', contact.CN_Wechat_ID__c);
			mapItem.put('family_info', contact.CN_Family_Info__c);
			mapItem.put('open_field_to_comment', contact.CN_Open_Field_To_Comment__c);
			mapItem.put('decision_maker', contact.CN_Decision_Maker__c);
			mapItem.put('contact_license_name', contact.Account.CN_MG_Account_ID__c);
			mapItem.put('company', contact.Account.CN_MG_Account_ID__c);
			mapItem.put('contact_id', contact.CN_MG_Contact_ID__c);
			mapItem.put('mg_billing_id', contact.CN_MG_Billing_To_Address_ID__c);
			mapItem.put('sf_billing_to_address_id', contact.CN_Billing_To_Address_ID__c);
			mapItem.put('lead_mg_account_id', contact.CN_Lead_MG_Account_ID__c);
			mapItem.put('customer_code', contact.Account.CN_Customer_Code__c);
			mapItem.put('used_mg_account_id', contact.Account.CN_MG_Account_ID__c);
			mapItem.put('up_code', contact.CN_UP_Code__c);
			maps.add(mapItem);
		}
		return maps;
	}

}
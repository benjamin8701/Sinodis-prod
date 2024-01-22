/*
 * ************************************************************************************************
 * Name : CN_Account_Customer_Code_To_Mg_Callout
 * Object :
 * Requirement : AC-017
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/7
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Account_Customer_Code_To_Mg_Callout {

	public static Map<String,Account> upsertCustomerCodeToMg(List<Account> accounts,List<CN_API_Call_Logger__c> listLog){

		//handleDataList
		List<Map<String, Object>> maps = handleData(accounts);

		//Necessary parameters for assembly request
		Talend_Setting__c setting = Talend_Setting__c.getInstance();
		Http http = new Http();
		HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
				setting.Sandbox_MG_Save_Customer_Code__c,
				setting.MG_Save_Customer_Code__c);

		Map<String,Account> sendSuccessMap = new Map<String,Account>();
		for(Map<String,Object> param:maps){
			CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
			try {
				String body = JSON.serialize(param);
				log.SetRequest(body);

				request.setBody(body);
				System.debug(body);
				HttpResponse response = http.send(request);
				log.SetResponse(response.getBody());

				// Parse the JSON response
				Integer resCode = response.getStatusCode();
				String errorMsg = '';
				String errorMessage = '';
				if(resCode == 200) {
					System.debug(response.getBody());
					Integer  cs = CN_HelperClass_WS.getRetDataCode(response.getBody());
					if(cs != null &&cs == 1) {
						Account account = new Account();
						account.Id = String.valueOf(param.get('MAP_ID'));
						sendSuccessMap.put(account.Id, account);
					}
				}else if(resCode == 503) {
					System.debug(resCode + ':' + Json.serialize(response.getBody()));
					errorMessage = 'Server Error';
				}else {
					if(resCode == 500) {
						errorMessage = 'Server Error';
					} else if(resCode == 404) {
						errorMessage = 'API Path Error';
					}
				}
				errorMsg = resCode + ':' + errorMessage + ':' +  Json.serialize(response.getBody());
				log.SetResult(resCode, Json.serialize(response.getBody()), errorMessage);
				listLog.add(log.getLog());
			} catch (Exception e){
				System.debug(e.getMessage());
				System.debug(e.getCause());
				System.debug(e.getStackTraceString());
				log.SetResult(0, '', e.getStackTraceString());
				listLog.add(log.getLog());
			}

		}
		return sendSuccessMap;

	}

	private static List<Map<String, Object>> handleData(List<Account> accounts) {
		List<Map<String,Object>> maps = new List<Map<String,Object>>();
		for(Account account : accounts){
			Map<String,Object> mapItem= new Map<String,Object>();
			mapItem.put('MAP_ID',account.Id);
			mapItem.put('license_name_cn',account.Name);
			mapItem.put('license_name_en',account.CN_License_Name_EN__c);
			mapItem.put('commercial_name_cn',account.CN_Store_Name_CN__c);
			mapItem.put('commercial_name_en',account.CN_Store_Name_EN__c);
			mapItem.put('customer_code',account.CN_Customer_Code__c);
			mapItem.put('owner',account.Owner.Name);
			mapItem.put('email',account.Owner.Email);
			mapItem.put('mg_account_id',account.CN_MG_Account_ID__c);
			mapItem.put('sales_team',account.CN_Sales_Team_UI__r.Name);
			mapItem.put('payment_terms',account.CN_Payment_Terms__c);
			mapItem.put('invoice_type',account.CN_Invoice_Type__c);
			mapItem.put('bank_account_name',account.CN_Bank_Account_Name__c);
			mapItem.put('tax_registration_no',account.CN_Tax_Registration_No__c);
			mapItem.put('invoicing_address_and_phone',account.CN_Invoicing_Address_and_Phone__c);
			mapItem.put('bank_account',account.CN_Bank_Account__c);
			mapItem.put('sales_office',account.CN_Sales_Office__c);
			mapItem.put('sales_org',account.CN_Sales_Org__c);
			mapItem.put('sales_district',account.CN_Sales_District__c);
			mapItem.put('finance_ar',account.CN_Finance_AR__r.Username);

			mapItem.put('bill_to',account.CN_Invoicing_Name_Bill_To_Party__c);
			
			maps.add(mapItem);
		}
		return maps;
	}
}
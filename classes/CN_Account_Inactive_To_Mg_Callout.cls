/*
 * ************************************************************************************************
 * Name : CN_Account_Inactive_To_Mg_Callout
 * Object :
 * Requirement :AC-018
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/4/7
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Account_Inactive_To_Mg_Callout {

	public static Map<String,Account> upsertInactiveToMg(List<Account> accounts,List<CN_API_Call_Logger__c> listLog){

		//handleDataList
		List<Map<String, Object>> maps = handleData(accounts);

		//Necessary parameters for assembly request
		Talend_Setting__c setting = Talend_Setting__c.getInstance();
		Http http = new Http();
		HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
				setting.Sandbox_MG_Update_Company_Status__c,
				setting.MG_Update_Company_Status__c);

		Map<String,Account> sendSuccessMap = new Map<String,Account>();
		for(Map<String,Object> param:maps){
			CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
			try{
				String body = JSON.serialize(param);
				log.SetRequest(body);
				System.debug(body);
				request.setBody(body);
				HttpResponse response = http.send(request);

				log.SetResponse(response.getBody());
				System.debug(response.getBody());

				// Parse the JSON response
				Integer resCode = response.getStatusCode();
				String errorMsg = '';
				String errorMessage = '';
				if(resCode == 200) {
					System.debug(response.getBody());
					Integer  code = CN_HelperClass_WS.getRetDataCode(response.getBody());
					if(code == 1) {
						Account account = new Account();
						account.Id = String.valueOf(param.get('MAP_ID'));
						sendSuccessMap.put(account.Id, account);
					}
				}else if(resCode == 503) {
					System.debug(resCode + ':' + Json.serialize(response.getBody()));
				}else {
					if(resCode == 500) {
						errorMessage = 'Server Error';
					} else if(resCode == 404) {
						errorMessage = 'API Path Error';
					}
					errorMsg = resCode + ':' + errorMessage + ':' +  Json.serialize(response.getBody());
				}
				System.debug(errorMsg);
				log.SetResult(resCode, Json.serialize(response.getBody()), errorMessage);
				listLog.add(log.getLog());
			}catch (Exception e){
				log.SetResult(0, '', e.getMessage());
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
			mapItem.put('account_id',account.CN_MG_Account_ID__c);
			mapItem.put('inactive',account.CN_Inactive__c?'1':'0');
			mapItem.put('billing_block',account.CN_Billing_Block__c);
			mapItem.put('delivery_block',account.CN_Delivery_Block__c);
			mapItem.put('order_block',account.CN_Order_Block__c);
			mapItem.put('block_sales_support',account.CN_Block_Sales_Support__c);
			mapItem.put('closed',account.CN_Closed__c);
			maps.add(mapItem);
		}
		return maps;
	}
}
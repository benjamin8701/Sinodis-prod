/*
 * ************************************************************************************************
 * Name : CN_Campaign_Upsert_To_Mg_Callout
 * Object :
 * Requirement : ET-001
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Campaign_Upsert_To_Mg_Callout {

    public static Map<String,Campaign> sendMgCampaign(List<Campaign> ltCampaigns,List<CN_API_Call_Logger__c> listLog){
        //handleDataList
        List<Map<String, Object>> maps = handleData(ltCampaigns);

        //Necessary parameters for assembly request
        Talend_Setting__c setting = Talend_Setting__c.getInstance();
        Http http = new Http();
        HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
                setting.Sandbox_MG_Update_Campaign__c,
                setting.MG_Update_Campaign__c);

        Map<String,Campaign> sendSuccessMap = new Map<String,Campaign>();

        for(Map<String,Object> param:maps) {
            CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();

            try {


                String body = JSON.serialize(param);
                log.SetRequest(body);
                System.debug(body);

                request.setBody(body);
                HttpResponse response = http.send(request);
                System.debug(response.getStatus());
                System.debug(response.getBody());
                // Parse the JSON response
                String data = Json.serialize(response.getBody());
                log.SetResponse(data);
                Integer resCode = response.getStatusCode();
                String errorMsg = '';
                String errorMessage = '';
                if (resCode == 200) {
                    Campaign campaign = new Campaign();
                    campaign.Id = String.valueOf(param.get('sf_campaign_id'));
                    campaign.CN_Need_Send_MG_Flag__c = 0;
                    sendSuccessMap.put(campaign.Id, campaign);
                } else {
                    if (resCode == 503) {
                        errorMessage = 'Service Unavailable';
                    } else if (resCode == 500) {
                        errorMessage = 'Server Error';
                    } else if (resCode == 404) {
                        errorMessage = 'API Path Error';
                    } else {
                        errorMessage = 'Others Error';
                    }
                }
                errorMsg = resCode + ':' + errorMessage + ':' + data;

                log.SetResult(1, 'success', 'success');
                listLog.add(log.getLog());
            } catch (Exception e) {
                log.SetResult(0, 'error', e.getMessage());
                listLog.add(log.getLog());
            }
        }
        return sendSuccessMap;
    }

    private static List<Map<String, Object>> handleData(List<Campaign> campaigns) {
        List<Map<String,Object>> maps = new List<Map<String,Object>>();
        for(Campaign campaign : campaigns){
            Map<String,Object> mapItem= new Map<String,Object>();
            mapItem.put('sf_campaign_id',campaign.Id);
            mapItem.put('brand',multiSelectToList(campaign.CN_Brand__c));
            mapItem.put('product_type',multiSelectToList(campaign.CN_Product_Type__c));
            mapItem.put('product_category',multiSelectToList(campaign.CN_Product_Category__c));
            mapItem.put('event_type',campaign.Type);
            mapItem.put('campaign_name',campaign.Name);
            mapItem.put('start_date',campaign.StartDate);
            mapItem.put('end_date',campaign.EndDate);
            mapItem.put('status',campaign.Status);
            mapItem.put('description',campaign.Description);
            mapItem.put('new_product_launch',campaign.CN_New_Product_Launch__c?1:0);
            mapItem.put('number_audiences',campaign.CN_Number_of_Audiences__c);
            mapItem.put('parent_campaign',campaign.ParentId);
            mapItem.put('channel',multiSelectToList(campaign.CN_Channel__c));
            mapItem.put('number_of_audiences',campaign.CN_Number_of_Audiences__c);
            mapItem.put('campaign_owner',campaign.OwnerId);
            mapItem.put('customer_category',multiSelectToList(campaign.CN_Customer_Category__c));
            mapItem.put('execution_type',multiSelectToList(campaign.CN_Execution_Type__c));
            mapItem.put('publish_date_enable','0');
            mapItem.put('registration_type','1');

            maps.add(mapItem);
        }
        return maps;
    }

    @Future(callout=true)
    public static void sendMgCampaignRealTime(String args){
        System.debug(args);
        List<Campaign> ltCampaigns = (List<Campaign>)JSON.deserialize(args,List<Campaign>.class);
        List<CN_API_Call_Logger__c> loggerList = new List<CN_API_Call_Logger__c>();
        Map<String,Campaign> res = sendMgCampaign(ltCampaigns,loggerList);
        update res.values();
        insert loggerList;
    }


    private static List<Object> multiSelectToList(String args){
        if(args == null || String.isEmpty(args)){
            return null;
        }
        return args.split(';');
    }



}
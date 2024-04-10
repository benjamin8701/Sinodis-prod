/*
 * ************************************************************************************************
 * Name : CN_CampaignMember_Upsert_To_Mg_Callout
 * Object :
 * Requirement : ET-002
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public class CN_CampaignMember_Upsert_To_Mg_Callout {

    public static void sendMgCampaignMember(List<CampaignMember> ltCampaignMembers){

        //Callout
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
        try {
            Talend_Setting__c setting = Talend_Setting__c.getInstance();

            Http http = new Http();
            HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
                    setting.Sandbox_MG_Update_CampaignMember__c,
                    setting.MG_Update_CampaignMember__c);

            String body = ConvertToRequestMsgBody(ltCampaignMembers);
            log.SetRequest(body);

            request.setBody(body);
            System.debug(request.getBody());
            HttpResponse response = http.send(request);
            // Parse the JSON response
            String data = Json.serialize(response.getBody());
            log.SetResponse(data);
            Integer resCode = response.getStatusCode();
            String errorMsg = '';
            String errorMessage = '';

            Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign>();
            if(resCode == 200) {
                System.debug(response.getBody());
                System.debug(CN_HelperClass_WS.getRetDataCode(response.getBody()));
                //sendSuccess.add(newCase);
                if (CN_HelperClass_WS.getRetDataCode(response.getBody()) == 1){
                    ResponseBody responseBody = (ResponseBody)JSON.deserialize(response.getBody(),ResponseBody.class );
                    List<RetData> retDatas = responseBody.message[0].retData;


                    for (CampaignMember item : ltCampaignMembers) {
                        Campaign camp = new Campaign();
                        camp.Id = item.CampaignId;
                        camp.CN_Need_Send_Childrens_MG_Flag__c = 0;
                        mapCampaigns.put(item.CampaignId, camp);
                    }


                    for (CN_CampaignMember_Upsert_To_Mg_Callout.RetData next : retDatas) {
                        if(next.sync_status == 1){
                            Campaign camp = new Campaign();
                            camp.Id = next.campaign_id;
                            camp.CN_Need_Send_Childrens_MG_Flag__c = 0;
                            mapCampaigns.put(next.campaign_id, camp);
                        }
                    }
                    System.debug(responseBody);
                }else{

                }

            }else {
                if(resCode == 503) {
                    errorMessage = 'Service Unavailable';
                }else if(resCode == 500) {
                    errorMessage = 'Server Error';
                } else if(resCode == 404) {
                    errorMessage = 'API Path Error';
                }else{
                    errorMessage = 'Others Error';
                }
            }
            errorMsg = resCode + ':' + errorMessage + ':' + data;

            if (mapCampaigns.values().size() > 0) {
                update mapCampaigns.values();
            }

            log.SetResult(1, 'success', 'success');
        } catch (Exception e){
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            System.debug(e.getCause());
            System.debug(e.getMessage());
            log.SetResult(0, 'failed', e.getMessage());
        }
        log.Save();
    }

    @Future(callout = true)
    public static void sendMgCampaignMemberRealTime(String args){

        System.debug(args);

        List<CampaignMember> ltCampaigns = (List<CampaignMember>)JSON.deserialize(args,List<CampaignMember>.class);
        Set<Id> setPIds = new Set<Id>();
        for (CampaignMember item : ltCampaigns) {
            setPIds.add(item.Id);
        }
        List<CampaignMember> ltChildrens = [SELECT Id, CampaignId, Account.CN_Customer_Code__c, Campaign.Owner.Name FROM CampaignMember WHERE Id IN :setPIds];
        sendMgCampaignMember(ltChildrens);

    }

    private static List<dataNode> ConvertToDataNode(List<CampaignMember> ltCampaignMembers) {
        Map<Id, dataNode> mapCPGroup = new Map<Id, dataNode>();
        for (CampaignMember item : ltCampaignMembers) {
            
            if (mapCPGroup.containsKey(item.CampaignId)) {
                dataNode node = mapCPGroup.get(item.CampaignId);
                node.account_code.add(item.Account.CN_Customer_Code__c);
            }
            else {
                dataNode node = new dataNode();
                node.id = String.valueOf(item.Id);
                node.campaign_id = String.valueOf(item.CampaignId);
                node.owner = item.Campaign.Owner.Name;
                node.account_code = new List<String>();
                node.account_code.add(item.Account.CN_Customer_Code__c);
                mapCPGroup.put(item.CampaignId, node);
            }
        }

        return mapCPGroup.values();
    }

    private static String ConvertToRequestMsgBody(List<CampaignMember> ltCampaignMembers) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('data', ConvertToDataNode(ltCampaignMembers));
        if (Untils.isSandbox()) {
            result.put('skip_campaign', Constants.SKIP_CAMPAIGN_VALUE);
        }
        return Json.serialize(result);
    }

    private class dataNode {
        public String id { get; set; }
        public String campaign_id { get; set; }
        public String owner { get; set; }
        public List<String> account_code { get; set; }
    }

    private class RetData{
        public String id { get; set; }
        public String campaign_id { get; set; }
        public Integer sync_status { get; set; }
        public String errorMess { get; set; }
    }

    private class Message{
        public Integer code { get; set; }
        public String msg { get; set; }
        public List<RetData> retData { get; set; }
    }

    private class ResponseBody{
        public Integer code { get; set; }
        public List<Message> message { get; set; }
    }
}
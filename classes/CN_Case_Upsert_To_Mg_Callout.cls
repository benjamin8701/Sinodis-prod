/*
 * ************************************************************************************************
 * Name : CN_Case_Upsert_To_Mg_Callout
 * Object :
 * Requirement : CP-003
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
public class CN_Case_Upsert_To_Mg_Callout {

    public static void sendMgCaseStatus(List<Case> ltCases){
        //Callout
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
        try {
            Talend_Setting__c setting = Talend_Setting__c.getInstance();

            Http http = new Http();
            HttpRequest request = CN_HelperClass_WS.createHttpRequestHelper(
                    setting.Sandbox_MG_Update_Case_Status__c,
                    setting.MG_Update_Case_Status__c);

            CaseNotifityBody objBody = new CaseNotifityBody(ltCases);

            String body = JSON.serialize(objBody);
            log.SetRequest(body);
            
            request.setBody(body);
            System.debug('JSON.serialize(objBody)'+body);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            String data = Json.serialize(response.getBody());
            log.SetResponse(data);
            Integer resCode = response.getStatusCode();
            String errorMsg = '';
            String errorMessage = '';
            if(resCode == 200) {
                //sendSuccess.add(newCase);
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

            for (Case item : ltCases) {
                item.CN_Need_Send_MG_Flag__c = 0;
            }
            update ltCases;

            System.debug(errorMsg);
    		log.SetResult(1, '执行成功', '接口成功');
        } catch (Exception e){
            log.SetResult(0, '执行失败', e.getMessage());
        }
    	log.Save();
    }

    private class dataNode {
        public List<Map<String,Object>> complaints { get; set; }
    }

    private class requestNode {
        public dataNode data { get; set; }
    }

    private class CaseNotifityBody {
        public requestNode request { get; set; }

        public CaseNotifityBody(List<Case> ltCases) {
            request = new requestNode();
            request.data = new dataNode();
            request.data.complaints = new List<Map<String, Object>>();

            for(Case item : ltCases) {
                Map<String,Object> paramMap = new Map<String, Object>();
                paramMap.put('id', item.CN_MG_Case_Id__c);
                paramMap.put('sf_status', item.Status);
                paramMap.put('actual_return_consistent_status', item.CN_Actual_Return_Consistent_Status__c);
                paramMap.put('cn_cs_feedback', item.CN_CS_Feedback__c);
                request.data.complaints.add(paramMap);
            }
        }
    }
}
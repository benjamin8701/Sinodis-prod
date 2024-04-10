/*
 * ************************************************************************************************
 * Name : CN_Case_Cancel_Rest
 * Object :
 * Requirement : CP-004
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping = '/CancelComplaintsUpsert')
global class CN_Case_Cancel_Rest {
     private static Set<String> SET_RequireFields = new Set<String>{
        'mgCaseId'
    };
    private static Map<String,String> MAP_Fields = new Map<String, String>{
        'mgCaseId' => 'CN_MG_Case_Id__c'
    };
 
    @HttpPost
    global static void post() {
        
        Map<String, Object> result = new Map<String, Object>();
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();

        String strBody;
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

            List<Case> ltDealData = (List<Case>)CN_HelperClass_WS.convertAPIMapToSObject('Case', MAP_Fields, ltDatas);

            map<String, Id> mapIds = new map<String, Id>();
            for (Case item : ltDealData) {
                mapIds.put(item.CN_MG_Case_Id__c, null);
            }
            for (Case item : [SELECT Id, CN_MG_Case_Id__c FROM Case WHERE CN_MG_Case_Id__c IN :mapIds.keySet()]) {
                mapIds.put(item.CN_MG_Case_Id__c, item.Id);
            }
            for (Case item : ltDealData) {
                item.Id = mapIds.get(item.CN_MG_Case_Id__c);
                item.Status = 'Canceled';
            }
        
            List<Database.SaveResult> databaseResult = Database.update(ltDealData, false);

            list<Map<String, Object>> ltRet = new list<Map<String, Object>>();
            Map<String, String> reMAP_Fields = new Map<String, String>();
            for (String item : MAP_Fields.keySet()) {
                reMAP_Fields.put(MAP_Fields.get(item), item);
            }

            for (Integer index = 0; index < databaseResult.size(); index++) {
                Database.SaveResult item = databaseResult[index];
                Object uniqueId = ltDealData[index].get('CN_MG_Case_Id__c');
                if (item.id != null && ltDealData[index].Id != item.id) {
                    throw new JSONException('Database.Result map ERROR, Please contact development.');
                }
                Map<String, Object> mapRet =
                        CN_HelperClass_WS.convertDatabaseResultToMap(item.id, item.success, item.errors, uniqueId,
                                reMAP_Fields);
                ltRet.add(mapRet);
            }
            result.put('retData', ltRet);
            result.put('message', 'success');
            result.put('code', 1);
            log.SetResult(1, JSON.serialize(ltRet), '');

        } catch (Exception ex) {
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
}
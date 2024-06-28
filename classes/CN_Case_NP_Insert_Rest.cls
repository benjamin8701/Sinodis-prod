/*
 * ************************************************************************************************
 * Name : CN_Case_NP_Insert_Rest
 * Object :
 * Requirement : CP-002
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping = '/NPComplaintsUpsert')
global class CN_Case_NP_Insert_Rest {
    private static Set<String> SET_RequireFields = new Set<String> {
        'mgCaseId',
        'complaintDate',
        'origin',
        'accountId',
        'recordType',
        'contactId'
    };
    private static Map<String, String> MAP_Fields = new Map<String, String> {
        'mgCaseId' => 'CN_MG_Case_Id__c',
        'complaintDate' => 'CN_Complaint_Date__c',
        'origin' => 'Origin',
        'accountId' => 'AccountId',
        'recordType' => 'Reason',
        'contactId' => 'ContactId',
        'description' => 'Description'
    };
    private static Map<String, Map<String, String>> MAP_ConvertFields = new Map<String, Map<String, String>> {
        'contactId' => new Map<String, String>{'targetField' => 'ID', 'object'=>'Contact', 'field'=>'CN_MG_Contact_ID__c'},
        'accountId' => new Map<String, String>{'targetField' => 'ID', 'object'=>'Account', 'field'=>'CN_MG_Account_ID__c'}
    };

    @HttpPost
    global static void post() {
        Map<String, Object> resultMap = new Map<String, Object>();
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();

        String strBody;
        try {

            strBody = RestContext.request.requestBody.toString();
            log.SetRequest(strBody);

            Map<String, Object> mapBody = (Map<String, Object>)JSON.deserializeUntyped(strBody);
            if (mapBody.containsKey('datas') == false) {
                throw new JSONException('[datas] cannot be null or empty');
            }

            List<Map<String,Object>> ltDatas = new List<Map<String,Object>>();
            for (Object item : (List<Object>)mapBody.get('datas')) {
                ltDatas.add((Map<String,Object>)item);
            }

            if (ltDatas.size() > 2000) {
                throw new JSONException('data size cannot be greater than 2000');
            }

            String errorMsg = '';
            for (Map<String, Object> item : ltDatas) {
                for (string requireField : SET_RequireFields) {
                    if (item.containsKey(requireField) == false) {
                        errorMsg += 'data must have require field [' + requireField + ']; ';
                    } else if (String.isBlank(String.valueOf(item.get(requireField)))) {
                        errorMsg += 'require field [' + requireField + '] can not be null; ';
                    }
                }
            }
            if (errorMsg != '') {
                throw new JSONException(errorMsg);
            }

            List<Case> ltDealData = (List<Case>)CN_HelperClass_WS.convertAPIMapToSObject('Case', MAP_Fields, MAP_ConvertFields, ltDatas);

            Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_RECORD_TYPE_Non_Product).getRecordTypeId();
            Id CSQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'CN_CS_Queue'].Id;

            for (Case newCase : ltDealData) {
                newCase.RecordTypeId = caseRtId;
                newCase.OwnerId = CSQueueId;
            }

            List<Database.SaveResult> databaseResult = Database.insert(ltDealData, false);

            list<Map<String, Object>> ltRet = new list<Map<String, Object>>();
            Map<String, String> reMapFields = new Map<String, String>();
            for (String item : MAP_Fields.keySet()) {
                reMapFields.put(MAP_Fields.get(item), item);
            }

            for (Integer index = 0; index < databaseResult.size(); index++) {
                Database.SaveResult result = databaseResult[index];
                Object uniqueId = ltDealData[index].get('CN_MG_Case_Id__c');
                if (result.id != null && ltDealData[index].Id != result.id) {
                    throw new JSONException('Database.Result map ERROR, Please contact development.');
                }
                Map<String, Object> mapRet = CN_HelperClass_WS.convertDatabaseResultToMap(result.id, result.success, result.errors, uniqueId, reMapFields);
                ltRet.add(mapRet);
            }

            resultMap.put('retData', ltRet);
            resultMap.put('message', 'success');
            resultMap.put('code', 1);
            log.SetResult(1, JSON.serialize(ltRet), '');

        } catch (Exception ex) {
            resultMap.put('retData', null);
            resultMap.put('message', ex.getMessage());
            resultMap.put('code', 0);
            log.SetResult(0, '', ex.getMessage());
        }
        log.SetResponse(JSON.serialize(resultMap));
        log.Save();

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Blob responseBody = Blob.valueOf(JSON.serialize(resultMap));
        res.responseBody = responseBody;
    }
}
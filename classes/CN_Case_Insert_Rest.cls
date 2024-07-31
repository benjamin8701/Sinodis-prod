/*
 * ************************************************************************************************
 * Name : CN_Case_Insert_Rest
 * Object :
 * Requirement : CP-001
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/10/1
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping = '/PComplaintsUpsert')
global class CN_Case_Insert_Rest {
    //add by He Peng 2024.2.29 Images
    private static Set<String> SET_RequireFields = new Set<String> {
        'mgCaseId',
        'complaintDate',
        'origin',
        'accountId',
        'skuCode',
        'skuQuantity',
        'sapBatchNumbers',
        'dn',
        'contactId',
        'productIssueImage',
        'packagingIssueImage',
        'otherProblemImages',
        'sapBatch'
    };
    //add by  Zhang Zhihao 2023.11.13 Check field 
    //add by He Peng 2024.2.27 expiry date
    private static Set<String> SET_BatchNums_RequireFields = new Set<String> {
        'sapBatchNumber',
        'number',
        'unit',
        'productionDate',
        'expiryDate'
    };
    //add by  Zhang Zhihao 2023.11.13 Check field 
     //add by He Peng 2024.3.11 sap_batch
    private static Map<String, String> MAP_Fields = new Map<String, String> {
        'mgCaseId' => 'CN_MG_Case_Id__c', 
        'complaintDate' => 'CN_Complaint_Date__c',
        'origin' => 'Origin',
        'reason' => 'CN_Other__c',
        'accountId' => 'AccountId',
        'contactId' => 'ContactId',
        'skuCode' => 'ProductId',
        'skuQuantity' => 'CN_SKU_Quantity__c',
        'dn' => 'CN_DN__c',
        'package' => 'CN_Package__c',
        'product' => 'CN_Product_Problem__c',
        'productIssueImage' => 'CN_Product_issue_image__c',
        'packagingIssueImage' => 'CN_Packaging_issue_image__c',
        'otherProblemImages' => 'CN_Other_problem_images__c',
        'wsCompanyName'      => 'CN_WS_Account_Name__c',
        'wsContactPhone'     => 'CN_WS_Telephone__c',
        'sapBatch'  => 'CN_SAP_Batch_Number__c',
        // add by ZhangZhihao 2024/5/21 Add field
        'CN_EC_Complaint_Id__c' => 'CN_EC_Complaint_Id__c'
        // add by ZhangZhihao 2024/5/21 Add field
    };
    private static Map<String, String> MAP_BatchNums_Fields = new Map<String, String> {
        'CN_Case_ID__c' => 'CN_Case_ID__c',
        'sapBatchNumber' => 'Name',
        'number' => 'CN_Return_Good_Number__c',
        'unit' => 'CN_Unit__c',
        'productionDate' => 'CN_Production_Date__c',
        'expiryDate' => 'CN_Expiry_Date__c'
    };
    private static Map<String, Map<String, String>> MAP_ConvertFields = new Map<String, Map<String, String>> {
        'contactId' => new Map<String, String>{'targetField' => 'ID', 'object'=>'Contact', 'field'=>'CN_MG_Contact_ID__c'},
        'accountId' => new Map<String, String>{'targetField' => 'ID', 'object'=>'Account', 'field'=>'CN_MG_Account_ID__c'} 
    };
    private static Map<String, String> MAP_UrlConvertFields = new Map<String, String> {
        'productIssueImage' => 'Product issue image',
        'packagingIssueImage' => 'Packaging issue image',
        'otherProblemImages' => 'Other problem images'
    };

    @HttpPost
    global static void post() {
        Map<String, Object> result = new Map<String, Object>();
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();

        String strBody;
        try {
            // --------------- Accept the JSON string passed from storage ------------------
            strBody = RestContext.request.requestBody.toString();
            log.SetRequest(strBody);

            Map<String, Object> mapBody = (Map<String, Object>)JSON.deserializeUntyped(strBody);
            if (mapBody.containsKey('datas') == false) {
                throw new JSONException('[datas] cannot be null or empty');
            }
            
            List<Map<String,Object>> ltDatas = new List<Map<String,Object>>();
          //add by  Zhang Zhihao 2023.11.13 Check field 
            List<Map<String,Object>> batchNumsDatas = new List<Map<String,Object>>();
            for (Object item : (List<Object>)mapBody.get('datas')) {
                Map<String,Object> itemMap = (Map<String,Object>)item;
                //ltDatas.add((Map<String,Object>)item);
                ltDatas.add(itemMap);
                //add by He Peng
                if(itemMap.get('sapBatchNumbers')!=null){
                    List<Object> sapBatchNumbers = (List<Object>)itemMap.get('sapBatchNumbers');
                    if(sapBatchNumbers.size()>0){  
                        for(Object batchNum:sapBatchNumbers){
                            batchNumsDatas.add((Map<String,Object>)batchNum);   
                        }
                    }else{
                        throw new JSONException('data must have require field sapBatchNumbers;');
                    }
                }else{
                    throw new JSONException('data must have require field sapBatchNumbers;');
                }     
            }
            
            //add by  Zhang Zhihao 2023.11.13 Check field 
            // ---------------No more than 2000 pieces in size ------------------
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
                if(item.get('package')==null&&item.get('product')==null){
                    errorMsg += 'require field [package] and [product] both can not be null; ';
                }
            }
            //add by  Zhang Zhihao 2023.11.13 Check field 
            //add by He Peng 2024.2.29 number not 0  3.1  =>  can be 0; 3.6  number send int=>string
            for (Map<String, Object> item : batchNumsDatas) {
                try{
                    item.put('number',Decimal.valueOf((String)item.get('number')));
                }
                catch(Exception e){
                    errorMsg += e.getMessage();
                }
                for (string requireField : SET_BatchNums_RequireFields) {
                    if (item.containsKey(requireField) == false) {
                        errorMsg += 'data must have require field [' + requireField + ']; ';
                    } else if (String.isBlank(String.valueOf(item.get(requireField)))) {
                        errorMsg += 'require field [' + requireField + '] can not be null; ';
                    }   
                }
            }
          //add by  Zhang Zhihao 2023.11.13 Check field 
            
            if (errorMsg != '') {
                throw new JSONException(errorMsg);
            }

            List<Case> ltDealData = (List<Case>)CN_HelperClass_WS.convertAPIMapToSObject('Case', MAP_Fields, MAP_ConvertFields, ltDatas);

            Id caseRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_RECORD_TYPE_COMPLAINT).getRecordTypeId();
            Id CSQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'CN_CS_Queue'].Id;

            Map<String, Case> mapDealData = new Map<String, Case>();
            for (Case item : ltDealData) {
                item.RecordTypeId = caseRtId;
                item.OwnerId = CSQueueId;
                mapDealData.put(item.CN_MG_Case_Id__c, item);
            }
            
            Map<String,String> reMAP_Fields = new Map<String,String>();
            for (String item : MAP_Fields.keySet()) {
                reMAP_Fields.put(MAP_Fields.get(item), item);
            }

            Map<String, Map<String,Object>> mapIdRet = new Map<String, Map<String,Object>>();
            List<Database.SaveResult> databaseResult = Database.insert(ltDealData, false);
            for (Integer index = 0; index < databaseResult.size(); index++) {
                Database.SaveResult item = databaseResult[index];
                Object uniqueId = ltDealData[index].get('CN_MG_Case_Id__c');
                if (item.id != null && ltDealData[index].Id != item.id) {
                    throw new JSONException('Database.Result map ERROR, Please contact development.');
                }
                Map<String,Object> mapRet = CN_HelperClass_WS.convertDatabaseResultToMap(item.id, item.success, item.errors, uniqueId, reMAP_Fields);
                mapIdRet.put((String)uniqueId, mapRet);
            }
            
            List<Map<String, Object>> ltBatchNums = new List<Map<String, Object>>();
            List<CN_Download_By_Url_Info__c> ltAttachments = new List<CN_Download_By_Url_Info__c>();
            for (Map<String, Object> item : ltDatas) {
                String uniqueId = (String)item.get('mgCaseId');
                if ((Boolean)mapIdRet.get(uniqueId).get('success')) {
                    for (object item2 : (List<object>)item.get('sapBatchNumbers')) {
                        Map<String, Object> batchNum = (Map<String, Object>)item2;
                        batchNum.put('CN_Case_ID__c', mapIdRet.get(uniqueId).get('sfid'));
                        ltBatchNums.add(batchNum);
                    }
                    for (String item2 : MAP_UrlConvertFields.keySet()) {
                        if (String.isNotBlank((String)item.get(item2))) {
                            CN_Download_By_Url_Info__c file = CN_Download_By_Url_Helper.convert(
                                (String)mapIdRet.get(uniqueId).get('sfid'), MAP_UrlConvertFields.get(item2), (String)item.get(item2), 'Case', item2);
                            ltAttachments.add(file);
                        }
                    }
                }
            }

            List<CN_Case_SAP_Batch__c> ltDealBatchNums = (List<CN_Case_SAP_Batch__c>)CN_HelperClass_WS.convertAPIMapToSObject(
                'CN_Case_SAP_Batch__c',MAP_BatchNums_Fields, ltBatchNums);

            // no add err deal
            List<Database.SaveResult> databaseBatchNumResult = Database.insert(ltDealBatchNums, false);
            List<Database.SaveResult> databasefileResult = Database.insert(ltAttachments, false);
            
            result.put('retData', mapIdRet.values());
            result.put('message', 'success');
            result.put('code', 1);
            log.SetResult(1, JSON.serialize(mapIdRet.values()), '');

        } catch (Exception ex) {
            result.put('retData', null);
            result.put('message', ex.getMessage());
            result.put('code', 0);
            log.SetResult(0, '', ex.getMessage());
        }
        System.debug('result==>' + result);
        log.SetResponse(JSON.serialize(result));
        log.Save();

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Blob responseBody = Blob.valueOf(JSON.serialize(result));
        res.responseBody = responseBody;
    }
}
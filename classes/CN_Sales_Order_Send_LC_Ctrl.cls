/**************************************************************************************************
 * Name           : CN_Sales_Order_Send_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas
 * Create Date    : 2021-05-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Sales_Order_Send_LC_Ctrl {
    @AuraEnabled
    public static Boolean retrieveSOStatus(String salesOrderId){
        try {
            CN_Sales_Order__c so = [SELECT Id, 
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_Up_Code__c
                                    FROM CN_Sales_Order__c
                                    WHERE Id =: salesOrderId];
            if(so.CN_Sync_Time__c > Datetime.now().addSeconds(-5)) {
                throw new CustomException(System.label.CN_Sales_Order_Warning_Msg_Too_Frequency);
            }
            Map<String, Object> calloutResult = doCallout(so.CN_Up_Code__c);
            Boolean isSuccess = (Boolean)calloutResult.get('isSuccess');
            String errorMessage = (String)calloutResult.get('errorMessage');
            if(!isSuccess) {
                CN_Sales_Order__c soUpdate = new CN_Sales_Order__c(
                    Id = so.Id,
                    CN_Sync_Status__c = Constants.CN_SO_SYNC_STATUS_FAIL,
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage
                );
                update soUpdate;
                System.debug(errorMessage);
                throw new CustomException(errorMessage);
            } else {
                CN_Sales_Order__c soUpdate = new CN_Sales_Order__c(
                    Id = so.Id,
                    CN_Sync_Status__c = Constants.CN_SO_SYNC_STATUS_SUCCESS,
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = ''
                );
                update soUpdate;
            }
            return isSuccess;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Map<String, Object> doCallout(String salesOrderNumber) {
        
        if(String.isBlank(salesOrderNumber)) {
            return new Map<String, Object>{
                'isSuccess' => false,
                'errorMessage' => 'No Valid Sales Order Number Found!'
            };
        }
        
        Boolean isSendSuccess = false;
        String errorMsg = '';
    	Talend_Setting__c setting = Talend_Setting__c.getInstance();
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        Blob headerValue;
        if (Untils.isSandbox()) {
            request.setEndpoint(setting.Sanbox_Sales_Order_Update_Endpoint__c);
            headerValue = Blob.valueOf(setting.Sandbox_User_Name__c + ':' + setting.Sandbox_Password__c);
        } else {
            request.setEndpoint(setting.Sales_Order_Update_Endpoint__c);
            headerValue = Blob.valueOf(setting.User_Name__c + ':' + setting.Password__c);
        }
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setMethod('POST');
        request.setBody('' + salesOrderNumber + '');
        request.setTimeout(120000);
        HTTPResponse resp = http.send(request);
        Integer resCode = resp.getStatusCode();
        String resBody = resp.getBody();
        System.debug(resBody);
        if(resCode == 200) {
            try{
                Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
                errorMsg = resultMap.containsKey('CN_Sync_Error_Message__c')? (String)resultMap.get('CN_Sync_Error_Message__c'): '';
                if(resultMap.containsKey('CN_Sync_Status__c')) {
                    String resultStatus = (String)resultMap.get('CN_Sync_Status__c');
                    if('S'.equals(resultStatus)) {
                        isSendSuccess = true;
                        Map<String, Schema.SObjectField> fieldMap = Schema.CN_Sales_Order__c.sObjectType.getDescribe().fields.getMap();
                        CN_Sales_Order__c so = new CN_Sales_Order__c();
                        List<Object> orderItemList = new List<Object>();
                        for(String key: resultMap.keySet()) {
                            if(!'Sales_Order_Item__r'.equals(key)) {
                                String fieldType = String.valueof(fieldMap.get(key).getDescribe().getType());
                                if(fieldType == 'Date') {
                                    so.put(key, Date.valueOf((String)resultMap.get(key)));
                                } else if(fieldType == 'Boolean') {
                                    so.put(key, (Boolean)resultMap.get(key));
                                } else if(fieldType == 'Integer') {
                                    so.put(key, (Integer)resultMap.get(key));
                                } else if(fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'CURRENCY') {
                                    so.put(key, (Decimal)resultMap.get(key));
                                } else {
                                    so.put(key, resultMap.get(key));
                                }
                            } else {
                                orderItemList = (List<Object>)resultMap.get(key);
                            }
                        }
                        so.put('CN_Sync_Time__c', Datetime.now());
                        upsert so CN_Up_Code__c;
                        
                        List<CN_Sales_Order_Item__c> soItemList = new List<CN_Sales_Order_Item__c>();
                        fieldMap = Schema.CN_Sales_Order_Item__c.sObjectType.getDescribe().fields.getMap();
                        if(orderItemList.size() > 0) {
                            for(Object item: orderItemList) {
                                Map<String, Object> itemMap = (Map<String, Object>)item;
                                CN_Sales_Order_Item__c soItem = new CN_Sales_Order_Item__c();
                                for(String key: itemMap.keySet()) {
                                    String fieldType = String.valueof(fieldMap.get(key).getDescribe().getType());
                                    if(fieldType == 'Date') {
                                        soItem.put(key, Date.valueOf((String)itemMap.get(key)));
                                    } else if(fieldType == 'Boolean') {
                                        soItem.put(key, (Boolean)itemMap.get(key));
                                    } else if(fieldType == 'Integer') {
                                        soItem.put(key, (Integer)itemMap.get(key));
                                    } else if(fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'CURRENCY') {
                                        soItem.put(key, (Decimal)itemMap.get(key));
                                    } else {
                                        soItem.put(key, itemMap.get(key));
                                    }
                                }
                                soItem.put('CN_Order_Number__c', so.Id);
                                soItemList.add(soItem);
                            }
                            upsert soItemList CN_Up_Code__c;
                        }
                    } else if('E'.equals(resultStatus) || String.isBlank(resultStatus)) {
                        throw new CustomException(errorMsg);
                    } else {
                        throw new CustomException(errorMsg);
                    }
                } else {
                    throw new CustomException(errorMsg);
                }
            } catch(Exception e) {
                isSendSuccess = false;
                errorMsg = e.getMessage();
            }
        } else {
            String errorMessage = '';
            isSendSuccess = false;
            if(resCode == 500) {
                errorMessage = System.Label.CN_Account_API_Server_Error;
            } else if(resCode == 400) {
                errorMessage = System.Label.CN_Account_Request_Validation_Fail;
            } else if(resCode == 401) {
                errorMessage = System.Label.CN_Account_API_US_PW_Error;
            } else if(resCode == 404) {
                errorMessage = System.Label.CN_Account_API_Path_Error;
            }
            errorMsg = resCode + ':' + errorMessage + System.Label.CN_Account_Contact_System_Admin;
        }
        System.debug(errorMsg);
        return new Map<String, Object>{
            'isSuccess' => isSendSuccess,
            'errorMessage' => errorMsg
        };
    }
}
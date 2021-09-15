/**************************************************************************************************
 * Name           : CN_Quote_Send_To_SAP_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Send_To_SAP_LC_Ctrl {
    public static String moduleName = System.Label.CN_Quote_Name;
    @AuraEnabled
    public static Map<String, Object> getQuoteInfoAndCheckEditPermisison(String recordId){
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Not_Found, new List<String>{moduleName}));
        }
        
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        Quote quo = new Quote();
        hasCreatePermission = Untils.checkObjectCreatePermission('Quote');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_No_Permission, new List<String>{moduleName}));
        }
        
        List<Quote> quoList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c
                                    FROM Quote
                                    WHERE Id =: recordId];      //SQL修改
        if(quoList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Not_Found, new List<String>{moduleName}));
        }
        
        quo = quoList[0];        
        if(Constants.CN_QUOTE_SYNC_STATUS_SUCCESS.equals(quo.CN_Sync_Status__c) ) {
            errorMsg = String.format(System.Label.CN_Quote_Had_Synced, new List<String>{moduleName});
        }
        if(checkTimeInterval(quo)) {
            errorMsg = System.Label.CN_Quote_Warning_Msg_Too_Frequency;
        }
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }

    @auraEnabled
    public static Map<String, Object> sendQuote(String recordId) {
        
        System.debug('Send Start');
        System.debug(Datetime.now().getTime());
        Boolean isSendSuccess = false;
        String errorMessage = '';
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Not_Found, new List<String>{moduleName}));
        }
        
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('Quote');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_No_Permission, new List<String>{moduleName}));
        }

        List<Quote> quoList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c        //SQL
                                    FROM Quote
                                    WHERE Id =: recordId];
        if(quoList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Not_Found, new List<String>{moduleName}));
        }

        Quote quoToSend = quoList[0];
        if(Constants.CN_QUOTE_SYNC_STATUS_SUCCESS.equals(quoToSend.CN_Sync_Status__c) ) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Had_Synced, new List<String>{moduleName}));
        }
        if(checkTimeInterval(quoToSend)) {
            throw new AuraHandledException(System.Label.CN_Quote_Warning_Msg_Too_Frequency);      //label
        }
        
        Map<String, Object> resultMap = doCallout(quoToSend);
        Quote quo_result = (Quote)resultMap.get('Quote');
        //String businessUnitCode = '';

        errorMessage = (String)resultMap.get('errorMessage');
        if((Boolean)resultMap.get('isSendSuccess')) {
            isSendSuccess = true;
            // 这里是已经发成功，具体的判断逻辑需要确定接口
            // if(bu_result.CN_Business_Unit_Code__c !=null && String.isNotBlank(bu_result.CN_Business_Unit_Code__c)){
            //     businessUnitCode = bu_result.CN_Business_Unit_Code__c;
            // } else {
            //     throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Code_Is_Blank, new List<String>{moduleName}));      //label
            // }
             Quote quoToUpdate = new Quote(
            //         Id = buToSend.Id,
            //         CN_Sync_Status__c = Constants.CN_BU_SYNC_STATUS_SUCCESS,    
            //         CN_Sync_Time__c = Datetime.now(),
            //         CN_Sync_Error_Message__c = errorMessage,
            //         CN_Business_Unit_Code__c = businessUnitCode
            );
            try{
				update quoToUpdate;
            } catch(Exception e) {
                errorMessage = e.getMessage();
                throw new AuraHandledException( e.getMessage());   
            }
        }else{
            Quote quoToUpdate = new Quote(
                    Id = quoToSend.Id,
                    CN_Sync_Status__c = Constants.CN_QUOTE_SYNC_STATUS_FAIL,
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage
            );
            try{
				update quoToUpdate;
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   
            }
        }
        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMessage
        };
    }

    public static Map<String, Object> doCallout(Quote quo_select) {
        
        Boolean isSendSuccess = false;
        String errorMsg = '';
        Talend_Setting__c setting = Talend_Setting__c.getInstance();
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        Blob headerValue;
        if (Untils.isSandbox()) {
            request.setEndpoint(setting.Sandbox_Customer_Hierarchy_Endpoint__c);
            headerValue = Blob.valueOf(setting.Sandbox_User_Name__c + ':' + setting.Sandbox_Password__c);
        } else {
            request.setEndpoint(setting.Customer_Hierarchy_Endpoint__c);
            headerValue = Blob.valueOf(setting.User_Name__c + ':' + setting.Password__c);
        }

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        // 确定接口后来构建Json
        // gen.writeStringField('Name',quo_select.Name);
        // gen.writeStringField('CN_Up_Code__c',quo_select.CN_Business_Unit_Code__c == null? '': quo_select.CN_Business_Unit_Code__c);
        // gen.writeStringField('CN_Parent_Up_Code__c','');
        // gen.writeStringField('CN_City_API__c',quo_select.CN_City_API__c);
        gen.writeEndObject();
        gen.close();

        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setBody(gen.getAsString());
        request.setTimeout(120000);
        HTTPResponse resp = http.send(request);
        Integer resCode = resp.getStatusCode();
        String resBody = resp.getBody();
        System.debug(resBody);

        Quote quo = new Quote();
        if(resCode == 200) {
            try{
                Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
                errorMsg = resultMap.containsKey('CN_Sync_Error_Message__c')? (String)resultMap.get('CN_Sync_Error_Message__c'): '';
                if(resultMap.containsKey('CN_Sync_Status__c')) {
                    String resultStatus = (String)resultMap.get('CN_Sync_Status__c');
                    if('S'.equals(resultStatus)) {
                        
                        isSendSuccess = true;
                        // 等接口确定下来，这个要从SAP中获取什么
                        // if(resultMap.containsKey('CN_Up_Code__c')) {
                        //     quo.CN_Business_Unit_Code__c = (String)resultMap.get('CN_Up_Code__c');      //Business Unit Code
                        // } else {
                        //     quo.CN_Business_Unit_Code__c = null;    //Business Unit Code
                        // }
                        quo.CN_Sync_Time__c = Datetime.now();
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
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMsg,
            'quote' => quo
        };
    }

    public static Boolean checkTimeInterval(Quote quoToSend){
        Boolean isLessFiveMins = (quoToSend.CN_Sync_Status__c != null && quoToSend.CN_Sync_Time__c != null 
        && quoToSend.CN_Sync_Time__c > Datetime.now().addSeconds(-5));     
        return isLessFiveMins;
    }
}
/**************************************************************************************************
 * Name           : CN_ST_Send_To_SAP_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-21
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_ST_Send_To_SAP_LC_Ctrl {
    public static String moduleName = System.Label.CN_Sales_Team_Name;
    @AuraEnabled
    public static Map<String, Object> getBUInfoAndCheckEditPermisison(String recordId){
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName})); 
        }
        
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        CN_Sales_Team__c st = new CN_Sales_Team__c();
        hasCreatePermission = Untils.checkObjectCreatePermission('CN_Sales_Team__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_No_Permission, new List<String>{moduleName}));
        }
        
        List<CN_Sales_Team__c> stList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_City_API__c,
                                        CN_Sales_Team_Code__c
                                    FROM CN_Sales_Team__c
                                    WHERE Id =: recordId];
        if(stList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }
        
        st = stList[0];        
        if(Constants.CN_BU_SYNC_STATUS_SUCCESS.equals(st.CN_Sync_Status__c) ) {
            errorMsg = String.format(System.Label.CN_Business_Unit_Had_Synced, new List<String>{moduleName}); 
        }
        if(checkTimeInterval(st)) {
            errorMsg = System.Label.CN_CustomerHierarchy_Warning_Msg_Too_Frequency;   
        }
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }

    @auraEnabled
    public static Map<String, Object> sendSalesTeam(String recordId) {
        
        System.debug('Send Start');
        System.debug(Datetime.now().getTime());
        Boolean isSendSuccess = false;
        String errorMessage = '';
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }
        
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('CN_Sales_Team__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_No_Permission, new List<String>{moduleName}));
        }

        List<CN_Sales_Team__c> stList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_City_API__c,
                                        CN_Sales_Team_Code__c,
                                        CN_Business_Unit_Code__c
                                    FROM CN_Sales_Team__c
                                    WHERE Id =: recordId];
        if(stList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }

        CN_Sales_Team__c stToSend = stList[0];
        if(Constants.CN_BU_SYNC_STATUS_SUCCESS.equals(stToSend.CN_Sync_Status__c) ) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Had_Synced, new List<String>{moduleName}));   
        }
        if(checkTimeInterval(stToSend)) {
            throw new AuraHandledException(System.Label.CN_CustomerHierarchy_Warning_Msg_Too_Frequency);   
        }
        
        Map<String, Object> resultMap = doCallout(stToSend);
        CN_Sales_Team__c st_result = (CN_Sales_Team__c)resultMap.get('salesTeam');
        String stCode = '';

        errorMessage = (String)resultMap.get('errorMessage');
        if((Boolean)resultMap.get('isSendSuccess')) {
            isSendSuccess = true;
            if(st_result.CN_Sales_Team_Code__c !=null && String.isNotBlank(st_result.CN_Sales_Team_Code__c)){
                stCode = st_result.CN_Sales_Team_Code__c;
            } else {
                throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Code_Is_Blank, new List<String>{moduleName}));   
            }
            CN_Sales_Team__c stToUpdate = new CN_Sales_Team__c(
                    Id = stToSend.Id,
                    CN_Sync_Status__c = Constants.CN_BU_SYNC_STATUS_SUCCESS,    
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage,
                    CN_Sales_Team_Code__c = stCode
            );
            try{
                update stToUpdate;
            } catch(Exception e) {
                errorMessage = e.getMessage();
                throw new AuraHandledException( e.getMessage());   
            }
        }else{
			if(String.isBlank(stToSend.CN_Sales_Team_Code__c) && st_result.CN_Sales_Team_Code__c !=null && String.isNotBlank(st_result.CN_Sales_Team_Code__c)){
                stCode = st_result.CN_Sales_Team_Code__c;
            }
            CN_Sales_Team__c stToUpdate = new CN_Sales_Team__c(
                    Id = stToSend.Id,
                    CN_Sync_Status__c = Constants.CN_BU_SYNC_STATUS_FAIL,
                    CN_Sales_Team_Code__c = String.isBlank(stCode)? stToSend.CN_Sales_Team_Code__c: stCode,
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage
            );
            try{
                update stToUpdate;
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   
            }
        }
        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMessage
        };
    }

    public static Map<String, Object> doCallout(CN_Sales_Team__c st_select) {
        
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
        gen.writeStringField('Name',st_select.Name);
        gen.writeStringField('CN_Up_Code__c',st_select.CN_Sales_Team_Code__c == null? '': st_select.CN_Sales_Team_Code__c);
        gen.writeStringField('CN_Parent_Up_Code__c',st_select.CN_Business_Unit_Code__c);
        gen.writeStringField('CN_City_API__c',st_select.CN_City_API__c);
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

        CN_Sales_Team__c st = new CN_Sales_Team__c();
        if(resCode == 200) {
            try{
                Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
                errorMsg = resultMap.containsKey('CN_Sync_Error_Message__c')? (String)resultMap.get('CN_Sync_Error_Message__c'): '';
                if(resultMap.containsKey('CN_Sync_Status__c')) {
                    String resultStatus = (String)resultMap.get('CN_Sync_Status__c');
                    if('S'.equals(resultStatus)) {
                        
                        isSendSuccess = true;
                        if(resultMap.containsKey('CN_Up_Code__c')) {
                            st.CN_Sales_Team_Code__c = (String)resultMap.get('CN_Up_Code__c');
                        } else {
                            st.CN_Sales_Team_Code__c = null;
                        }
                        st.CN_Sync_Time__c = Datetime.now();
                    } else if('E'.equals(resultStatus) || String.isBlank(resultStatus)) {
                        if(resultMap.containsKey('CN_Up_Code__c')) {
                            if(resultMap.get('CN_Up_Code__c') != null) {
                            	st.CN_Sales_Team_Code__c = (String)resultMap.get('CN_Up_Code__c');
                            }
                        } else {
                        	throw new CustomException(errorMsg);
                        }
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
            'salesTeam' => st
        };
    }

    public static Boolean checkTimeInterval(CN_Sales_Team__c stToSend){
        Boolean isLessFiveMins = (stToSend.CN_Sync_Status__c != null && stToSend.CN_Sync_Time__c != null 
        && stToSend.CN_Sync_Time__c > Datetime.now().addSeconds(-5));     
        return isLessFiveMins;
    }
}
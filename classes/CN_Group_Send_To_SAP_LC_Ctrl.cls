/**************************************************************************************************
 * Name           : CN_Group_Send_To_SAP_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-21
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Group_Send_To_SAP_LC_Ctrl {
    public static String moduleName = System.Label.CN_Group_Name;
    @AuraEnabled
    public static Map<String, Object> getBUInfoAndCheckEditPermisison(String recordId){
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName})); 
        }
        
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        CN_Group__c grp = new CN_Group__c();
        hasCreatePermission = Untils.checkObjectCreatePermission('CN_Group__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_No_Permission, new List<String>{moduleName}));
        }
        
        List<CN_Group__c> groupList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_City_API__c,
                                        CN_Group_Code__c
                                    FROM CN_Group__c
                                    WHERE Id =: recordId];
        if(groupList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }
        
        grp = groupList[0];        
        if(Constants.CN_BU_SYNC_STATUS_SUCCESS.equals(grp.CN_Sync_Status__c) ) {
            errorMsg = String.format(System.Label.CN_Business_Unit_Had_Synced, new List<String>{moduleName}); 
        }
        if(checkTimeInterval(grp)) {
            errorMsg = System.Label.CN_CustomerHierarchy_Warning_Msg_Too_Frequency;   
        }
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }

    @auraEnabled
    public static Map<String, Object> sendGroup(String recordId) {
        
        System.debug('Send Start');
        System.debug(Datetime.now().getTime());
        Boolean isSendSuccess = false;
        String errorMessage = '';
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }
        
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('CN_Group__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_No_Permission, new List<String>{moduleName}));
        }

        List<CN_Group__c> groupList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_City_API__c,
                                        CN_Group_Code__c,
                                        CN_Sales_Team_Code__c
                                    FROM CN_Group__c
                                    WHERE Id =: recordId];
        if(groupList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }

        CN_Group__c groupToSend = groupList[0];
        if(Constants.CN_BU_SYNC_STATUS_SUCCESS.equals(groupToSend.CN_Sync_Status__c) ) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Had_Synced, new List<String>{moduleName}));   
        }
        if(checkTimeInterval(groupToSend)) {
            throw new AuraHandledException(System.Label.CN_CustomerHierarchy_Warning_Msg_Too_Frequency);   
        }
        
        Map<String, Object> resultMap = doCallout(groupToSend);
        CN_Group__c group_result = (CN_Group__c)resultMap.get('group');
        String groupCode = '';

        errorMessage = (String)resultMap.get('errorMessage');
        if((Boolean)resultMap.get('isSendSuccess')) {
            isSendSuccess = true;
            if(group_result.CN_Group_Code__c !=null && String.isNotBlank(group_result.CN_Group_Code__c)){
                groupCode = group_result.CN_Group_Code__c;
            } else {
                throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Code_Is_Blank, new List<String>{moduleName}));   
            }
            CN_Group__c groupToUpdate = new CN_Group__c(
                    Id = groupToSend.Id,
                    CN_Sync_Status__c = Constants.CN_BU_SYNC_STATUS_SUCCESS,    
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage,
                    CN_Group_Code__c = groupCode
            );
            try{
                update groupToUpdate;
            } catch(Exception e) {
                errorMessage = e.getMessage();
                throw new AuraHandledException( e.getMessage());   
            }
        }else{
            CN_Group__c groupToUpdate = new CN_Group__c(
                    Id = groupToSend.Id,
                    CN_Sync_Status__c = Constants.CN_BU_SYNC_STATUS_FAIL,   
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage
            );
            try{
                update groupToUpdate;
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   
            }
        }
        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMessage
        };
    }

    public static Map<String, Object> doCallout(CN_Group__c group_select) {
        
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
        gen.writeStringField('Name',group_select.Name);
        gen.writeStringField('CN_Up_Code__c',group_select.CN_Group_Code__c);
        gen.writeStringField('CN_Parent_Up_Code__c', group_select.CN_Sales_Team_Code__c);
        gen.writeStringField('CN_City_API__c',group_select.CN_City_API__c);
        gen.writeEndObject();
        gen.close();

        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setMethod('POST');
        request.setBody(gen.getAsString());
        request.setTimeout(120000);
        HTTPResponse resp = http.send(request);
        Integer resCode = resp.getStatusCode();
        String resBody = resp.getBody();
        System.debug(resBody);

        CN_Group__c grp = new CN_Group__c();
        if(resCode == 200) {
            try{
                Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
                errorMsg = resultMap.containsKey('CN_Sync_Error_Message__c')? (String)resultMap.get('CN_Sync_Error_Message__c'): '';
                if(resultMap.containsKey('CN_Sync_Status__c')) {
                    String resultStatus = (String)resultMap.get('CN_Sync_Status__c');
                    if('Success'.equals(resultStatus)) {
                        
                        isSendSuccess = true;
                        if(resultMap.containsKey('CN_Up_Code__c')) {
                            grp.CN_Group_Code__c = (String)resultMap.get('CN_Up_Code__c');
                        } else {
                            grp.CN_Group_Code__c = null;
                        }
                        grp.CN_Sync_Time__c = Datetime.now();
                    } else if('FAIL'.equals(resultStatus) || String.isBlank(resultStatus)) {
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
            'group' => grp
        };
    }

    public static Boolean checkTimeInterval(CN_Group__c groupToSend){
        Boolean isLessFiveMins = (groupToSend.CN_Sync_Status__c != null && groupToSend.CN_Sync_Time__c != null 
        && groupToSend.CN_Sync_Time__c > Datetime.now().addSeconds(-5));     
        return isLessFiveMins;
    }
}
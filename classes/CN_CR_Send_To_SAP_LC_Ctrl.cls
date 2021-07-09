/**************************************************************************************************
 * Name           : CN_CR_Send_To_SAP_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wang Jessica
 * Create Date    : 2021-05-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Send_To_SAP_LC_Ctrl {
    @AuraEnabled
    public static Map<String, Object> getCRInfoAndCheckEditPermisison(String recordId){
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_CR_Not_Found);
        }
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        CN_Change_Request__c cr = new CN_Change_Request__c();
        hasCreatePermission = Untils.checkObjectCreatePermission('CN_Change_Request__c');
        system.debug('hasCreatePermission' + hasCreatePermission);
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_CR_No_Permission);
        }
        List<CN_Change_Request__c> crList = [SELECT Id, 
                                        Name,
                                        CN_Change_Request_Status__c, 
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_Synchronized__c,
                                        CN_Sync_Error_Message__c 
                                    FROM CN_Change_Request__c 
                                    WHERE Id =: recordId];
        if(crList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_CR_Not_Found);
        }
        cr = crList[0];        
        if(cr.CN_Synchronized__c) {
            errorMsg = System.Label.CN_CR_Had_Synced;
        }
        if(cr.CN_Sync_Status__c == Constants.CN_CR_SYNC_STATUS_NO_NEED_TO_SYNC) {
            errorMsg = System.Label.CN_CR_Sync_No_Need;
        }
        if(checkTimeInterval(cr)) {
            errorMsg = System.Label.CN_Account_Wait_5_Mins;   
        }
        if(cr.CN_Change_Request_Status__c != Constants.CN_CR_STATUS_APPROVALED){   
            errorMsg = System.Label.CN_CR_Not_Approved;     
        }                                                   
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }
    @auraEnabled
    public static Map<String, Object> sendCR(String recordId) {
        System.debug('Send Start');
        System.debug(Datetime.now().getTime());
        Boolean isSendSuccess = false;
        String errorMessage = '';
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_CR_Not_Found);
        }
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('CN_Change_Request__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_CR_No_Permission);
        }
        List<CN_Change_Request__c> crList = [SELECT Id, 
                                        Name,
                                        CN_Change_Request_Status__c,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_Synchronized__c,
                                        CN_Sync_Error_Message__c 
                                    FROM CN_Change_Request__c 
                                    WHERE Id =: recordId];
        if(crList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_CR_Not_Found);
        }

        CN_Change_Request__c crToSend = crList[0];
        if(crToSend.CN_Synchronized__c) {
            throw new AuraHandledException(System.Label.CN_CR_Had_Synced);
        }
        if(crToSend.CN_Sync_Status__c == Constants.CN_CR_SYNC_STATUS_NO_NEED_TO_SYNC) {
            throw new AuraHandledException(System.Label.CN_CR_Sync_No_Need);
        }
        if(checkTimeInterval(crToSend)) {
            throw new AuraHandledException(System.Label.CN_Account_Wait_5_Mins);   
        }
        if(crToSend.CN_Change_Request_Status__c != Constants.CN_CR_STATUS_APPROVALED){   
            throw new AuraHandledException(System.Label.CN_CR_Not_Approved);     
        }
        Map<String, Object> resultMap = callTalendAPI(crToSend);
        errorMessage = (String)resultMap.get('errorMsg');
        if((Boolean)resultMap.get('isSendSuccess')) {
            isSendSuccess = true;
            CN_Change_Request__c crToUpdate = new CN_Change_Request__c();
            crToUpdate.Id = crToSend.Id;
            crToUpdate.CN_Sync_Status__c = 'Sent';
            crToUpdate.CN_Sync_Time__c = Datetime.now();
            crToUpdate.CN_Sync_Error_Message__c = '';
            update crToUpdate;
        }
        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMessage
        };
    }
    public static Map<String, Object> callTalendAPI(CN_Change_Request__c crToSend) {
        Boolean isSendSuccess = false;
        String errorMsg = '';
        Talend_Setting__c setting = Talend_Setting__c.getInstance();
        try {
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            Blob headerValue;
            if (Untils.isSandbox()) {
                request.setEndpoint(setting.Sanbox_Change_Request_Endpoint__c);
                headerValue = Blob.valueOf(setting.Sandbox_User_Name__c + ':' + setting.Sandbox_Password__c);
            } else {
                request.setEndpoint(setting.Change_Request_Endpoint__c);
                headerValue = Blob.valueOf(setting.User_Name__c + ':' + setting.Password__c);
            }
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('POST');
            request.setBody('(\'' + crToSend.Id + '\')');
            System.debug(request);
            HTTPResponse resp = http.send(request);
            Integer resCode = resp.getStatusCode();
            String resBody = resp.getBody();
            if(resCode == 200) {
                isSendSuccess = true;  
            } else {
                String errorMessage = '';
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
        } catch (Exception e) {
            isSendSuccess = false;
            errorMsg = e.getMessage();
        }
        System.debug('Send End');
        System.debug(Datetime.now().getTime());
        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMsg' => errorMsg
        };
    }

    public static Boolean checkTimeInterval(CN_Change_Request__c crToSend){
        Boolean isLessFiveMins = (!crToSend.CN_Synchronized__c && crToSend.CN_Sync_Time__c != null 
        && crToSend.CN_Sync_Time__c > Datetime.now().addMinutes(-5));     
        return isLessFiveMins;
    }
}
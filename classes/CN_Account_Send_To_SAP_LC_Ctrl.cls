/**************************************************************************************************
 * Name           : CN_Account_Send_To_SAP_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wang Jessica
 * Create Date    : 2021-05-07
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Send_To_SAP_LC_Ctrl {
    @AuraEnabled
    public static Map<String, Object> getAccountInfoAndCheckEditPermisison(String recordId){
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Found);
        }
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        Account acc = new Account();
        hasCreatePermission = Untils.checkObjectCreatePermission('Account');
        system.debug('hasCreatePermission' + hasCreatePermission);
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_Account_No_Permission);
        }
        List<Account> accList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_Synchronized__c,
                                        CN_Sync_Error_Message__c 
                                    FROM Account 
                                    WHERE Id =: recordId];
        if(accList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Found);
        }
        acc = accList[0];        
        if(acc.CN_Synchronized__c) {
            errorMsg = System.Label.CN_Account_Had_Synced;
        }
        if(checkTimeInterval(acc)) {
            errorMsg = System.Label.CN_Account_Wait_5_Mins;   
        }
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }
    @auraEnabled
    public static Map<String, Object> sendAccount(String recordId) {
        System.debug('Send Start');
        System.debug(Datetime.now().getTime());
        Boolean isSendSuccess = false;
        String errorMessage = '';
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Found);
        }
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('Account');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_Account_No_Permission);
        }
        List<Account> accList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_Synchronized__c,
                                        CN_Sync_Error_Message__c 
                                    FROM Account 
                                    WHERE Id =: recordId];
        if(accList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Found);
        }

        Account accToSend = accList[0];
        if(accToSend.CN_Synchronized__c) {
            throw new AuraHandledException(System.Label.CN_Account_Had_Synced);
        }
        if(checkTimeInterval(accToSend)) {
            throw new AuraHandledException(System.Label.CN_Account_Wait_5_Mins);   
        }
        Map<String, Object> resultMap = callTalendAPI(accToSend);
        errorMessage = (String)resultMap.get('errorMsg');
        if((Boolean)resultMap.get('isSendSuccess')) {
            isSendSuccess = true;
            Account accToUpdate = new Account();
            accToUpdate.Id = accToSend.Id;
            accToUpdate.CN_Sync_Status__c = 'Sent';
            accToUpdate.CN_Sync_Time__c = Datetime.now();
            accToUpdate.CN_Sync_Error_Message__c = '';
            update accToUpdate;
        }
        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMessage
        };
    }
    public static Map<String, Object> callTalendAPI(Account accToSend) {
        Boolean isSendSuccess = false;
        String errorMsg = '';
        Talend_Setting__c setting = Talend_Setting__c.getInstance();
        try {
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            Blob headerValue;
            if (Untils.isSandbox()) {
                request.setEndpoint(setting.Sandbox_Send_To_Account_Endpoint__c);
                headerValue = Blob.valueOf(setting.Sandbox_User_Name__c + ':' + setting.Sandbox_Password__c);
            } else {
                request.setEndpoint(setting.Send_to_Account_Endpoint__c);
                headerValue = Blob.valueOf(setting.User_Name__c + ':' + setting.Password__c);
            }
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('POST');
            request.setBody('(\'' + accToSend.Id + '\')');
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

    public static Boolean checkTimeInterval(Account accToSend){
        Boolean isLessFiveMins = (!accToSend.CN_Synchronized__c && accToSend.CN_Sync_Time__c != null 
        && accToSend.CN_Sync_Time__c > Datetime.now().addMinutes(-5));     
        return isLessFiveMins;
    }
}
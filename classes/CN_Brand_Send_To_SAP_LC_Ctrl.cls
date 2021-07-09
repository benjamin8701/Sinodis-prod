/**************************************************************************************************
 * Name           : CN_Brand_Send_To_SAP_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-21
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Brand_Send_To_SAP_LC_Ctrl {
    public static String moduleName = System.Label.CN_Brand_Name;
    @AuraEnabled
    public static Map<String, Object> getBUInfoAndCheckEditPermisison(String recordId){
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName})); 
        }
        
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        CN_Brand__c brand = new CN_Brand__c();
        hasCreatePermission = Untils.checkObjectCreatePermission('CN_Brand__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_No_Permission, new List<String>{moduleName}));
        }
        
        List<CN_Brand__c> brandList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_City_API__c,
                                        CN_Group_Code__c
                                    FROM CN_Brand__c
                                    WHERE Id =: recordId];
        if(brandList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }
        
        brand = brandList[0];        
        if(Constants.CN_BU_SYNC_STATUS_SUCCESS.equals(brand.CN_Sync_Status__c) ) {
            errorMsg = String.format(System.Label.CN_Business_Unit_Had_Synced, new List<String>{moduleName}); 
        }
        if(checkTimeInterval(brand)) {
            errorMsg = System.Label.CN_CustomerHierarchy_Warning_Msg_Too_Frequency;   
        }
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }

    @auraEnabled
    public static Map<String, Object> sendBrand(String recordId) {
        
        System.debug('Send Start');
        System.debug(Datetime.now().getTime());
        Boolean isSendSuccess = false;
        String errorMessage = '';
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }
        
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('CN_Brand__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_No_Permission, new List<String>{moduleName}));
        }

        List<CN_Brand__c> brandList = [SELECT Id, 
                                        Name,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c,
                                        CN_City_API__c,
                                        CN_Group_Code__c,
                                        CN_Brand_Code__c
                                    FROM CN_Brand__c
                                    WHERE Id =: recordId];
        if(brandList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Not_Found, new List<String>{moduleName}));
        }

        CN_Brand__c brandToSend = brandList[0];
        if(Constants.CN_BU_SYNC_STATUS_SUCCESS.equals(brandToSend.CN_Sync_Status__c) ) {
            throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Had_Synced, new List<String>{moduleName}));   
        }
        if(checkTimeInterval(brandToSend)) {
            throw new AuraHandledException(System.Label.CN_CustomerHierarchy_Warning_Msg_Too_Frequency);   
        }
        
        Map<String, Object> resultMap = doCallout(brandToSend);
        CN_Brand__c brand_result = (CN_Brand__c)resultMap.get('brand');
        String brandCode = '';

        errorMessage = (String)resultMap.get('errorMessage');
        if((Boolean)resultMap.get('isSendSuccess')) {
            isSendSuccess = true;
            if(brand_result.CN_Brand_Code__c !=null && String.isNotBlank(brand_result.CN_Brand_Code__c)){
                brandCode = brand_result.CN_Brand_Code__c;
            } else {
                throw new AuraHandledException(String.format(System.Label.CN_Business_Unit_Code_Is_Blank, new List<String>{moduleName}));   
            }
            CN_Brand__c brandToUpdate = new CN_Brand__c(
                    Id = brandToSend.Id,
                    CN_Sync_Status__c = Constants.CN_BU_SYNC_STATUS_SUCCESS,    
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage,
                    CN_Brand_Code__c = brandCode
            );
            try{
                update brandToUpdate;
            } catch(Exception e) {
                errorMessage = e.getMessage();
                throw new AuraHandledException( e.getMessage());   
            }
        }else{
            if(String.isBlank(brandToSend.CN_Brand_Code__c) && brand_result.CN_Brand_Code__c !=null && String.isNotBlank(brand_result.CN_Brand_Code__c)){
                brandCode = brand_result.CN_Brand_Code__c;
            }
            CN_Brand__c brandToUpdate = new CN_Brand__c(
                    Id = brandToSend.Id,
                    CN_Sync_Status__c = Constants.CN_BU_SYNC_STATUS_FAIL,   
                    CN_Sync_Time__c = Datetime.now(),
                    CN_Sync_Error_Message__c = errorMessage,
                	CN_Brand_Code__c = String.isBlank(brandCode)? brandToSend.CN_Brand_Code__c: brandCode
            );
            try{
                update brandToUpdate;
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   
            }
        }
        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMessage
        };
    }

    public static Map<String, Object> doCallout(CN_Brand__c group_select) {
        
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
        gen.writeStringField('CN_Up_Code__c',group_select.CN_Brand_Code__c == null? '': group_select.CN_Brand_Code__c);
        gen.writeStringField('CN_Parent_Up_Code__c', group_select.CN_Group_Code__c);
        gen.writeStringField('CN_City_API__c',group_select.CN_City_API__c);
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

        CN_Brand__c brand = new CN_Brand__c();
        if(resCode == 200) {
            try{
                Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
                errorMsg = resultMap.containsKey('CN_Sync_Error_Message__c')? (String)resultMap.get('CN_Sync_Error_Message__c'): '';
                if(resultMap.containsKey('CN_Sync_Status__c')) {
                    String resultStatus = (String)resultMap.get('CN_Sync_Status__c');
                    if('S'.equals(resultStatus)) {
                        
                        isSendSuccess = true;
                        if(resultMap.containsKey('CN_Up_Code__c')) {
                            brand.CN_Brand_Code__c = (String)resultMap.get('CN_Up_Code__c');
                        } else {
                            brand.CN_Brand_Code__c = null;
                        }
                        brand.CN_Sync_Time__c = Datetime.now();
                    } else if('E'.equals(resultStatus) || String.isBlank(resultStatus)) {
                        if(resultMap.containsKey('CN_Up_Code__c')) {
                            if(resultMap.get('CN_Up_Code__c') != null) {
                            	brand.CN_Brand_Code__c = (String)resultMap.get('CN_Up_Code__c');
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
            'brand' => brand
        };
    }

    public static Boolean checkTimeInterval(CN_Brand__c brandToSend){
        Boolean isLessFiveMins = (brandToSend.CN_Sync_Status__c != null && brandToSend.CN_Sync_Time__c != null 
        && brandToSend.CN_Sync_Time__c > Datetime.now().addSeconds(-5));     
        return isLessFiveMins;
    }
}
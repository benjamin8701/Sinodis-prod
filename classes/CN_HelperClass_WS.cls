/*
 * ************************************************************************************************
 * Name : CN_HelperClass_WS
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author :
 * Create Date : 2023/4/6
 * Modify History :Leo Dicaprio
 * ************************************************************************************************
 */
global without sharing class CN_HelperClass_WS {


    private static void setSobjectValue(SObject obj, DescribeFieldResult filedDes, Object value) {
        try {
            switch on filedDes.getType()
            {
                when Date {
                    String strValue = String.valueOf(value);
                    Date dtValue = Date.newInstance(
                            Integer.valueOf(strValue.substring(0,4)),
                            Integer.valueOf(strValue.substring(5,7)),
                            Integer.valueOf(strValue.substring(8,10))
                        );
                    obj.put(filedDes.getName(), dtValue);
                }
                when Datetime {
                    String strValue = String.valueOf(value);
                    Datetime dtValue = Datetime.newInstance(
                            Integer.valueOf(strValue.substring(0,4)),
                            Integer.valueOf(strValue.substring(5,7)),
                            Integer.valueOf(strValue.substring(8,10)),
                            Integer.valueOf(strValue.substring(11,13)),
                            Integer.valueOf(strValue.substring(14,16)),
                            Integer.valueOf(strValue.substring(17,19))
                        );
                    obj.put(filedDes.getName(), dtValue);
                }
                when Picklist {
                    String strValue = String.valueOf(value);
                 
                    obj.put(filedDes.getName(), strValue);
                }
                when Reference {
                    String strValue = String.valueOf(value);
                    try {
                        Id newId = Id.valueOf(strValue);
                        obj.put(filedDes.getName(), newId);
                    } catch (Exception ex) {
                        
                        SObject sobjRed = filedDes.getReferenceTo()[0].newSObject();
                        for (Schema.SObjectField refField : filedDes.getReferenceTo()[0].getDescribe().fields.getMap().values()) {
                           
                            if (refField.getDescribe().isExternalID()) {
                                sobjRed.put(refField.getDescribe().getName(), strValue);
                               
                            }
                        }
                        
                        obj.putSObject(filedDes.getRelationshipName(), sobjRed);
                    }
                }
                when else {
                    obj.put(filedDes.getName(), value);
                }
            }
        } catch (Exception ex) {
            throw new JSONException('SetSobjectValue error, field [' + filedDes.getName() + '] type: [' + filedDes.getType() + '] ' + ex.getMessage());
        }
    }

    public static List<SObject> convertAPIMapToSObject(String strSobjectName, Map<String,String> mapFieldsMap, List<Map<String,Object>> ltAPIMap) {
        try {
            Schema.SObjectType type = Schema.getGlobalDescribe().get(strSobjectName);
            Map<String, Schema.SObjectField> fsMapFields = type.getDescribe().fields.getMap();
            List<SObject> listResultSObjs = new List<SObject>();

            for (Map<String,Object> item : ltAPIMap) {
                SObject dealData = type.newSObject();
                Boolean bEmpry = true;

                for (string fieldname : item.keySet()) {
                    if (mapFieldsMap.containsKey(fieldname)) {
                        String sobjFiledname = mapFieldsMap.get(fieldname);
                        if (fsMapFields.containsKey(sobjFiledname)) {
                            setSobjectValue(dealData, fsMapFields.get(sobjFiledname).getDescribe(), item.get(fieldname));
                            bEmpry = false;
                        }
                    }
                }

                if (bEmpry == false) {
                    listResultSObjs.add(dealData); 
                }
            }

            return listResultSObjs;
        } catch (Exception ex) {
            throw new JSONException('convertAPIMapToSObject ' + ex.getMessage());
        }
    }

    public static List<SObject> convertAPIMapToSObject(String strSobjectName, Map<String,String> mapFieldsMap,Map<String,Map<String,String>> convertFieldsMap, List<Map<String,Object>> ltAPIMap) {
        System.debug('new_convertAPIMapToSObject');
        try {
            Schema.SObjectType type = Schema.getGlobalDescribe().get(strSobjectName);
            Map<String, Schema.SObjectField> fsMapFields = type.getDescribe().fields.getMap();
            List<SObject> listResultSObjs = new List<SObject>();

           
            Map<String,Map<Object,Object>> convert = new Map<String,Map<Object,Object>>();
            for(String fieldName : convertFieldsMap.keySet()){
                Map<Object,Object> oneConvertList = new Map<Object, Object>();
                convert.put(fieldName,oneConvertList);
            }

           
            for (Map<String,Object> item : ltAPIMap) {
                
                for(String fieldName :convert.keySet()){
                    //modify by leo 2024.01.24 start
                    if (item.get(fieldname) == null || String.valueOf(item.get(fieldname)) == ''){
                        continue;
                    }
                    //modify by leo 2024.01.24 end
                    convert.get(fieldname).put(item.get(fieldname),null);
                }
            }

            
            for(String fieldName :convertFieldsMap.keySet()){
                boolean isEdit = false;
                
                String queryString = 'SELECT ' + convertFieldsMap.get(fieldName).get('targetField') + ' ,' + convertFieldsMap.get(fieldName).get('field') + ' FROM ' + convertFieldsMap.get(fieldName).get('object') + ' WHERE ' + convertFieldsMap.get(fieldName).get('field') + ' IN ( ' ;
                for (Object obj: convert.get(fieldName).keySet()){
                    if (obj != null && obj != ''){
                        isEdit = true;
                        queryString +=  '\'' + obj + '\',';
                    }
                }

                //modify by leo 2024.01.24 start
                List<SObject> res;
                //modify by leo 2024.01.24 end

                if(isEdit){
                    queryString = queryString.substring(0,queryString.length()-1) + ')';
                    
                    res= Database.query(queryString);
                    System.debug('convertAPIMapToSObject:' + Json.serialize(res));

                //modify by leo 2024.01.24 start
                }else{
                    
                    res = new List<SObject>();
                }
                //modify by leo 2024.01.24 end

               
                for(SObject s:res){
                    //modify by leo 2024.01.24 start
                   
                    if(s.get(convertFieldsMap.get(fieldName).get('field')) == null || s.get(convertFieldsMap.get(fieldName).get('targetField')) == null ){
                        convert.get(fieldName).put(s.get(convertFieldsMap.get(fieldName).get('field')),null);
                    }else{
                       
                        convert.get(fieldName).put(s.get(convertFieldsMap.get(fieldName).get('field')),s.get(convertFieldsMap.get(fieldName).get('targetField')));
                    }
                    //modify by leo 2024.01.24 end
                }

              
                for (Map<String,Object> item  :ltAPIMap){

                    Object old = item.get(fieldName);

                    if (old != null && old != '') {
                        if(convert.get(fieldName).get(old) != null){
                            item.put(fieldName,convert.get(fieldName).get(old));
                        }else{
                            item.remove(fieldName);
                        }
                    //modify by leo 2024.01.24 start
                    }else{
                        item.remove(fieldName);
                    }
                    //modify by leo 2024.01.24 end
                }
            }
            //The replacement job is complete

            for (Map<String,Object> item : ltAPIMap) {
                SObject dealData = type.newSObject();
                Boolean bEmpry = true;

                for (string fieldname : item.keySet()) {
                    if (mapFieldsMap.containsKey(fieldname)) {
                        String sobjFiledname = mapFieldsMap.get(fieldname);
                        if (fsMapFields.containsKey(sobjFiledname)) {
                            setSobjectValue(dealData, fsMapFields.get(sobjFiledname).getDescribe(), item.get(fieldname));
                            bEmpry = false;
                        }
                    }


                }

                if (bEmpry == false) {
                    listResultSObjs.add(dealData);
                }

            }

            return listResultSObjs;
        } catch (Exception ex) {
            System.debug(ex.getLineNumber() + ':' + ex.getMessage() );
            throw new JSONException('convertAPIMapToSObject ' + ex.getMessage());
        }
    }

    public static Map<String,Object> convertDatabaseResultToMap(ID id, Boolean isSuccess, Database.Error[] errors, Object uniqueId, Map<String,String> mapFields) {
        Map<String,Object> mapRet = new Map<String,Object>();
        try {
            List<Map<String,Object>> ltErrors = new List<Map<String,Object>>();
            for (Integer index = 0; index < errors.size(); index++) {
                Database.Error error = errors[index];
                List<String> newfields = new List<String>();
                for (String item : error.fields) {
                    newfields.add(mapFields.containsKey(item) ? mapFields.get(item) : item);
                }
                ltErrors.add(new Map<String,Object> { 
                    'fields' => newfields,
                    'message' => error.message
                });
            }
            mapRet.put('sfid', id);
            mapRet.put('errors', ltErrors);
            mapRet.put('success', isSuccess);
            mapRet.put('uniqueid', uniqueId);
            return mapRet;
        } catch (Exception ex) {
            throw new JSONException('convertAPIMapToSObject ' + ex.getMessage());
        }
    }

    public without sharing class WS_Log {
        private CN_API_Call_Logger__c log = new CN_API_Call_Logger__c();
        private String recordType = Schema.SObjectType.CN_API_Call_Logger__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_API_CALL_LOGGER).getRecordTypeId();

        public WS_Log() {
            String ClassName = new DmlException().getStackTraceString().substringAfter('\n');
            if (ClassName.startsWith('Class.')) ClassName = ClassName.substringAfter('Class.');
            ClassName = ClassName.substringBefore(':').substringBeforeLast('.');
            log.CN_Class_Name__c = ClassName;
            log.RecordTypeId = recordType;
        }

        public void SetRequest(String requestBody) {
            log.CN_Request_Body__c = requestBody.left(32700);
        }

        public void SetResponse(String responseBody) {
            log.CN_Response_Body__c = responseBody.left(32700);
        }

        public void SetResult(Integer code, String dbResult, String errorMsg) {
            log.CN_DataBase_Result__c = dbResult.left(32700);
            log.CN_Error_Message__c = errorMsg.left(32700);
            log.CN_Status_Code__c = code;
        }

        public void Save() {
           
            insert log;
        }

        public CN_API_Call_Logger__c getLog(){
            return log;
        }
    }

    public static HttpRequest createHttpRequestHelper(String sandboxPoint,String prodPoint){
        Talend_Setting__c setting = Talend_Setting__c.getInstance();
        HttpRequest request = new HttpRequest();
        Blob headerValue;
        if (Untils.isSandbox()) {
            System.debug('request--->'+request+'setting---->'+setting+'sandboxPoint--->'+sandboxPoint+'prodPoint--->'+prodPoint);
            request.setEndpoint(sandboxPoint);
            headerValue = Blob.valueOf(setting.Sandbox_User_Name__c + ':' + setting.Sandbox_Password__c);
        } else {
            request.setEndpoint(prodPoint);
            headerValue = Blob.valueOf(setting.User_Name__c + ':' + setting.Password__c);
        }
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8;');
        return request;
    }

    public static Message getRetData(String responseBody){
        System.debug(responseBody);
        Map<String, Object> message = null;
        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        List<Object> retDataList = (List<Object>)res.get('message');
        if(retDataList != null && retDataList.size()>0){
            message = (Map<String, Object>)retDataList.get(0);
        }else{
            return null;
        }
        Message ms = new Message();
        ms.msg = String.valueOf(message.get('msg'));
        ms.code = Integer.valueOf(String.valueOf(message.get('code')));
        if(ms.code == 1){
            ms.retData = (Map<String,Object>)message.get('retData');
        }else {
            ms.retData = null;
        }
        return ms;
    }

    public static Integer getRetDataCode(String responseBody){
        System.debug(responseBody);
        Map<String, Object> message = null;
        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        List<Object> retDataList = (List<Object>)res.get('message');
        if(retDataList != null && retDataList.size()>0){
            message = (Map<String, Object>)retDataList.get(0);
        }else{
            return null;
        }
        return Integer.valueOf(String.valueOf(message.get('code')));
    }

    public class Message{
        public Integer code;
        public String msg;
        public Map<String,Object> retData;
    }


}
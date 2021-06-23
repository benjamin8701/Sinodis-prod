@RestResource(urlMapping='/OrderTreeUpsert/*')
global class CN_OrderTreeUpsert_WS {
    @HttpPost
    global static void post() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        Boolean hasError = false;
        
        JSONGenerator gen = JSON.createGenerator(false);
                gen.writeStartObject();
        Savepoint sp = Database.setSavepoint();
        try{
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        Map<String, Object> masterAttribute = (Map<String, Object>)resultMap.get('attributes');
        String masterObjType = (String)masterAttribute.get('type');
        String masterObjExternalId = (String)masterAttribute.get('externalField');
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(masterObjType);
        
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
        
        List<Schema.ChildRelationship> crList = targetType.getDescribe().getChildRelationships();
        Map<String, Schema.sObjectField> relationLookupFieldNameMap = new Map<String, Schema.sObjectField>();
        Map<String, Schema.SObjectType> relationsObjectNameMap = new Map<String, Schema.SObjectType>();
        for(Schema.ChildRelationship cr : crList) {
            if(String.isNotBlank(cr.getRelationshipName())) {
                relationLookupFieldNameMap.put(cr.getRelationshipName(), cr.getField());
                relationsObjectNameMap.put(cr.getRelationshipName(), cr.getChildSObject());
            }
        } 
        
        sObject masterObj = targetType.newSObject();
        Schema.SObjectField externalIdField = fieldMap.get(masterObjExternalId);
        
        List<String> relationNameList = new List<String>();
        
        for(String key : resultMap.keyset()) {
            if('attributes'.equals(key)) {
                continue;
            } else if(!relationLookupFieldNameMap.containsKey(key)) {
                if(!key.contains('.')) {
                    String fieldType = String.valueof(fieldMap.get(key).getDescribe().getType());
                    if(fieldType == 'Date') {
                        masterObj.put(key, Date.valueOf((String)resultMap.get(key)));
                    } else if(fieldType == 'Boolean') {
                        masterObj.put(key, (Boolean)resultMap.get(key));
                    } else if(fieldType == 'Integer') {
                        masterObj.put(key, (Integer)resultMap.get(key));
                    } else if(fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'CURRENCY') {
                        masterObj.put(key, (Decimal)resultMap.get(key));
                    } else {
                        masterObj.put(key, resultMap.get(key));
                    }

                } else {
                    List<String> keyList = key.split('\\.');
                    Schema.sObjectType parentType = fieldMap.get(keyList[0]).getDescribe().getReferenceTo()[0];
                    sObject parentObj = parentType.newSObject();
                    parentObj.put(keyList[1], (String)resultMap.get(key));
                    masterObj.putsObject(fieldMap.get(keyList[0]).getDescribe().getRelationShipName(), parentObj);
                }
                
            } else if(relationLookupFieldNameMap.containsKey(key)) {
                relationNameList.add(key);
            }
        }
        Database.UpsertResult upsertResult = Database.upsert(masterObj, externalIdField, false);
        if(!upsertResult.isSuccess()) {
            hasError = true;
        }
        gen.writeFieldName(masterObjType);
        gen.writeObject(upsertResult);
        
        String masterRecordId = masterObj.Id;
        for(String relaName : relationNameList) {
            Map<String, Object> subMap = (Map<String, Object>)resultMap.get(relaName);
            List<Object> subMapList = (List<Object>)subMap.get('records');
            String parentFieldName = relationLookupFieldNameMap.get(relaName).getDescribe().getName();
            List<sObject> subObjList = new List<sObject>();
            String subObjExternalId = '';
            Schema.SObjectField subExternalIdField = null;
            Map<String, List<String>> subRelationNameMap = new Map<String, List<String>>();
            Map<String, Map<String, Object> > subExtIdRelateMap = new Map<String, Map<String, Object>>();
            Map<String, Schema.sObjectField> subRelationLookupFieldNameMap = new Map<String, Schema.sObjectField>();
            Map<String, Schema.SObjectType> subRelationsObjectNameMap = new Map<String, Schema.SObjectType>();
            for(Object sub : subMapList) {
                Map<String, Object> subObjMap = (Map<String, Object>)sub;
                Map<String, Object> subAttribute = (Map<String, Object>)subObjMap.get('attributes');
                String subObjType = (String)subAttribute.get('type');
                subObjExternalId = (String)subAttribute.get('externalField');
                subExtIdRelateMap.put((String)subObjMap.get(subObjExternalId), subObjMap);
                Schema.SObjectType subTargetType = Schema.getGlobalDescribe().get(subObjType);
                Map<String, Schema.SObjectField> subFieldMap = subTargetType.getDescribe().fields.getMap();
                
                List<Schema.ChildRelationship> subCrList = subTargetType.getDescribe().getChildRelationships();
                for(Schema.ChildRelationship cr : subCrList) {
                    if(String.isNotBlank(cr.getRelationshipName())) {
                        subRelationLookupFieldNameMap.put(cr.getRelationshipName(), cr.getField());
                        subRelationsObjectNameMap.put(cr.getRelationshipName(), cr.getChildSObject());
                    }
                }
                
                sObject subObj = subTargetType.newSObject();
                subExternalIdField = subFieldMap.get(subObjExternalId);
                for(String key : subObjMap.keyset()) {
                    if('attributes'.equals(key)) {
                        continue;
                    } else if(!subRelationLookupFieldNameMap.containsKey(key)) {
                        if(!key.contains('.')) {
                            String fieldType = String.valueof(subFieldMap.get(key).getDescribe().getType());
                            if(fieldType == 'Date') {
                                subObj.put(key, Date.valueOf((String)subObjMap.get(key)));
                            } else if(fieldType == 'Boolean') {
                                subObj.put(key, (Boolean)subObjMap.get(key));
                            } else if(fieldType == 'Integer') {
                                subObj.put(key, (Integer)subObjMap.get(key));
                            } else if(fieldType == 'DOUBLE'|| fieldType == 'PERCENT' || fieldType == 'CURRENCY') {
                                subObj.put(key, (Decimal)subObjMap.get(key));
                            } else {
                                subObj.put(key, (String)subObjMap.get(key));
                            }
                        } else {
                            List<String> keyList = key.split('\\.');
                            Schema.sObjectType parentType = subFieldMap.get(keyList[0]).getDescribe().getReferenceTo()[0];
                            sObject parentObj = parentType.newSObject();
                            parentObj.put(keyList[1], (String)subObjMap.get(key));
                            subObj.putsObject(subFieldMap.get(keyList[0]).getDescribe().getRelationShipName(), parentObj);
                        }
                        
                    } else if(subRelationLookupFieldNameMap.containsKey(key)) {
                        if(subRelationNameMap.containsKey((String)subObjMap.get(subObjExternalId))) {
                            subRelationNameMap.get((String)subObjMap.get(subObjExternalId)).add(key);
                        } else {
                            subRelationNameMap.put((String)subObjMap.get(subObjExternalId), new List<String>{key});
                        }
                        
                    }
                }
                if(String.isNotBlank(parentFieldName)) {
                    subObj.put(parentFieldName, masterRecordId);
                }
                subObjList.add(subObj);
            }
            List<Database.UpsertResult> subUpsertResultList = Database.upsert(subObjList, subExternalIdField, false);
            for(Database.UpsertResult result : subUpsertResultList) {
                if(!result.isSuccess()) {
                    hasError = true;
                }
            }
            gen.writeFieldName(relaName);
            gen.writeObject(subUpsertResultList);
            
            Map<String, String> subIdExtIdMap = new Map<String, String>();
            Map<String, List<sObject>> relateNameUpsertRecordListMap = new Map<String, List<sObject>>();
            Map<String, Schema.SObjectField> relateNameExtFieldMap = new Map<String, Schema.SObjectField>();
            for(sObject obj : subObjList) {
                String subExternalIdValue = (String)obj.get(subObjExternalId);
                subIdExtIdMap.put(obj.Id, subExternalIdValue);
                List<String> subRelaNameList = subRelationNameMap.get(subExternalIdValue);
                Map<String, Object> subObjMap = subExtIdRelateMap.get(subExternalIdValue);
                if(subRelaNameList != null) {
                    for(String subRelaName : subRelaNameList) {
                        Map<String, Object> subSubMap = (Map<String, Object>)subObjMap.get(subRelaName);
                        List<Object> subSubMapList = (List<Object>)subSubMap.get('records');
                        String subParentFieldName = subRelationLookupFieldNameMap.get(subRelaName).getDescribe().getName();
                        String subSubObjExternalId = '';
                        Schema.SObjectField subSubExternalIdField = null;
                        List<sObject> subSubObjUpsertList = new List<sObject>();
                        for(Object subSub : subSubMapList) {
                            Map<String, Object> subSubObjMap = (Map<String, Object>)subSub;
                            System.debug(subSubObjMap);
                            Map<String, Object> subSubAttribute = (Map<String, Object>)subSubObjMap.get('attributes');
                            String subSubObjType = (String)subSubAttribute.get('type');
                            subSubObjExternalId = (String)subSubAttribute.get('externalField');
                            Schema.SObjectType subSubTargetType = Schema.getGlobalDescribe().get(subSubObjType);
                            Map<String, Schema.SObjectField> subSubFieldMap = subSubTargetType.getDescribe().fields.getMap();
                            sObject subObj = subSubTargetType.newSObject();
                            subSubExternalIdField = subSubFieldMap.get(subSubObjExternalId);
                            for(String key : subSubObjMap.keyset()) {
                                if('attributes'.equals(key)) {
                                    continue;
                                } else {
                                    if(!key.contains('.')) {
                                        String fieldType = String.valueof(subSubFieldMap.get(key).getDescribe().getType());
                                        if(fieldType == 'Date') {
                                            subObj.put(key, Date.valueOf((String)subSubObjMap.get(key)));
                                        } else if(fieldType == 'Boolean') {
                                            subObj.put(key, (Boolean)subSubObjMap.get(key));
                                        } else if(fieldType == 'Integer') {
                                            subObj.put(key, (Integer)subSubObjMap.get(key));
                                        } else if(fieldType == 'DOUBLE'|| fieldType == 'PERCENT' || fieldType == 'CURRENCY') {
                                            subObj.put(key, (Decimal)subSubObjMap.get(key));
                                        } else {
                                            subObj.put(key, (String)subSubObjMap.get(key));
                                        }
                                    } else {
                                        List<String> keyList = key.split('\\.');
                                        Schema.sObjectType parentType = subSubFieldMap.get(keyList[0]).getDescribe().getReferenceTo()[0];
                                        sObject parentObj = parentType.newSObject();
                                        parentObj.put(keyList[1], (String)subSubObjMap.get(key));
                                        subObj.putsObject(subSubFieldMap.get(keyList[0]).getDescribe().getRelationShipName(), parentObj);
                                    }
                                }
                            }
                            if(String.isNotBlank(parentFieldName)) {
                                subObj.put(subParentFieldName, obj.Id);
                            }
                            subSubObjUpsertList.add(subObj);
                        }
                        system.debug(subSubObjUpsertList);
                        if(relateNameUpsertRecordListMap.containsKey(subRelaName)) {
                            relateNameUpsertRecordListMap.get(subRelaName).addAll(subSubObjUpsertList);
                        } else {
                            relateNameUpsertRecordListMap.put(subRelaName, subSubObjUpsertList);
                        }

                        relateNameExtFieldMap.put(subRelaName, subSubExternalIdField);
                    }
                }
            }
            for(String key : relateNameUpsertRecordListMap.keyset()) {
                List<Database.UpsertResult> subSubUpsertResultList = Database.upsert(relateNameUpsertRecordListMap.get(key), relateNameExtFieldMap.get(key), false);
                for(Database.UpsertResult result : subSubUpsertResultList) {
                    if(!result.isSuccess()) {
                        hasError = true;
                    }
                }
                gen.writeFieldName(key);
                gen.writeObject(subSubUpsertResultList);
            }
        }
             gen.writeBooleanField('hasErrors', hasError);
        } catch (Exception e) {
            Database.rollback(sp);
            gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeBooleanField('hasErrors', true);
            List<exceptionClass> ecList = new List<exceptionClass>();
            exceptionClass ec = new exceptionClass();
            ec.errorCode = e.getTypeName();
            ec.message = e.getMessage();
            ecList.add(ec);
            gen.writeFieldName('error');
            gen.writeObject(ecList);
        }
        gen.writeEndObject();
        gen.close();
        
        if(hasError) {
            res.statusCode = 400;
        } else {
            res.statusCode = 200;
        }
        res.responseBody = Blob.valueOf(gen.getAsString());
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');
    }
    public class exceptionClass {
        public String errorCode;
        public String message;
    }
}
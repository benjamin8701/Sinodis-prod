/**************************************************************************************************
 * Name           : CN_CR_Generate_ShipTo_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-24
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Generate_ShipTo_Handler implements Triggers.Handler{
    public static Boolean isTriggerRun = true;
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            if(CN_CR_Generate_ShipTo_Handler.isTriggerRun) {
                handleBeforeUpdate();
            }
        }
    }
    
    public void handleBeforeUpdate() {
        Id crNewShipToRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
        Map<Id,CN_Change_Request__c> idChangeRequestMap = new Map<Id,CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.New) {
            if(cr.RecordTypeId == crNewShipToRTId && Constants.CN_CR_STATUS_APPROVALED.equals(cr.CN_Change_Request_Status__c) && cr.CN_Change_Request_Status__c!=((CN_Change_Request__c)Trigger.oldMap.get(cr.Id)).CN_Change_Request_Status__c) {
                idChangeRequestMap.put(cr.Id,cr);
            }
        }
        if(idChangeRequestMap.size() > 0) {
            List<CN_Ship_to_Party__c> shipToList = new List<CN_Ship_to_Party__c>();
            Map<Id, CN_Ship_to_Party__c> stpMap = new Map<Id, CN_Ship_to_Party__c>();
            shipToList = generateshipTos(idChangeRequestMap);
            if(shipToList.size() > 0) {
                for(CN_Ship_to_Party__c stp: shipToList) {
                    stpMap.put(stp.Id, stp);
                }
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                dml.OptAllOrNone = false;
                Database.SaveResult[] srList = Database.insert(shipToList, dml);
                Set<Id> stpSuccessIdSet = new Set<Id>();
                for(Database.SaveResult sr: srList) {
                    if(!sr.isSuccess()) {
                        Trigger.newMap.get(stpMap.get(sr.getId()).CN_Change_Request__c).addError(sr.getErrors()[0]?.getMessage());
                    } else {
                        stpSuccessIdSet.add(sr.getId());
                    }
                }
                populateExternalId(shipToList,idChangeRequestMap, stpSuccessIdSet);
            }
            CN_CR_Generate_ShipTo_Handler.isTriggerRun = false;
        }
    }
    
    public void populateExternalId(List<CN_Ship_to_Party__c> shipToList,Map<Id,CN_Change_Request__c> idChangeRequestMap, Set<Id> successIdSet) {
        for (CN_Ship_to_Party__c shipTo : shipToList) {
            if(successIdSet.contains(shipTo.Id)) {
                idChangeRequestMap.get(shipTo.CN_Change_Request__c).CN_External_Id__c = shipTo.Id;
                idChangeRequestMap.get(shipTo.CN_Change_Request__c).CN_Ship_To_Party__c = shipTo.Id;
            }
        }
    }

    public List<CN_Ship_to_Party__c> generateshipTos(Map<Id,CN_Change_Request__c> idChangeRequestMap) {
        Id shipToRTId = Schema.SObjectType.CN_Ship_to_Party__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SHIPTO_RT_API_NAME).getRecordTypeId();
        List<CN_Ship_to_Party__c> shipToList = new List<CN_Ship_to_Party__c>();
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();  
        Map<String, String> fieldNameNewFieldNameMap = new Map<String, String>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            if('CN_Ship_to_Party__c'.equalsIgnoreCase(crmSettingMap.get(crmSettingId).CN_Object_Name__c) == False){
                continue;
            }
            CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
            String fieldName = crmSetting.CN_Field_Name__c;
            String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
            String fieldNameNew = 'New_' + fieldNameOld;
            fieldNameNewFieldNameMap.put(fieldNameNew,fieldName);
        }
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)idChangeRequestMap.values()){
            CN_Ship_To_Party__c shipTo = new CN_Ship_To_Party__c();
            shipTo.RecordTypeId = shipToRTId;
            for(String newFieldName : fieldNameNewFieldNameMap.keySet()){
                shipTo.put(fieldNameNewFieldNameMap.get(newFieldName),cr.get(newFieldName));
            }
            shipTo.CN_Change_Request__c = cr.Id;
            shipToList.add(shipTo);
        } 
        return shipToList;
    }
}
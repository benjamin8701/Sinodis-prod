/**************************************************************************************************
 * Name           : CN_CR_Write_Back_To_Shipto_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Write_Back_To_Shipto_Handler implements Triggers.Handler{
    public static Boolean isTriggerRun = true;
    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            if(CN_CR_Write_Back_To_Shipto_Handler.isTriggerRun) {
                handleAfterUpdate();
            }
        }
    }
    public void handleAfterUpdate() {
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_SHIPTO).getRecordTypeId();
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.New){
            if(cr.RecordTypeId == crRTId && Constants.CN_CR_STATUS_APPROVALED.equals(cr.CN_Change_Request_Status__c) 
            && cr.CN_Change_Request_Status__c!=((CN_Change_Request__c)Trigger.oldMap.get(cr.Id)).CN_Change_Request_Status__c){
                crList.add(cr);
            }
        }
        if(crList.size()>0){
            populateShipToFields(crList);
            CN_CR_Write_Back_To_Shipto_Handler.isTriggerRun = false;
        }
    }

    public void populateShipToFields(List<CN_Change_Request__c> crList){    
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();  
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldNameOldfieldNameMap = new Map<String, String>();
        List<CN_Ship_To_Party__c> shipToList  = new List<CN_Ship_To_Party__c>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            if('CN_Ship_to_Party__c'.equalsIgnoreCase(crmSettingMap.get(crmSettingId).CN_Object_Name__c) == False){
                continue;
            }
            CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
            String fieldName = crmSetting.CN_Field_Name__c;
            String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
            String fieldNameNew = 'New_' + fieldNameOld;
            fieldMap.put(fieldNameOld, fieldNameNew);       
            fieldNameOldfieldNameMap.put(fieldNameOld, fieldName);
        }
        for(CN_Change_Request__c cr : crList){
            Set<String> changedFieldSet = new Set<String>();
            for(String oldFieldName : fieldMap.keySet()) {
                if(cr.get(oldFieldName) != cr.get(fieldMap.get(oldFieldName))) {
                    changedFieldSet.add(oldFieldName);
                }
            }
            if(changedFieldSet.size()>0){
                CN_Ship_To_Party__c shipTo = new CN_Ship_To_Party__c();
                shipTo.Id = cr.CN_Ship_To_Party__c;
                for(String oldFieldName : changedFieldSet){
                    shipTo.put(fieldNameOldfieldNameMap.get(oldFieldName),cr.get(fieldMap.get(oldFieldName)));
                }
                shipTo.CN_Change_Request__c = cr.Id;
                shipToList.add(shipTo);
            }
        } 
        if(shipToList.size()>0){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList = Database.update(shipToList, dml);
        }  
        
    }

}
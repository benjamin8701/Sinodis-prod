/**************************************************************************************************
 * Name           : CN_CR_Write_Back_To_Contact_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica
 * Create Date    : 2021-05-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Write_Back_To_Contact_Handler implements Triggers.Handler{
    public static Boolean isTriggerRun = true;
    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            if(CN_CR_Write_Back_To_Contact_Handler.isTriggerRun) {
                handleAfterUpdate();
            }
        }
    }
    public void handleAfterUpdate() {
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT).getRecordTypeId();
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.New){
            if(cr.RecordTypeId == crRTId && Constants.CN_CR_STATUS_APPROVALED.equals(cr.CN_Change_Request_Status__c)){
                crList.add(cr);
            }
        }
        if(crList.size()>0){
            populateContactFields(crList);
            CN_CR_Write_Back_To_Contact_Handler.isTriggerRun =false;
        }
    }
    public void populateContactFields(List<CN_Change_Request__c> crList){    
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll(); 
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldNameOldfieldNameMap = new Map<String, String>();
        List<Contact> conList  = new List<Contact>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            if('Contact'.equalsIgnoreCase(crmSettingMap.get(crmSettingId).CN_Object_Name__c) == False){
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
                Contact con = new Contact();
                con.Id = cr.CN_Contact__c;
                con.CN_Change_Request__c = cr.Id;
                for(String oldFieldName : changedFieldSet){
                    con.put(fieldNameOldfieldNameMap.get(oldFieldName),cr.get(fieldMap.get(oldFieldName)));
                }
                conList.add(con);
            }
        } 
        if(conList.size()>0){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList = Database.update(conList, dml);
        }         
    }
}
/**************************************************************************************************
 * Name           : CN_CR_Write_Back_To_Account_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Write_Back_To_Account_Handler implements Triggers.Handler{
    public static Boolean isTriggerRun = true;
    public void handle() {
    system.debug('shuqi++1');
        if(Trigger.isAfter && Trigger.isUpdate) {
            if(CN_CR_Write_Back_To_Account_Handler.isTriggerRun) {
                handleAfterUpdate();
            }
        }
        //hotfix realse7 ----by shuqi start
        if(Trigger.isAfter && Trigger.isInsert) {
            if(CN_CR_Write_Back_To_Account_Handler.isTriggerRun) {
                handleAfterInsert();
            }
        }
        //hotfix realse7 ----by shuqi end
    }
    public void handleAfterUpdate() {
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT).getRecordTypeId();
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.New){
            CN_Change_Request__c oldCR = (CN_Change_Request__c)Trigger.oldMap.get(cr.Id);
            if(cr.RecordTypeId == crRTId && oldCR.CN_Change_Request_Status__c != cr.CN_Change_Request_Status__c && Constants.CN_CR_STATUS_APPROVALED.equals(cr.CN_Change_Request_Status__c)){
                crList.add(cr);
            }
        }
        if(crList.size()>0){
            populateAccountFields(crList);
            CN_CR_Write_Back_To_Account_Handler.isTriggerRun = false;
        }
    }
    //hotfix realse7 ----by shuqi start
    public void handleAfterInsert() {
        Id crOwnerRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_Mass_UPDATE_ACCOUNT_OWNER).getRecordTypeId();
        Id crFinanceRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_Mass_UPDATE_ACCOUNT_FINANCE_AR).getRecordTypeId();
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.New){            
            if(cr.RecordTypeId == crOwnerRTId ||cr.RecordTypeId == crFinanceRTId ){
                crList.add(cr);
            }
        }
        if(crList.size()>0){
            populateAccountFields(crList);
            CN_CR_Write_Back_To_Account_Handler.isTriggerRun = false;
        }
    }
    //hotfix realse7 ----by shuqi end
    public void populateAccountFields(List<CN_Change_Request__c> crList){
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll(); 
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldNameOldfieldNameMap = new Map<String, String>();
        List<Account> accList  = new List<Account>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            if('Account'.equalsIgnoreCase(crmSettingMap.get(crmSettingId).CN_Object_Name__c) == False){
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
                Account acc = new Account();
                acc.Id = cr.CN_Account_Name__c;
                acc.CN_Change_Request__c = cr.Id;
                for(String oldFieldName : changedFieldSet){
                    acc.put(fieldNameOldfieldNameMap.get(oldFieldName),cr.get(fieldMap.get(oldFieldName)));
                }
                accList.add(acc);
            }
        } 
        if(accList.size()>0){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList = Database.update(accList, dml);
        }
    }
}
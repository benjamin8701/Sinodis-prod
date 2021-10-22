/**************************************************************************************************
 * Name           : CN_CTA_Generate_CR_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-21
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CTA_Generate_CR_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isAfter && Trigger.IsUpdate) {
            handleAfterUpdate();
        }
    }
    
    public void handleAfterUpdate() {
        Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();
        List<CN_Credit_Term_Application__c> ctaList = new List<CN_Credit_Term_Application__c>();
        Map<Id,Id> ctaIdaccIdMap = new Map<Id,Id>();
        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New) {          
            if(Constants.CN_CTA_STATUS_APPROVALED.equals(cta.CN_Status__c) && cta.CN_Status__c <> ((CN_Credit_Term_Application__c)Trigger.oldMap.get(cta.Id)).CN_Status__c 
            && Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(cta.CN_Account_Sync_Status__c)){
                ctaList.add(cta);
                ctaIdaccIdMap.put(cta.Id, cta.CN_Account__c);
            }
        }
        if(ctaList.size() > 0){
            generateChangeRequest(ctaList,ctaIdaccIdMap);
        }
    }

    public void generateChangeRequest(List<CN_Credit_Term_Application__c> ctaList,Map<Id,Id> ctaIdaccIdMap){
        Set<String> accIdStringSet = new Set<String>();
        for(Id accId : ctaIdaccIdMap.values()){
            accIdStringSet.add('\'' + String.valueOf(accId) + '\'');
        }
        Set<String> fieldNameStringSet = new Set<String>();
        
        Map<String, String> fieldNamefieldNameOldMap = new Map<String, String>();
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Credit_Term_Application__c cta : ctaList){
            Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();  
            for(String crmSettingId : crmSettingMap.keyset()) {
                if('Account'.equalsIgnoreCase(crmSettingMap.get(crmSettingId).CN_Object_Name__c) == False){
                    continue;
                }
                CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
                String fieldName = crmSetting.CN_Field_Name__c;
                String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;    
                fieldNamefieldNameOldMap.put(fieldName, fieldNameOld);
                fieldNameStringSet.add(fieldName); 
            }
        }
    
        String selectFields = String.join(new List<String>(fieldNameStringSet), ',');
        String accIds = String.join(new List<String>(accIdStringSet), ',');
        String soql = 'SELECT ' + selectFields + ' FROM Account WHERE Id IN (' + accIds + ')';
        List<Account> accList = Database.query(soql);
        Map<Id,Account> accIdAccountMap = new Map<Id,Account>();
        for (Account acc : accList) {
            accIdAccountMap.put(acc.Id,acc);
        }

        for(CN_Credit_Term_Application__c cta : ctaList){
            CN_Change_Request__c cr = new CN_Change_Request__c();
            cr.recordTypeId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT).getRecordTypeId();
            for(String fieldName : fieldNameStringSet) {
                String fieldNameOld = fieldNamefieldNameOldMap.get(fieldName);
                String fieldNameNew = 'New_' + fieldNameOld;
                cr.put(fieldNameOld,accIdAccountMap.get( ctaIdaccIdMap.get(cta.Id)).get(fieldName) );
                cr.put(fieldNameNew,accIdAccountMap.get( ctaIdaccIdMap.get(cta.Id)).get(fieldName) );
            }
            cr.New_CN_Account_Reference_Day__c = cta.CN_Reference_Day__c;
            cr.New_CN_Account_Payment_Terms__c = cta.CN_Payment_Term_Negotiated__c;
            cr.CN_Is_Generate_From_Action__c = True;
            if(Constants.CN_CTA_NATURE_OF_REQUEST_REGULAR.equals(cta.CN_Nature_Of_Request__c) 
                || Constants.CN_CTA_NATURE_OF_REQUEST_TM1.equals(cta.CN_Nature_Of_Request__c) 
                || Constants.CN_CTA_NATURE_OF_REQUEST_TM2.equals(cta.CN_Nature_Of_Request__c) ){
                    cr.New_CN_Account_Require_Contract__c = TRUE;
            }
            crList.add(cr);
        }
        insert crList;

    }
}
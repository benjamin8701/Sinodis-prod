/**************************************************************************************************
 * Name           : CN_Lead_New_Contact_Request_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-07-18
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Lead_New_Contact_Request_LC_Ctrl {
    @AuraEnabled
    public static Map<String, Object> getLead(String recordId) {
		String selectFields = String.join(new List<String>(Schema.Lead.sObjectType.getDescribe().fields.getMap().keyset()), ',');
        String soql = 'SELECT ' + selectFields + ' FROM Lead WHERE Id = \'' + recordId + '\'';
        List<Lead> leadList = Database.query(soql);
        Lead sourceLead = leadList[0];
        /*if(!Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(sourceLead.CN_Account_Sync_Status__c)) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Synced);
        }*/
        if(!Constants.CN_LEAD_STATUS_SALES_QUALIFIED.equals(sourceLead.Status)) {
            throw new AuraHandledException(System.Label.CN_Lead_Not_Sales_Qualified);
        }

        List<CN_Change_Request__c> crList = [SELECT Id FROM CN_Change_Request__c WHERE CN_From_Lead__c =: sourceLead.Id];
        if(crList.size() > 0) {
            throw new AuraHandledException(System.Label.CN_Lead_Has_Change_Request);
        }

        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();
        Map<String, String> fieldMap = new Map<String, String>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
            if('Lead'.equals(crmSetting.CN_Object_Name__c)) {
                String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
                String fieldNameNew = 'New_' + fieldNameOld;
                fieldMap.put(fieldNameOld, crmSetting.CN_Field_Name__c);
                fieldMap.put(fieldNameNew, crmSetting.CN_Field_Name__c);
            }
        }
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
        
        return new Map<String, Object>{
      		'sourceLead' => sourceLead,
            'fieldMap' => fieldMap,
            'crRTId' => crRTId
        };
    }
}
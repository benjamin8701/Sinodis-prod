/**************************************************************************************************
 * Name           : CN_Shipto_Change_Request_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-05-07
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Shipto_Change_Request_LC_Ctrl {
    @AuraEnabled
    public static Map<String, Object> getShipTo(String recordId) {
		String selectFields = String.join(new List<String>(Schema.CN_Ship_To_Party__c.sObjectType.getDescribe().fields.getMap().keyset()), ',');
        String soql = 'SELECT ' + selectFields + ' FROM CN_Ship_To_Party__c WHERE Id = \'' + recordId + '\'';
        List<CN_Ship_To_Party__c> accList = Database.query(soql);
        CN_Ship_To_Party__c sourceShipTo = accList[0];
        if(!Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(sourceShipTo.CN_Account_Sync_Status__c)) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Synced);
        }
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();
        Map<String, String> fieldMap = new Map<String, String>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
            if('CN_Ship_to_Party__c'.equals(crmSetting.CN_Object_Name__c)) {
                String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
                String fieldNameNew = 'New_' + fieldNameOld;
                fieldMap.put(fieldNameOld, crmSetting.CN_Field_Name__c);
                fieldMap.put(fieldNameNew, crmSetting.CN_Field_Name__c);
            }
        }
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
        
        return new Map<String, Object>{
      		'sourceShipTo' => sourceShipTo,
            'fieldMap' => fieldMap,
            'crRTId' => crRTId
        };
    }
}
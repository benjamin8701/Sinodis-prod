/**************************************************************************************************
 * Name           : CN_Account_Change_Request_LCController
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-05-07
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Change_Request_LCController {
    @AuraEnabled
    public static Map<String, Object> getAccount(String recordId) {
		String selectFields = String.join(new List<String>(Schema.Account.sObjectType.getDescribe().fields.getMap().keyset()), ',');
        String soql = 'SELECT ' + selectFields + ' FROM Account WHERE Id = \'' + recordId + '\'';
        List<Account> accList = Database.query(soql);
        Account sourceAccount = accList[0];
        if(!(Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(sourceAccount.CN_Sync_Status__c) && Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED.equals(sourceAccount.CN_Account_Status__c))) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Synced);
        }
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();
        Map<String, String> fieldMap = new Map<String, String>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
            if('Account'.equals(crmSetting.CN_Object_Name__c)) {
                String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
                String fieldNameNew = 'New_' + fieldNameOld;
                fieldMap.put(fieldNameOld, crmSetting.CN_Field_Name__c);
                fieldMap.put(fieldNameNew, crmSetting.CN_Field_Name__c);
            }
        }
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
        
        return new Map<String, Object>{
      		'sourceAccount' => sourceAccount,
            'fieldMap' => fieldMap,
            'crRTId' => crRTId
        };
    }
}
/*
 * ************************************************************************************************
 * Name : CN_Offline_Contact_Change_Request_LC_Ctrl
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2023/8/23
 * Modify History :
 * ************************************************************************************************
 */

public without sharing class CN_Offline_Contact_Request_LC_Ctrl {
	@AuraEnabled
	public static Map<String, Object> getContact(String recordId,String leadId) {
		System.debug(leadId);
		String selectFields =
				String.join(new List<String>(Schema.Contact.sObjectType.getDescribe().fields.getMap().keyset()), ',');
		String soql = 'SELECT ' + selectFields + ' FROM Contact WHERE Id = \'' + recordId + '\'';
		List<Contact> accList = Database.query(soql);
		Contact sourceContact = accList[0];
		if (!Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(sourceContact.CN_Account_Sync_Status__c)) {
			throw new AuraHandledException(System.Label.CN_Account_Not_Synced);
		}
		Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap =
				CN_Change_Request_Fields_Mapping__mdt.getAll();
		Map<String, String> fieldMap = new Map<String, String>();
		for (String crmSettingId : crmSettingMap.keyset()) {
			CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
			if ('Contact'.equals(crmSetting.CN_Object_Name__c)) {
				String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
				String fieldNameNew = 'New_' + fieldNameOld;
				fieldMap.put(fieldNameOld, crmSetting.CN_Field_Name__c);
				fieldMap.put(fieldNameNew, crmSetting.CN_Field_Name__c);
			}
		}

		//填写lead带过来的数据
		String selectFieldsLead =
				String.join(new List<String>(Schema.Lead.sObjectType.getDescribe().fields.getMap().keyset()), ',');
		String soqlLead = 'SELECT ' + selectFieldsLead + ' FROM Lead WHERE Id = \'' + leadId + '\'';
		List<Lead> accListLead = Database.query(soqlLead);
		Lead lead = accListLead[0];
		if(!Constants.CN_LEAD_STATUS_SALES_QUALIFIED.equals(lead.Status)) {
			throw new AuraHandledException(System.Label.CN_Lead_Not_Sales_Qualified);
		}

		Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(
				Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();

		return new Map<String, Object>{
		'sourceContact' => sourceContact,
		'sourceLead' => lead,
		'fieldMap' => fieldMap,
		'crRTId' => crRTId
		};
	}
}
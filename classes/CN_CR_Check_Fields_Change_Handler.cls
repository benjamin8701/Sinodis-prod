/**************************************************************************************************
 * Name           : CN_CR_Check_Fields_Change_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-05-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Check_Fields_Change_Handler implements Triggers.Handler {
    Set<Id> cnRTIdSet = new Set<Id>();
    Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
    Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
    Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
    Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();

    //add by leo 2023.10.19
    Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();

    Map<Id, Set<String>> crIdChangedFieldNameMap = new Map<Id, Set<String>>();
    public void handle() {
        this.cnRTIdSet.add(this.updateAccountRTId);
        this.cnRTIdSet.add(this.updateContactRTId);
        this.cnRTIdSet.add(this.updateShiptoRTId);
        this.cnRTIdSet.add(this.newContactRTId);
        this.cnRTIdSet.add(this.newShiptoRTId);
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    public void handleBeforeUpdate() {
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
            CN_Change_Request__c oldCr = (CN_Change_Request__c)Trigger.oldMap.get(cr.Id);
            if(cnRTIdSet.contains(cr.RecordTypeId) && oldCr.CN_Change_Request_Status__c != cr.CN_Change_Request_Status__c && Constants.CN_CR_STATUS_READY_FOR_APPROVAL.equals(cr.CN_Change_Request_Status__c)) {
                crList.add(cr);
            }
        }
        if(crList.size() > 0) {
            checkFieldsChanged(crList);
            checkContactRelation(crList);
            //add by leo 2023.08.24 check field
            checkShipToField(crList);
            //add by leo 2023.08.24 check field
            checkShipToRelation(crList);
        }
    }

    /*
     * add by leo 2023.08.24 check field
	 */
    private void checkShipToField(List<CN_Change_Request__c> crList) {
        List<CN_Change_Request__c> crCheckList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : crList) {
            if(cr.hasErrors()) {
                continue;
            }
            crCheckList.add(cr);
        }
        if(crCheckList.size() > 0) {
            Map<String, CN_Change_Request_Fields_Check__mdt> crmSettingMap = CN_Change_Request_Fields_Check__mdt.getAll();
            List<String> requiredFieldNames = new List<String>();
            for(String crmSettingId : crmSettingMap.keyset()) {
                CN_Change_Request_Fields_Check__mdt mdt = crmSettingMap.get(crmSettingId);
                if (mdt.CN_Object_Name__c == 'CN_Ship_to_Party__c'
                        && (
                                        mdt.CN_Change_Request_Record_Type__c == Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO ||
                                        mdt.CN_Change_Request_Record_Type__c == Constants.CN_CR_RT_API_NAME_NEW_SHIPTO
                        )
                        && mdt.CN_Is_Required__c == true
                ){
                    requiredFieldNames.add(mdt.CN_Field_Name__c);
                }
            }

            for(CN_Change_Request__c cr : crCheckList) {
                if(updateShiptoRTId == cr.RecordTypeId || newShiptoRTId == cr.RecordTypeId) {
                    for (String next : requiredFieldNames) {
                        System.debug(next);
                        System.debug(cr.get(next));
                        if (cr.get(next) == null){
                            System.debug(next);
                            cr.addError('Field [' + next + '] can not be null');
                        }
                    }
                }
            }
        }
    }

    public void checkContactRelation(List<CN_Change_Request__c> crList) {
        List<CN_Change_Request__c> crCheckList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : crList) {
            if(cr.hasErrors()) {
                continue;
            }
            crCheckList.add(cr);
        }
        Map<Id, List<Id>> accIdBillingConIdListMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> accIdPurchasingConIdListMap = new Map<Id, List<Id>>();
        if(crCheckList.size() > 0) {
            List<CN_Change_Request__c> crCheckRelationList = new List<CN_Change_Request__c>();
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> conIdSet = new Set<Id>();
            for(CN_Change_Request__c cr : crCheckList) {
                Set<String> changedFieldSet = crIdChangedFieldNameMap.get(cr.Id);
                if(changedFieldSet != null && updateContactRTId == cr.RecordTypeId) {
                    if(changedFieldSet.contains('CN_Contact_Type__c') || changedFieldSet.contains('CN_Contact_License_Name__c')) {
                        crCheckRelationList.add(cr);
                        if(cr.New_CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                            if(accIdBillingConIdListMap.containsKey(cr.New_CN_Contact_License_Name__c)) {
                                accIdBillingConIdListMap.get(cr.New_CN_Contact_License_Name__c).add(cr.CN_Contact__c);
                            } else {
                                accIdBillingConIdListMap.put(cr.New_CN_Contact_License_Name__c, new List<Id>{cr.CN_Contact__c});
                            }
                        }
                        if(cr.New_CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)) {
                            if(accIdPurchasingConIdListMap.containsKey(cr.New_CN_Contact_License_Name__c)) {
                                accIdPurchasingConIdListMap.get(cr.New_CN_Contact_License_Name__c).add(cr.CN_Contact__c);
                            } else {
                                accIdPurchasingConIdListMap.put(cr.New_CN_Contact_License_Name__c, new List<Id>{cr.CN_Contact__c});
                            }
                        }
                        accIdSet.add(cr.CN_Contact_License_Name__c);
                        accIdSet.add(cr.New_CN_Contact_License_Name__c);
                        conIdSet.add(cr.CN_Contact__c);
                    }
                }
            }
            if(accIdSet.size() > 0) {
                List<Account> accList = [SELECT Id, Name, (SELECT Id, Name, CN_Contact_Type__c FROM Contacts WHERE CN_Contact_Type__c INCLUDES ('01','02') AND Id NOT IN: conIdSet) FROM Account WHERE Id in: accIdSet];
                for(Account acc : accList) {
                    if(acc.contacts.size() > 0) {
                        for(Contact con : acc.Contacts) {
                            if(con.CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_FINANCE_VALUE_NAME)) {
                                if(accIdBillingConIdListMap.containsKey(acc.Id)) {
                                    accIdBillingConIdListMap.get(acc.Id).add(con.Id);
                                } else {
                                    accIdBillingConIdListMap.put(acc.Id, new List<Id>{con.Id});
                                }
                            }
                            if(con.CN_Contact_Type__c?.contains(Constants.CN_CONTACT_TYPE_PURCHASE_VALUE_NAME)) {
                                if(accIdPurchasingConIdListMap.containsKey(acc.Id)) {
                                    accIdPurchasingConIdListMap.get(acc.Id).add(con.Id);
                                } else {
                                    accIdPurchasingConIdListMap.put(acc.Id, new List<Id>{con.Id});
                                }
                            }
                        }
                    }
                }
                Set<Id> accIdErrSet = new Set<Id>();
                for(Account acc : accList) {
                    if(!(accIdBillingConIdListMap.containsKey(acc.Id) && accIdPurchasingConIdListMap.containsKey(acc.Id))) {
                        accIdErrSet.add(acc.Id);
                    }
                }
                if(crCheckRelationList.size() > 0) {
                    for(CN_Change_Request__c cr : crCheckRelationList) {
                        if(accIdErrSet.contains(cr.CN_Contact_License_Name__c) || accIdErrSet.contains(cr.New_CN_Contact_License_Name__c)) {
                            cr.addError(system.Label.CN_Account_Has_Billing_and_Purchase_Contact);
                        }
                    }
                }
            }

        }
    }
    public void checkFieldsChanged(List<CN_Change_Request__c> crList) {
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll();
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, Boolean> fieldInterfaceMap = new Map<String, Boolean>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
            String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
            String fieldNameNew = 'New_' + fieldNameOld;
            fieldMap.put(fieldNameOld, fieldNameNew);
            fieldInterfaceMap.put(fieldNameOld, crmSetting.CN_Is_Interface_Field__c);
        }

        for(CN_Change_Request__c cr : crList) {
            Set<String> changedFieldSet = new Set<String>();
            Boolean isInterfaceField = false;
            for(String oldFieldName : fieldMap.keySet()) {
                if(cr.get(oldFieldName) != cr.get(fieldMap.get(oldFieldName))) {
                    changedFieldSet.add(oldFieldName);
                    if(fieldInterfaceMap.get(oldFieldName)) {
                        isInterfaceField = true;
                    }
                }
            }

            if(newContactRTId == cr.recordTypeId){
                if(cr.New_CN_Contact_Type__c.contains('01')){
                    isInterfaceField = true;
                }else{
                    isInterfaceField = false;
                }
            }else if(updateContactRTId == cr.recordTypeId){
                if (cr.New_CN_Contact_Type__c.contains('01')){
                    if (!cr.CN_Contact_Type__c?.contains('01')){
                        isInterfaceField = true;
                    }
                } else {
                    isInterfaceField = false;
                }
            }

            if(changedFieldSet.size() == 0) {
                cr.addError(System.Label.CN_CR_AT_LEAST_ONE_FIELD_CHANGE);
            } else {
                crIdChangedFieldNameMap.put(cr.Id, changedFieldSet);
                if(isInterfaceField) {
                    cr.CN_Sync_Status__c = '';
                } else {
                    cr.CN_Sync_Status__c = Constants.CN_CR_SYNC_STATUS_NO_NEED_TO_SYNC;
                }

            }
        }
    }
    public void checkShipToRelation(List<CN_Change_Request__c> crList) {
        List<CN_Change_Request__c> crCheckList = new List<CN_Change_Request__c>();
        Set<Id> STPIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, List<Id>> accIdSTPIdMap = new Map<Id, List<Id>>();
        for(CN_Change_Request__c cr : crList) {
            if(cr.hasErrors()) {
                continue;
            }
            Set<String> changedFieldSet = crIdChangedFieldNameMap.get(cr.Id);
            if(changedFieldSet != null && changedFieldSet.contains('CN_ShipTo_Sold_To_Party_Customer__c') && updateShiptoRTId == cr.RecordTypeId) {
                crCheckList.add(cr);
                accIdSet.add(cr.CN_ShipTo_Sold_To_Party_Customer__c);
                STPIdSet.add(cr.CN_Ship_To_Party__c);
            }
        }
        if(STPIdSet.size() > 0) {
            Set<Id> accErrorIdSet = new Set<Id>();
            List<Account> accList = [SELECT Id, Name, (SELECT Id, Name FROM Ship_to_Parties__r WHERE Id NOT IN: STPIdSet) FROM Account WHERE Id IN: accIdSet];
            for(Account acc : accList) {
                if(acc.Ship_to_Parties__r.isEmpty()) {
                    accErrorIdSet.add(acc.Id);
                }
            }
            if(accErrorIdSet.size() > 0) {
                for(CN_Change_Request__c cr : crCheckList) {
                    if(accErrorIdSet.contains(cr.CN_ShipTo_Sold_To_Party_Customer__c)) {
                        cr.addError(system.label.CN_Account_Has_ShipToParty);
                    }
                }
            }
        }
    }
}
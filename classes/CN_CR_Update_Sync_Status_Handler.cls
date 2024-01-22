/**************************************************************************************************
 * Name           : CN_CR_Update_Sync_Status_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica
 * Create Date    : 2021-05-23
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Update_Sync_Status_Handler implements Triggers.Handler {
    public static Boolean isTriggerRun = true;
    Set<Id> accRTIdSet = new Set<Id>();
    Set<Id> conRTIdSet = new Set<Id>();
    Set<Id> shipToRTIdSet = new Set<Id>();
    Id appdUpdateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT).getRecordTypeId();
    Id appdNewContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_NEW_CONTACT).getRecordTypeId();
    Id appdUpdateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT).getRecordTypeId();
    Id appdNewShipToRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_APPD_SHIPTO).getRecordTypeId();
    Id appdUpdateShipToRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_SHIPTO).getRecordTypeId();
    
    public void handle() {
        this.accRTIdSet.add(this.appdUpdateAccountRTId);
        this.conRTIdSet.add(this.appdNewContactRTId);
        this.conRTIdSet.add(this.appdUpdateContactRTId);
        this.shipToRTIdSet.add(this.appdNewShipToRTId);
        this.shipToRTIdSet.add(this.appdUpdateShipToRTId);

        if (Trigger.isAfter && Trigger.isUpdate) {
            if(CN_CR_Update_Sync_Status_Handler.isTriggerRun) {
                handleAfterUpdate();
            }
        }
    }
    public void handleAfterUpdate() {
        Map<Id, CN_Change_Request__c> oldCRMap = (Map<Id, CN_Change_Request__c>)Trigger.oldMap;
        Map<Id,CN_Change_Request__c> accSyncStatusMap = new Map<Id,CN_Change_Request__c>();
        Map<Id,CN_Change_Request__c> conSyncStatusMap = new Map<Id,CN_Change_Request__c>();
        Map<Id,CN_Change_Request__c> shipToSyncStatusMap = new Map<Id,CN_Change_Request__c>();

        Datetime latestAccountSyncTime = null;
        Datetime latestContactSyncTime = null;
        Datetime latestSTPSyncTime = null;
        for (CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
            if (
                accRTIdSet.contains(cr.RecordTypeId) ||
                 conRTIdSet.contains(cr.RecordTypeId) || 
                 shipToRTIdSet.contains(cr.RecordTypeId) &&
                 Constants.CN_CR_STATUS_APPROVED.equals(cr.CN_Change_Request_Status__c) &&
                 ( 
                     Constants.CN_CR_SYNC_STATUS_SUCCESS.equals(cr.CN_Sync_Status__c) ||
                     Constants.CN_CR_SYNC_STATUS_SENT.equals(cr.CN_Sync_Status__c) ||
                     Constants.CN_CR_SYNC_STATUS_NO_NEED_TO_SYNC.equals(cr.CN_Sync_Status__c)
                 )) {
                CN_Change_Request__c oldCRObj = null;
                if (oldCRMap.containsKey(cr.Id)) {
                    oldCRObj = (CN_Change_Request__c)oldCRMap.get(cr.Id);
                } 
                if (cr.CN_Sync_Status__c <> oldCRObj.CN_Sync_Status__c) {
                    if (cr.CN_Account_Name__c <> null) {
                        if(latestAccountSyncTime == null || latestAccountSyncTime < cr.CN_Sync_Time__c) {
                            latestAccountSyncTime = cr.CN_Sync_Time__c;
                            accSyncStatusMap.put(cr.CN_Account_Name__c, cr);
                        }
                    }
                    if (cr.CN_Contact__c <> null) {
                        if(latestContactSyncTime == null || latestContactSyncTime < cr.CN_Sync_Time__c) {
                            latestContactSyncTime = cr.CN_Sync_Time__c;
                            conSyncStatusMap.put(cr.CN_Contact__c, cr);
                        }
                    }
                    if (cr.CN_Ship_To_Party__c <> null) {
                        if(latestSTPSyncTime == null || latestSTPSyncTime < cr.CN_Sync_Time__c) {
                            latestSTPSyncTime = cr.CN_Sync_Time__c;
                            shipToSyncStatusMap.put(cr.CN_Ship_To_Party__c, cr);

                        }
                    }
                } 
            }
        }
        if (!accSyncStatusMap.isEmpty()) {
            syncAccountSyncStatus(accSyncStatusMap);
            CN_CR_Update_Sync_Status_Handler.isTriggerRun = false;
        }
        if (!conSyncStatusMap.isEmpty()) {
            syncContactSyncStatus(conSyncStatusMap);
            CN_CR_Update_Sync_Status_Handler.isTriggerRun = false;
        }
        if (!shipToSyncStatusMap.isEmpty()) {
            syncShipToSyncStatus(shipToSyncStatusMap);
            CN_CR_Update_Sync_Status_Handler.isTriggerRun = false;
        }
    }
    public void syncAccountSyncStatus(Map<Id, CN_Change_Request__c> accSyncStatusMap) {
        List<Account> accUpdateList = new List<Account>();
        for(Id accId : accSyncStatusMap.keySet()) {
            CN_Change_Request__c cr = accSyncStatusMap.get(accId);
            Account acc = new Account(
                Id = accId,
                CN_Latest_CR_Sync_Status__c = cr.CN_Sync_Status__c,
                CN_Latest_CR_Sync_Time__c = cr.CN_Sync_Time__c,
                CN_Latest_CR_Sync_Error_Message__c = cr.CN_Sync_Error_Message__c,
                CN_Change_Request__c = cr.Id
            );
            accUpdateList.add(acc);
        }
        if(accUpdateList.size() > 0) {
            Constants.CN_ACCOUNT_TRIGGER_ON = false;
            update accUpdateList;
            Constants.CN_ACCOUNT_TRIGGER_ON = true;
        }
    }
    public void syncContactSyncStatus(Map<Id, CN_Change_Request__c> conSyncStatusMap) {
        List<Contact> conUpdateList = new List<Contact>();

        for(Id conId : conSyncStatusMap.keySet()) {
            CN_Change_Request__c cr = conSyncStatusMap.get(conId);
            Contact con = new Contact();
            con.Id = conId;
            con.CN_Latest_CR_Sync_Status__c = cr.CN_Sync_Status__c;
            con.CN_Latest_CR_Sync_Time__c = cr.CN_Sync_Time__c;
            con.CN_Latest_CR_Sync_Error_Message__c = cr.CN_Sync_Error_Message__c;
            con.CN_Change_Request__c = cr.Id;
            if(cr.recordTypeId == appdNewContactRTId && Constants.CN_CR_SYNC_STATUS_SUCCESS.equals(cr.CN_Sync_Status__c)){
                con.CN_Up_Code__c = cr.CN_SAP_ID__c;
            }

            //add by leo 2023.12.10 CN_Has_CR_Need_Sync must be False when sync Contact to E-Commerce
            if(Constants.CN_CR_SYNC_STATUS_SUCCESS.equals(cr.CN_Sync_Status__c) || Constants.CN_CR_SYNC_STATUS_NO_NEED_TO_SYNC.equals(cr.CN_Sync_Status__c)){
                con.CN_Has_CR_Need_Sync__c = false;
            }
            //add by leo 2023.12.10 CN_Has_CR_Need_Sync must be False when sync Contact to E-Commerce

            conUpdateList.add(con);
        }
        if(conUpdateList.size() > 0) {
            Constants.CN_CONTACT_TRIGGER_ON = false;
            update conUpdateList;
            Constants.CN_CONTACT_TRIGGER_ON = true;
        }
    }
    public void syncShipToSyncStatus(Map<Id, CN_Change_Request__c> shipToSyncStatusMap) {
        List<CN_Ship_to_Party__c> shipToUpdateList = new List<CN_Ship_to_Party__c>();

        for(Id stpId : shipToSyncStatusMap.keyset()) {
            CN_Change_Request__c cr = shipToSyncStatusMap.get(stpId);
            CN_Ship_to_Party__c stp = new CN_Ship_to_Party__c();
            stp.Id = stpId;
            stp.CN_Latest_CR_Sync_Status__c = cr.CN_Sync_Status__c;
            stp.CN_Latest_CR_Sync_Time__c = cr.CN_Sync_Time__c;
            stp.CN_Latest_CR_Sync_Error_Message__c = cr.CN_Sync_Error_Message__c;
            stp.CN_Change_Request__c = cr.Id;
            if(cr.recordTypeId == appdNewShipToRTId && Constants.CN_CR_SYNC_STATUS_SUCCESS.equals(cr.CN_Sync_Status__c)){
                stp.CN_Up_Code__c = cr.CN_SAP_ID__c;
            }

            shipToUpdateList.add(stp);
        }
        if(shipToUpdateList.size() > 0) {
            Constants.CN_SHIPTO_TRIGGER_ON = false;
            update shipToUpdateList;
            Constants.CN_SHIPTO_TRIGGER_ON = true;
        }
    }
}
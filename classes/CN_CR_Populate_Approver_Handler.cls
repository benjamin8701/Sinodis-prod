/**************************************************************************************************
 * Name           : CN_CR_Populate_Approver_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Populate_Approver_Handler implements Triggers.Handler {
    Set<Id> cnRTIdSet = new Set<Id>();
    Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
    Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
    Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
    Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
    Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();
    public void handle() {
        this.cnRTIdSet.add(this.updateAccountRTId);
        this.cnRTIdSet.add(this.updateContactRTId);
        this.cnRTIdSet.add(this.updateShiptoRTId);
        this.cnRTIdSet.add(this.newContactRTId);
        this.cnRTIdSet.add(this.newShiptoRTId);
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }        
    }
    public void handleBeforeInsert() {
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
            if(cnRTIdSet.contains(cr.RecordTypeId)) {
                crList.add(cr);
            }
        }
        if(crList.size() > 0) {
            populateApprover(crList);
        }
    }
    public void handleBeforeUpdate() {
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
            CN_Change_Request__c oldCr = (CN_Change_Request__c)Trigger.oldMap.get(cr.Id);
            if(oldCr.OwnerId != cr.OwnerId || (oldCr.CN_Change_Request_Status__c != cr.CN_Change_Request_Status__c && Constants.CN_CR_STATUS_READY_FOR_APPROVAL.equals(cr.CN_Change_Request_Status__c))) {
                if(cnRTIdSet.contains(cr.RecordTypeId)) {
                    crList.add(cr);
                }
            }
        }
        if(crList.size() > 0) {
            populateApprover(crList);
        }
    }
    public void populateApprover(List<CN_Change_Request__c> crList) {
        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();

        Set<String> ownerIdSet = new Set<String>();
        for(CN_Change_Request__c cr : crList) {
            ownerIdSet.add(cr.OwnerId);
        }
        List<User> ownerList = [SELECT Id,
                                        Title,
                                        ManagerId,
                                        Manager.Title,
                                        Manager.ManagerId,
                                        Manager.Manager.Title,
                                        Manager.Manager.ManagerId,
                                        Manager.Manager.Manager.Title,
                                        Manager.Manager.Manager.ManagerId,
                                        Manager.Manager.Manager.Manager.Title,
                                        Manager.Manager.Manager.Manager.ManagerId,
                                        Manager.Manager.Manager.Manager.Manager.Title
                               FROM User
                               WHERE Id in: ownerIdSet];
        Map<Id, User> ownerMap = new Map<Id, User>(ownerList);

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

            cr.CN_Approver_1__c = null;
            cr.CN_Approver_2__c = null;
            cr.CN_Approver_3__c = null;
            cr.CN_Approver_4__c = null;
            cr.CN_Is_Auto_Approved__c = false;
            cr.CN_Approval_Send_Notification__c = false;

            User owner = ownerMap.get(cr.OwnerId);
            Map<String, String> titleUserIdMap = new Map<String, String>();
            if(String.isNotBlank(owner.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Title, owner.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Title, owner.Manager.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Manager.Title, owner.Manager.Manager.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.Manager.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Manager.Manager.Title, owner.Manager.Manager.Manager.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.Manager.Manager.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Manager.Manager.Manager.Title, owner.Manager.Manager.Manager.Manager.ManagerId);
            }

            String ManagerUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_MANAGER);
            String ARMUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_ARM);
            String RMUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_RM);
            String CMUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_CM);
            String CDUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_CD);

            Map<String, Integer> levelMap = new Map<String, Integer>();
            levelMap.put(Constants.CN_USER_TITLE_MANAGER, 0);
            levelMap.put(Constants.CN_USER_TITLE_ARM, 1);
            levelMap.put(Constants.CN_USER_TITLE_RM, 2);
            levelMap.put(Constants.CN_USER_TITLE_CM, 3);
            levelMap.put(Constants.CN_USER_TITLE_CD, 4);

            List<String> levelList = new List<String>();
            levelList.add(ManagerUserId);
            levelList.add(ARMUserId);
            levelList.add(RMUserId);
            levelList.add(CMUserId);
            levelList.add(CDUserId);

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

            // New/Update Contact
            if(newContactRTId.equals(cr.RecordTypeId) || updateContactRTId.equals(cr.RecordTypeId)) {
                cr.CN_Is_Auto_Approved__c = true;
                cr.CN_Finance_AR__c = settings.CN_Finance_AR_UserId__c;
            // New Ship-to
            } else if(newShiptoRTId.equals(cr.RecordTypeId)) {
                if(String.isNotBlank(owner.Title)) {
                    if(String.isBlank(RMUserId)) {
                        RMUserId = getLatestApprover(Constants.CN_USER_TITLE_RM, levelMap, levelList);
                    }
                    cr.CN_Approver_2__c = RMUserId;
                    cr.CN_Approver_3__c = settings.CN_Sales_MDM_UserId__c;                   
                    cr.CN_Approver_4__c = settings.CN_Finance_MDM_UserId__c;
                    cr.CN_Is_Auto_Approved__c = false;
                    cr.CN_Approval_Send_Notification__c = false;
                }
            // Update Ship-to
            } else if(updateShiptoRTId.equals(cr.RecordTypeId)) {
                Boolean isFinMDMRequired = false;
                Boolean isSalesMDMRequired = false;
                Boolean isOnlyOtherFieldChanged = true;
                Boolean isApprover2Needed = false;
                if(String.isNotBlank(owner.Title)) {
                    if(changedFieldSet.contains('CN_ShipTo_Delivery_Plant__c')) {
                        cr.CN_Approver_1__c = titleUserIdMap.get(Constants.CN_USER_TITLE_MANAGER);
                        isFinMDMRequired = true;
                        isSalesMDMRequired = true;
                        isOnlyOtherFieldChanged = false;
                    }
                    if(
                        changedFieldSet.contains('CN_ShipTo_Delivery_Address_CN__c') ||
                        changedFieldSet.contains('CN_ShipTo_Delivery_Address_EN__c') ||
                        changedFieldSet.contains('CN_ShipTo_Province_CN__c') ||
                        changedFieldSet.contains('CN_ShipTo_City_CN__c') ||
                        changedFieldSet.contains('CN_ShipTo_Street__c')
                    ) {
                            cr.CN_Approver_2__c = titleUserIdMap.get(Constants.CN_USER_TITLE_RM); 
                            isFinMDMRequired = true;
                            isSalesMDMRequired = true;
                            isOnlyOtherFieldChanged = false;
                            isApprover2Needed = true;
                    }
                    if(isApprover2Needed) {
                        if(cr.CN_Approver_2__c == null) {
                            cr.CN_Approver_2__c = getLatestApprover(Constants.CN_USER_TITLE_RM, levelMap, levelList);
                        }
                    } else {
                        if(cr.CN_Approver_1__c == null) {
                            cr.CN_Approver_1__c = getLatestApprover(Constants.CN_USER_TITLE_MANAGER, levelMap, levelList);
                        }
                    }

                    if(isSalesMDMRequired) {
                        cr.CN_Approver_3__c = settings.CN_Sales_MDM_UserId__c;
                    }
                    if(isFinMDMRequired) {
                        cr.CN_Approver_4__c = settings.CN_Finance_MDM_UserId__c;
                    }
                    if(isOnlyOtherFieldChanged) {
                        cr.CN_Is_Auto_Approved__c = true;
                    }
                }
            // Update Account
            } else if(updateAccountRTId.equals(cr.RecordTypeId)) {
                Boolean isFinMDMRequired = false;
                Boolean isSalesMDMRequired = false;
                Boolean isAutoApproved = true;
                Boolean isAppprover1Needed = false;
                Boolean isAppprover2Needed = false;
                if(String.isNotBlank(owner.Title)) {
                    if(changedFieldSet.contains('CN_Account_Chain__c')) {
                        cr.CN_Approver_1__c = titleUserIdMap.get(Constants.CN_USER_TITLE_MANAGER);
                        isSalesMDMRequired = false; 
                        isAutoApproved = false;
                        isAppprover1Needed = true;
                    } 
                    if(
                        changedFieldSet.contains('CN_Account_Group_Name__c') ||
                        changedFieldSet.contains('CN_Account_Level__c') ||
                        changedFieldSet.contains('CN_Account_Brand__c')
                    ) {
                            cr.CN_Approver_2__c = titleUserIdMap.get(Constants.CN_USER_TITLE_RM);
                            isSalesMDMRequired = true;
                            isAutoApproved = false;
                            isAppprover2Needed = true;
                    } 
                    //Add Payment Terms & Reference day finance approve by Shuqi ----Start
                    /*if( 
                        changedFieldSet.contains('CN_Account_Invoice_Type__c') ||
                        changedFieldSet.contains('CN_Account_Bank_Account__c') ||
                        changedFieldSet.contains('CN_Account_Invoicing_Name__c') ||
                        changedFieldSet.contains('CN_Account_Tax_Registration_No__c') ||
                        changedFieldSet.contains('CN_Account_Invoice_Address_and_Phone__c')
                    ) {
                            isFinMDMRequired = true;
                            isAutoApproved = false;
                    }*/
                    if( 
                        changedFieldSet.contains('CN_Account_Invoice_Type__c') ||
                        changedFieldSet.contains('CN_Account_Bank_Account__c') ||
                        changedFieldSet.contains('CN_Account_Invoicing_Name__c') ||
                        changedFieldSet.contains('CN_Account_Tax_Registration_No__c') ||
                        changedFieldSet.contains('CN_Account_Invoice_Address_and_Phone__c') ||
                        changedFieldSet.contains('CN_Account_Payment_Terms__c') ||
                        changedFieldSet.contains('CN_Account_Reference_Day__c')
                    ) {
                            isFinMDMRequired = true;
                            isAutoApproved = false;
                    }
                    //Add Payment Terms & Reference day finance approve by Shuqi ----end
                    if(
                        changedFieldSet.contains('CN_Account_License_Name_CN__c') ||
                        changedFieldSet.contains('CN_Account_License_Name_EN__c') ||
                        changedFieldSet.contains('CN_Account_Category__c') ||
                        changedFieldSet.contains('CN_Account_Subcategory__c') ||
                        changedFieldSet.contains('CN_Account_Sales_District__c') ||
                        changedFieldSet.contains('CN_Account_Delivery_Plant__c') 
                    ) {
                        cr.CN_Approver_2__c = titleUserIdMap.get(Constants.CN_USER_TITLE_RM);
                        isSalesMDMRequired = true;
                        isFinMDMRequired = true;
                        isAutoApproved = false;
                        isAppprover2Needed = true;
                    }
                    if(
                        changedFieldSet.contains('CN_Account_Store_Name_CN__c') ||
                        changedFieldSet.contains('CN_Account_Store_Name_EN__c') ||
                        changedFieldSet.contains('CN_Account_The_Number_Of_Seats__c') ||
                        changedFieldSet.contains('CN_Account_Potential_Volume_Market__c') ||
                        changedFieldSet.contains('CN_Account_Potential_Volume_Chance__c') ||
                        changedFieldSet.contains('CN_Account_Competitors__c') ||
                        changedFieldSet.contains('CN_Account_Number_Of_Stores__c') ||
                        changedFieldSet.contains('CN_Account_Competitors__c') ||
                        changedFieldSet.contains('CN_Account_Payment_Type__c') ||
                        changedFieldSet.contains('CN_Account_Payment_Bank_Name__c') ||
                        changedFieldSet.contains('CN_Account_Payment_Bank_Account__c') ||
                        changedFieldSet.contains('CN_Account_Payment_Name__c') ||
                        changedFieldSet.contains('CN_Account_Sinodis_Finance_AR__c')
                    ) {
                            if(isAutoApproved) {
                                cr.CN_Is_Auto_Approved__c = true;
                                isFinMDMRequired = true;
                                cr.CN_Approver_1__c = titleUserIdMap.get(Constants.CN_USER_TITLE_MANAGER);
                                cr.CN_Approval_Send_Notification__c = true;
                            }

                    }

                    // Set The Last Stand Approver
                    if(isAutoApproved) {
                        if(cr.CN_Approver_1__c == null) {
                            cr.CN_Approver_1__c = getLatestApprover(Constants.CN_USER_TITLE_MANAGER, levelMap, levelList);
                        }
                    } else {
                        if(isAppprover2Needed) {
                            if(cr.CN_Approver_2__c == null) {
                                cr.CN_Approver_2__c = getLatestApprover(Constants.CN_USER_TITLE_RM, levelMap, levelList);
                            }
                        }
                        if(isAppprover1Needed) {
                            if(cr.CN_Approver_1__c == null) {
                                cr.CN_Approver_1__c = getLatestApprover(Constants.CN_USER_TITLE_MANAGER, levelMap, levelList);
                            }
                        }
                    }

                    if(isSalesMDMRequired) {
                        cr.CN_Approver_3__c = settings.CN_Sales_MDM_UserId__c;
                        if(cr.CN_Approver_3__c == owner.Id && isFinMDMRequired == false) {
                            isAutoApproved = true;
                        }
                    }
                    if(isFinMDMRequired) {
                        cr.CN_Approver_4__c = settings.CN_Finance_MDM_UserId__c;
                        if(cr.CN_Approver_4__c == owner.Id) {
                            isAutoApproved = true;
                        }
                    }
                    if(isAutoApproved) {
                        cr.CN_Is_Auto_Approved__c = true;
                    }
                }
            }
        }
    }
    public String getLatestApprover(String title, Map<String, Integer> levelMap, List<String> levelList) {
        String latestApproverId = null;
        if(levelMap.containsKey(title)) {
            if(levelMap.get(title) <= levelList.size()) {
                if(String.isBlank(levelList[levelMap.get(title)])) {
                    for(Integer i = levelMap.get(title); i < levelList.size(); i++) {
                        if(String.isNotBlank(levelList[i])) {
                            latestApproverId = levelList[i];
                            break;
                        }
                    }
                } else {
                    latestApproverId = levelList[levelMap.get(title)];
                }
            }
        }
        return latestApproverId;
    }
}
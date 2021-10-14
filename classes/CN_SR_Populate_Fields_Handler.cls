/**************************************************************************************************
 * Name           : CN_SR_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-07-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_SR_Populate_Fields_Handler implements Triggers.Handler{
    Set<Id> cnRTIdSet = new Set<Id>();
    Id cnOfficeRepackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_OFFICE_REPACK_RT_API_NAME).getRecordTypeId();
    Id cnWholePackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_WHOLE_PACK_RT_API_NAME).getRecordTypeId();
    public void handle() {
        this.cnRTIdSet.add(this.cnOfficeRepackRTId);
        this.cnRTIdSet.add(this.cnWholePackRTId);
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        } else if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }
    public void handleBeforeInsert() {
        List<CN_Sample_Request__c> srList = new List<CN_Sample_Request__c>();
        for(CN_Sample_Request__c sr : (List<CN_Sample_Request__c>)Trigger.new) {
            if(cnRTIdSet.contains(sr.RecordTypeId)) {
                srList.add(sr);
            }
        }
        if(srList.size() > 0) {
            populateAccount(srList);
            //populateApprover1(srList);
            populateApprover2(srList);
            
        }
    }
    public void handleBeforeUpdate() {
        List<CN_Sample_Request__c> srList1 = new List<CN_Sample_Request__c>();
        List<CN_Sample_Request__c> srList2 = new List<CN_Sample_Request__c>();
        for(CN_Sample_Request__c sr : (List<CN_Sample_Request__c>)Trigger.new) {
            CN_Sample_Request__c oldSr = (CN_Sample_Request__c)Trigger.oldMap.get(sr.Id);
            if(oldSr.CN_Opportunity_Name__c != sr.CN_Opportunity_Name__c) {
                if(cnRTIdSet.contains(sr.RecordTypeId)) {
                    srList1.add(sr);
                }
            }
            if(oldSr.OwnerId != sr.OwnerId || (sr.CN_Sample_Request_Status__c != oldSr.CN_Sample_Request_Status__c && Constants.CN_SR_STATUS_READY.equals(sr.CN_Sample_Request_Status__c))) {
                if(cnRTIdSet.contains(sr.RecordTypeId)) {
                    srList2.add(sr);
                }
            }
        }
        if(srList1.size() > 0) {
            populateAccount(srList1);
            populateApprover2(srList1);
            // createSRSharing(srList1);
        }
        if(srList2.size() > 0) {
            populateApprover2(srList1);
        }
    }

    public void handleAfterUpdate() {
        List<CN_Sample_Request__c> srList = new List<CN_Sample_Request__c>();
        for(CN_Sample_Request__c sr : (List<CN_Sample_Request__c>)Trigger.new) {
            if(cnRTIdSet.contains(sr.RecordTypeId)) {
                CN_Sample_Request__c oldSr = (CN_Sample_Request__c)Trigger.oldMap.get(sr.Id);
                if(sr.CN_Sample_Request_Status__c != oldSr.CN_Sample_Request_Status__c && Constants.CN_SR_STATUS_READY.equals(sr.CN_Sample_Request_Status__c)) {
                    srList.add(sr);
                }
            }
        }
        if(srList.size() > 0) {
            //createSRSharing(srList);
        }
    }

    public void populateAccount(List<CN_Sample_Request__c> srList) {
        Set<Id> oppIdSet = new Set<Id>();
        for(CN_Sample_Request__c sr : srList) {
            oppIdSet.add(sr.CN_Opportunity_Name__c);
        }
        List<Opportunity> oppList = [SELECT Id,
                                            AccountId
                                    FROM Opportunity
                                    WHERE Id in :oppIdSet];
        Map<Id, Id> oppAccountIdMap = new Map<Id,Id>();
        for(Opportunity opp : oppList) {
            oppAccountIdMap.put(opp.Id, opp.AccountId);
        }
        for(CN_Sample_Request__c sr : srList) {
            sr.CN_Account_Name__c = oppAccountIdMap.get(sr.CN_Opportunity_Name__c);
        }
    }
    /*
    public void populateApprover1(List<CN_Sample_Request__c> srList) {
        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        Set<Id> accIdSet = new Set<Id>();
        for(CN_Sample_Request__c sr : srList) {
            accIdSet.add(sr.CN_Account_Name__c);
        }
        List<Account> accList = [SELECT Id,
                                        CN_Sales_Team_UI__c 
                                FROM Account
                                WHERE Id in :accIdSet];
        Map<Id, Id> stAccIdMap = new Map<Id, Id>();
        Set<Id> stIdSet = new Set<Id>();
        for(Account acc : accList) {
            stAccIdMap.put(acc.CN_Sales_Team_UI__c, acc.Id);
            stIdSet.add(acc.CN_Sales_Team_UI__c);
        }
        List<CN_Sales_Team__c> stList= [SELECT Id,
                                         Name
                                 FROM CN_Sales_Team__c
                                 WHERE Id in :stIdSet];
        Map<Id, String> accSTNameMap = new Map<Id, String>();
        for(CN_Sales_Team__c st : stList) {
            if(stAccIdMap.containsKey(st.Id)) {
                accSTNameMap.put(stAccIdMap.get(st.Id), st.Name);
            }
        }
        for(CN_Sample_Request__c sr : srList) {
            if(accSTNameMap.get(sr.CN_Account_Name__c) == Constants.CN_SALES_TEAM_NAME_KA) {
                sr.CN_Approver1_CCE__c = settings.CN_CCE1_KA__c;
            } else if (accSTNameMap.get(sr.CN_Account_Name__c) == Constants.CN_SALES_TEAM_NAME_DS) {
                sr.CN_Approver1_CCE__c = settings.CN_CCE2_DS__c;
            } else if (accSTNameMap.get(sr.CN_Account_Name__c) == Constants.CN_SALES_TEAM_NAME_WS) {
                sr.CN_Approver1_CCE__c = settings.CN_CCE3_WS__c;
            }
        }
    }
    */
    public void populateApprover2(List<CN_Sample_Request__c> srList) {
        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        
        Set<String> ownerIdSet = new Set<String>();
        for(CN_Sample_Request__c sr : srList) {
            ownerIdSet.add(sr.OwnerId);
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
        for(CN_Sample_Request__c sr : srList) {

            sr.CN_Approver1_CCE__c = null;
            sr.CN_Approver2_Channel_Leader__c = null;

            User owner = ownerMap.get(sr.OwnerId);
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

            if(String.isNotBlank(owner.Title)) {

                sr.CN_Approver1_CCE__c = getLatestApprover(Constants.CN_USER_TITLE_MANAGER, levelMap, levelList);

                String CMId = titleUserIdMap.get(Constants.CN_USER_TITLE_CM);
                if(String.isNotBlank(CMId)) {
                    if(CMId != sr.CN_Approver1_CCE__c) {
                        sr.CN_Approver2_Channel_Leader__c = CMId;
                    }
                } else {
                    String latestApproverId = getLatestApprover(Constants.CN_USER_TITLE_CM, levelMap, levelList);
                    if(sr.CN_Approver1_CCE__c != latestApproverId) {
                        sr.CN_Approver2_Channel_Leader__c = getLatestApprover(Constants.CN_USER_TITLE_CM, levelMap, levelList);
                    }
                }
            }
        }
    }
    /*
    public void createSRSharing(List<CN_Sample_Request__c> srList) {
        List<CN_Sample_Request__Share> srsList = new List<CN_Sample_Request__Share>();
        for(CN_Sample_Request__c sr : srList) {
            CN_Sample_Request__Share srsObj = new CN_Sample_Request__Share(
                ParentId = sr.Id,
                UserOrGroupId = sr.CN_Approver1_CCE__c,
                AccessLevel = Constants.CN_SR_SHARING_ROWCAUSE_EDIT,
                RowCause = Constants.CN_SR_SHARING_ACCESSLEVEL_MANUAL
            );
            srsList.add(srsObj);
        }
        insert srsList;
    }
    */
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
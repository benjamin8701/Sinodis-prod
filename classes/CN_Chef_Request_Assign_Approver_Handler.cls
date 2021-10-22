/**************************************************************************************************
 * Name           : CN_Chef_Request_Assign_Approver_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Request_Assign_Approver_Handler implements Triggers.Handler {
    Set<Id> cnRTIdSet = new Set<Id>();
    Id chefRequest1on1NewRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_1ON1_NEW_RT_API_NAME).getRecordTypeId();
    Id chefRequest1on1RTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_1ON1_RT_API_NAME).getRecordTypeId();
    Id chefRequestChefSelfRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_SELF_RT_API_NAME).getRecordTypeId();
    Id chefRequestChefDemoRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_DEMO_RT_API_NAME).getRecordTypeId();
    Id chefRequestMKTDEVRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_MKT_DEV_RT_API_NAME).getRecordTypeId();
    public void handle() {
        this.cnRTIdSet.add(this.chefRequest1on1NewRTId);
        this.cnRTIdSet.add(this.chefRequest1on1RTId);
        this.cnRTIdSet.add(this.chefRequestChefSelfRTId);
        this.cnRTIdSet.add(this.chefRequestChefDemoRTId);
        this.cnRTIdSet.add(this.chefRequestMKTDEVRTId);
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }        
    }
    public void handleBeforeInsert() {
        List<CN_Chef_Request__c> crList = new List<CN_Chef_Request__c>();
        for(CN_Chef_Request__c cr : (List<CN_Chef_Request__c>)Trigger.new) {
            if(cr.RecordTypeId == chefRequest1on1NewRTId) {
                crList.add(cr);
            }
        }
        if(crList.size() > 0) {
            populateApprover(crList);
        }
    }
    public void handleBeforeUpdate() {
        List<CN_Chef_Request__c> crList = new List<CN_Chef_Request__c>();
        for(CN_Chef_Request__c cr : (List<CN_Chef_Request__c>)Trigger.new) {
            CN_Chef_Request__c oldCr = (CN_Chef_Request__c)Trigger.oldMap.get(cr.Id);
            if(oldCr.OwnerId != cr.OwnerId || (oldCr.CN_Status__c != cr.CN_Status__c && Constants.CN_CHEF_REQUEST_STATUS_READY_FOR_APPROVAL.equals(cr.CN_Status__c))) {
                if(cr.RecordTypeId == chefRequest1on1RTId) {
                    crList.add(cr);
                }
            }
        }
        if(crList.size() > 0) {
            populateApprover(crList);
        }
    }

    public void populateApprover(List<CN_Chef_Request__c> crList) {
        Set<String> ownerIdSet = new Set<String>();
        for(CN_Chef_Request__c cr : crList) {
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
        for(CN_Chef_Request__c cr : crList) {
            cr.CN_Approver_1__c = null;
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

            cr.CN_Approver_1__c = titleUserIdMap.get(Constants.CN_USER_TITLE_CM);
            if(cr.CN_Approver_1__c == null) {
                cr.CN_Approver_1__c = getLatestApprover(Constants.CN_USER_TITLE_CM, levelMap, levelList);
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
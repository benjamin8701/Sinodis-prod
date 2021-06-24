/**************************************************************************************************
 * Name           : CN_Account_Populate_Approver_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Populate_Approver_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }        
    }
    public void handleBeforeInsert() {
        Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
        List<Account> accList = new List<Account>();
        for(Account acc : (List<Account>)Trigger.new) {
            if(newDirectRTId == acc.RecordTypeId && acc.CN_Is_Sales_Owner__c) {
                accList.add(acc);
            }
        }
        if(accList.size() > 0) {
            populateApprover(accList);
        }
    }
    
    public void handleBeforeUpdate() {
    	Id editDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId();
        List<Account> accList = new List<Account>();
        for(Account acc : (List<Account>)Trigger.new) {
            Account oldAcc = (Account)Trigger.oldMap.get(acc.Id);
            if(oldAcc.OwnerId != acc.OwnerId || (oldAcc.CN_Account_Status__c != acc.CN_Account_Status__c && Constants.CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL.equals(acc.CN_Account_Status__c))) {
                if(editDirectRTId == acc.RecordTypeId && acc.CN_Is_Sales_Owner__c) {
                    accList.add(acc);
                }
            }
        }
        if(accList.size() > 0) {
            populateApprover(accList);
        }
    }
    
    public void populateApprover(List<Account> accList) {

        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        
        Set<String> ownerIdSet = new Set<String>();
        for(Account acc : accList) {
            ownerIdSet.add(acc.OwnerId);
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
        for(Account acc : accList) {

            acc.CN_Approver_1__c = null;
            acc.CN_Approver_2__c = null;
            acc.CN_Approver_3__c = null;
            acc.CN_Approver_4__c = null;
            acc.CN_Approver_5__c = null;

            User owner = ownerMap.get(acc.OwnerId);
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
            if(String.isNotBlank(owner.Title)) {
                String RMId = titleUserIdMap.get(Constants.CN_USER_TITLE_RM);
                String CMId = titleUserIdMap.get(Constants.CN_USER_TITLE_CM);
                String CDId = titleUserIdMap.get(Constants.CN_USER_TITLE_CD);
                
                // Set The Last Stand Approver
                if(!acc.CN_Is_Cross_Channel__c) {
                    if(String.isBlank(CMId)) {
                        CMId = CDId;
                    }
                }

                acc.CN_Approver_1__c = RMId;
                acc.CN_Approver_2__c = CMId;
                acc.CN_Approver_3__c = CDId;
            }
            acc.CN_Approver_4__c = settings.CN_Sales_MDM_UserId__c;
            acc.CN_Approver_5__c = settings.CN_Finance_MDM_UserId__c;
        }
    }
    
}
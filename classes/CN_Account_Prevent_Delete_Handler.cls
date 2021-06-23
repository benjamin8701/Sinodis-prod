/**************************************************************************************************
 * Name           : CN_Account_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-06
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Prevent_Delete_Handler implements Triggers.Handler{
    Set<Id> CN_RTIds = new Set<Id>();
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    
    public void handleBeforeDelete() {
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_INDIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_INDIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId());
        for(Account acc : (List<Account>)Trigger.Old) {          
            if(CN_RTIds.contains(acc.RecordTypeId) && 
                (
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED.equals(acc.CN_Account_Status__c) ||
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL.equals(acc.CN_Account_Status__c) ||
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_SUBMITTED_FOR_APPROVAL.equals(acc.CN_Account_Status__c) ||
                    String.isNotBlank(acc.CN_Sync_Status__c)
                )
            ){
                acc.addError(system.Label.CN_Account_Has_Approved_Or_Synced);
            }
        }
    }
          
}
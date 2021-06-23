/**************************************************************************************************
 * Name           : CN_Account_New_Contact_Request_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-05-07
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_New_Contact_Request_LC_Ctrl {
    @AuraEnabled
    public static Map<String, Object> getContact(String recordId) {

        List<Account> accList = [SELECT Id, CN_Sync_Status__c, CN_Account_Status__c FROM Account WHERE Id =: recordId];
        Account sourceAccount = accList[0];
        if(!(Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS.equals(sourceAccount.CN_Sync_Status__c) && Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED.equals(sourceAccount.CN_Account_Status__c))) {
            throw new AuraHandledException(System.Label.CN_Account_Not_Synced);
        }
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
        
        return new Map<String, Object>{
      		'sourceAccount' => sourceAccount,
            'crRTId' => crRTId
        };
    }
}
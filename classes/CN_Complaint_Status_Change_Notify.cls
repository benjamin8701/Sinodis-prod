/**************************************************************************************************
 * Name           : CN_Complaint_Status_Change_Notify
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-01-15
 * Modify History : 
 **************************************************************************************************/
public with sharing class CN_Complaint_Status_Change_Notify implements Triggers.Handler {
    private static Boolean isFirstTime = true;
    public void handle() {
		if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
        //workflow:filed update => Repeated execution
        if(Trigger.isAfter && Trigger.isUpdate){
            if(isFirstTime) {
                handleAfterUpdate();
                isFirstTime = false;
            }
        }  
    }

    public void handleAfterUpdate() {
        Id cnCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_RECORD_TYPE_COMPLAINT).getRecordTypeId();
        List<Case> cnCaseList = new List<Case>();
        Map<ID,Case> oldCaseMap = (Map<ID,Case>)Trigger.oldMap;
        for(Case cases : (List<Case>)Trigger.new) {
            if(cnCaseId.equals(cases.recordTypeId)&&(
               Constants.CN_CA_STATUS_REJECTED.equals(cases.status)
            || Constants.CN_CA_STATUS_RESOLVED.equals(cases.status)
            || Constants.CN_CA_STATUS_CLOSED.equals(cases.status)
            )
            &&Constants.CN_COMPLAINT_SOURCE_ECOMMERCE.equals(cases.Origin)) {
                cnCaseList.add(cases);
            }
        }
        if(cnCaseList.size() > 0) {
            notifyUsers(cnCaseList);
        }
    }



    public void handleAfterInsert() {
        Id cnCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_RECORD_TYPE_COMPLAINT).getRecordTypeId();
        List<Case> cnCaseList = new List<Case>();
        for(Case cases : (List<Case>)Trigger.new) {
            if(cnCaseId.equals(cases.recordTypeId)&& Constants.CN_CA_STATUS_NEW.equals(cases.status)&&Constants.CN_COMPLAINT_SOURCE_ECOMMERCE.equals(cases.Origin)) {
                cnCaseList.add(cases);
            }
        }
        if(cnCaseList.size() > 0) {
            notifyUsers(cnCaseList);
        }
    }

    public static void notifyUsers(List<Case> cnCaseList) {
        Set <String> recipientsIds = new Set <String>();
        String cnCustomNotifyType = Constants.CN_Custom_Notification_API_NAME;

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName = :cnCustomNotifyType];

        Set<Id> accountIds = new Set<Id>();
        for (Case cases : cnCaseList) {
            accountIds.add(cases.AccountId);
        }
        
        Map<Id, String> accountIdToOwnerIdMap = new Map<Id, String>();
        for (Account account : [SELECT Id, CN_Sales_Team__c,OwnerId
                                FROM Account
                                WHERE Id IN :accountIds]) {
           accountIdToOwnerIdMap.put(account.id,account.OwnerId);
        }
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(notificationType.Id);
        for(Case cases : cnCaseList) {
            String userId = accountIdToOwnerIdMap.get(cases.AccountId);
            if (Constants.CN_CA_STATUS_NEW.equals(cases.Status)) {
                notification.setTitle(System.Label.CN_Complaint_Status_New_Notification_Title);
            } else if (Constants.CN_CA_STATUS_CLOSED.equals(cases.Status)) {
                notification.setTitle(System.Label.CN_Complaint_Status_Closed_Notification_Title);
            } else if(Constants.CN_CA_STATUS_REJECTED.equals(cases.Status)){
                notification.setTitle(System.Label.CN_Complaint_Status_Rejected_Notification_Title);
            }
            else if(Constants.CN_CA_STATUS_RESOLVED.equals(cases.Status)){
                notification.setTitle(System.Label.CN_Complaint_Status_Resolved_Notification_Title);
            }
            notification.setBody(System.Label.CN_Complaint_Status_Changed_Notification_Body+''+cases.Subject);
            notification.setTargetId(cases.Id);
            //add by He Peng notify cs
            Id CSQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'CN_CS_Queue'].Id;
            if (userId != null) {
                recipientsIds.add(userId);
                recipientsIds.add(CSQueueId);
            }
            notification.send(recipientsIds);
       }
    }



}
/**************************************************************************************************
 * Name           : CN_Lead_Owner_Changed_Custom_Notification
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-07-22
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Lead_Owner_Changed_Custom_Notify implements Triggers.Handler{
    public static Boolean isTriggerRun = true;
    public void handle() {
		if(Trigger.isBefore && Trigger.isUpdate) {
            if(CN_CR_Generate_Contact_Handler.isTriggerRun) {
                handleBeforeUpdate();
            }
        }   
    }
    public void handleBeforeUpdate() {
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        List<Lead> cnLeadList = new List<Lead>();
        Map<Id, Lead> oldLeadMap = (Map<Id, Lead>)Trigger.oldMap;
        for(Lead lead : (List<Lead>)Trigger.new) {
            if(cnLeadRTId.equals(lead.recordTypeId) && lead.OwnerId != oldLeadMap.get(lead.Id).OwnerId) {
                cnLeadList.add(lead);
            }
        }

        if(cnLeadList.size() > 0) {
            notifyUsers(cnLeadList);
        }
        CN_CR_Generate_Contact_Handler.isTriggerRun = false;
    }

    public static void notifyUsers(List<Lead> cnLeadList) {
        Set <Id> leadIds = new Set <Id>();
        Set <String> recipientsIds = new Set <String>();
        String cnCustomNotifyType = Constants.CN_Custom_Notification_API_NAME;

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName = :cnCustomNotifyType];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(System.Label.CN_Lead_Owner_Changed_Notification_Title);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        
        // Actually send the notification
        for(Lead lead : cnLeadList) {
            notification.setBody(System.Label.CN_Lead_Owner_Changed_Notification_Body + ' ' + lead.FirstName + ' ' + lead.LastName);
            notification.setTargetId(lead.Id );
            recipientsIds.add(lead.OwnerId);
            notification.send(recipientsIds);
        }
    }
}
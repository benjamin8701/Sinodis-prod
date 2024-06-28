/**************************************************************************************************
 * Name           : CN_Lead_Invitation_Owner_Notify
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-03-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Lead_Invitation_Owner_Notify implements Triggers.Handler{
    public void handle() {
		if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }   
    }

    public void handleAfterInsert() {
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        List<Lead> cnLeadList = new List<Lead>();
        //Map<Id, Lead> oldLeadMap = (Map<Id, Lead>)Trigger.oldMap;
        Map<String,List<Lead>> inviteLeadMap = new  Map<String,List<Lead>>();
        for(Lead item : (List<Lead>)Trigger.new) {
            if(!String.isEmpty(item.CN_Invitation_Code__c)){
                if(inviteLeadMap.get(item.CN_Invitation_Code__c)==null){
                    inviteLeadMap.put(item.CN_Invitation_Code__c,new List<Lead>());
                }
                 inviteLeadMap.get(item.CN_Invitation_Code__c).add(item);
            }

        }
            List<User> inviteUserList = [select Id,CN_User_Personnel_Number__c from User where CN_User_Personnel_Number__c =: inviteLeadMap.keySet()];
            Map<String,User> inviteUserMap = new Map<String,User>();
            for( User user:inviteUserList ){
                inviteUserMap.put(user.CN_User_Personnel_Number__c,user);
            }
            for(String invite:inviteLeadMap.keySet()){
                User inviteUser = inviteUserMap.get(invite);
                if(inviteUser ==null){
                    inviteLeadMap.remove(invite);
                }
            }
          
            List<Lead> inviteLead =new List<Lead>();
            for(List<Lead> next : inviteLeadMap.values()){
                inviteLead.addall(next);
            }
            for(Lead lead:inviteLead){
                if(cnLeadRTId.equals(lead.recordTypeId)) {
                    cnLeadList.add(lead);
                }
            }
        if(cnLeadList.size() > 0) {
            notifyUsers(cnLeadList);
        }
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
            recipientsIds.clear();
        }
    }

}
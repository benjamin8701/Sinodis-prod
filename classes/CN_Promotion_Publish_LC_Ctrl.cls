/**************************************************************************************************
 * Name           : CN_Promotion_Publish_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-08-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Promotion_Publish_LC_Ctrl {
    @auraEnabled
    public static Map<String, Object> prmtPublish(String recordId) {
        String errorMessage = '';
        String prmtName = '';
        String prmtStatus = '';
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Promotion_Not_Found);
        }
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('CN_Promotion__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_Promotion_No_Permission);
        }
        List<CN_Promotion__c> prmtList = [SELECT Id,
                                                 Name,
                                                 CN_Status__c
                                    FROM CN_Promotion__c
                                    WHERE Id = :recordId];
        if(prmtList.size() > 0) {
                prmtName = prmtList[0].Name;
                prmtStatus = prmtList[0].CN_Status__c;
        }
        if(!(prmtStatus.equals(Constants.CN_PROMOTION_STATUS_READY) || prmtStatus.equals(Constants.CN_PROMOTION_STATUS_PUBLISHED))) {
            throw new AuraHandledException(System.Label.CN_PRMT_Status_Not_Ready);
        }
        populatePRMTField(recordId);
        List<CN_Promotion_Member__c> prmtMemList = [SELECT CN_Account__c,
                                                           CN_IsPublished__c,
                                                           CN_Promotion__c,
                                                           Id
                                                    FROM CN_Promotion_Member__c
                                                    WHERE CN_Promotion__c = :recordId AND CN_IsPublished__c = false];
        if(prmtMemList.size() > 0) {
            Map<Id, Id> pmAccOwnerIdMap = populatePRMTMemField(prmtMemList);
            createPRMTMemberSharing(prmtMemList, pmAccOwnerIdMap);
            notifyUsers(prmtName, prmtList, pmAccOwnerIdMap);
        }
        return new Map<String, Object>{
            'errorMessage' => errorMessage
        };
    }

    public static void populatePRMTField(String recordId) {
        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        List<CN_Promotion__c> prmtList = [SELECT Id,
                                        CreatedById,
                                        CN_Status__c,
                                        CN_Last_Published_Time__c,
                                        CN_Publish_Date__c,
                                        CN_CS_Group_Email__c,
                                        CN_MKT_Group_Email__c
                                    FROM CN_Promotion__c
                                    WHERE Id =: recordId];
        if(prmtList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Promotion_Not_Found);
        }

        CN_Promotion__c prmtToUpdate = prmtList[0];
        if(Constants.CN_PROMOTION_STATUS_READY.equals(prmtToUpdate.CN_Status__c) || Constants.CN_PROMOTION_STATUS_PUBLISHED.equals(prmtToUpdate.CN_Status__c)) {
            prmtToUpdate.CN_Status__c = Constants.CN_PROMOTION_STATUS_PUBLISHED;
            prmtToUpdate.CN_Last_Published_Time__c = DateTime.now();
            if(prmtToUpdate.CN_Publish_Date__c == null) {
                prmtToUpdate.CN_Publish_Date__c = Date.today();
            }
            prmtToUpdate.CN_CS_Group_Email__c = settings.CN_CS_Group_Email__c;
            prmtToUpdate.CN_MKT_Group_Email__c = settings.CN_MKT_Group_Email__c;
        } else{
            throw new AuraHandledException(System.Label.CN_Promotion_Can_Not_Published);
        }
        update prmtToUpdate;
    }

    public static Map<Id,Id> populatePRMTMemField(List<CN_Promotion_Member__c> prmtMemList) {
        Map<Id,Id> pmAccOwnerIdMap = new Map<Id,Id>();
        Map<Id,Id> accPRMTIdMap = new Map<Id,Id>();
        List<CN_Promotion_Member__c> prmtMemUpdateList = new List<CN_Promotion_Member__c>();
        Set<Id> accIds = new Set<Id>();
        if(prmtMemList.size() > 0) {
            for(CN_Promotion_Member__c pm : prmtMemList) {
                accIds.add(pm.CN_Account__c);
                accPRMTIdMap.put(pm.CN_Account__c, pm.Id);
                if(pm.CN_IsPublished__c == Constants.CN_PROMOTION_MEMBER_PUBLISHED_FALSE) {
                    pm.CN_IsPublished__c = Constants.CN_PROMOTION_MEMBER_PUBLISHED_TRUE;
                    prmtMemUpdateList.add(pm);
                }
            }
            if(prmtMemUpdateList.size() > 0) {
                update prmtMemUpdateList;
            }
            if(accIds.size() > 0) {
                List<Account> accList = [SELECT Id,
                                                OwnerId
                                         FROM Account
                                         WHERE Id in : accIds];
                for(Account acc : accList) {
                    if(accPRMTIdMap.containsKey(acc.Id)) {
                        pmAccOwnerIdMap.put(accPRMTIdMap.get(acc.Id), acc.OwnerId);
                    }
                }
            }
        }
        return pmAccOwnerIdMap;
    }
    public static void createPRMTMemberSharing(List<CN_Promotion_Member__c> prmtMemList, Map<Id, Id> pmAccOwnerIdMap) {
        List<CN_Promotion__Share> promotionShareList = new List<CN_Promotion__Share>();
        List<CN_Promotion_Member__Share> promotionMemberShareList = new List<CN_Promotion_Member__Share>();

        if(prmtMemList.size() > 0) {
            for(CN_Promotion_Member__c pm : prmtMemList) {
                CN_Promotion_Member__Share pmsObj = new CN_Promotion_Member__Share(
                    ParentId = pm.Id,
                    UserOrGroupId = pmAccOwnerIdMap.get(pm.Id),
                    AccessLevel = Constants.CN_PROMOTION_SHARING_ROWCAUSE_READ,
                    RowCause = Constants.CN_PROMOTION_SHARING_ACCESSLEVEL_MANUAL
                );
                promotionMemberShareList.add(pmsObj);

                CN_Promotion__Share pms = new CN_Promotion__Share(
                    ParentId = pm.CN_Promotion__c,
                    UserOrGroupId = pmAccOwnerIdMap.get(pm.Id),
                    AccessLevel = Constants.CN_PROMOTION_SHARING_ROWCAUSE_READ,
                    RowCause = Constants.CN_PROMOTION_SHARING_ACCESSLEVEL_MANUAL
                );
                promotionShareList.add(pms);
            }
            if(promotionShareList.size() > 0) {
                insert promotionShareList;
            }
            if(promotionMemberShareList.size() > 0) {
                insert promotionMemberShareList;
            }
        }
    } 
    public static void notifyUsers(String prmtName, List<CN_Promotion__c> prmtList, Map<Id, Id> pmAccOwnerIdMap) {
        Set <Id> pmIds = new Set <Id>();
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
        notification.setTitle(System.Label.CN_PRMT_Published_Notification_Title);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        
        // Actually send the notification
        notification.setBody(System.Label.CN_PRMT_Published_Notification_Body + ' ' + prmtName);
        notification.setTargetId(prmtList[0].Id);
        recipientsIds.addAll((List<String>)pmAccOwnerIdMap.values());
        notification.send(recipientsIds);
    } 
}
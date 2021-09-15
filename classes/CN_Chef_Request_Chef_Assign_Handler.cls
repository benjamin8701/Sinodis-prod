/**************************************************************************************************
 * Name           : CN_Chef_Request_Chef_Assign_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Request_Chef_Assign_Handler implements Triggers.Handler {

    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }

    public void handleAfterUpdate() {

        List<CN_Chef_Request__c> confirmCRList = new List<CN_Chef_Request__c>();
        List<CN_Chef_Request__c> unConfirmCRList = new List<CN_Chef_Request__c>();

        Id chefRequestChefSelfRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_SELF_RT_API_NAME).getRecordTypeId();
        for(CN_Chef_Request__c cr: (List<CN_Chef_Request__c>)Trigger.new) {
            if(cr.RecordTypeId == chefRequestChefSelfRTId) {
                CN_Chef_Request__c oldCr = (CN_Chef_Request__c)Trigger.oldMap.get(cr.Id);
                if(!oldCr.CN_Confirmed__c && cr.CN_Confirmed__c) {
                    confirmCRList.add(cr);
                } else if(oldCr.CN_Confirmed__c && !cr.CN_Confirmed__c) {
                    unConfirmCRList.add(cr);
                }
            }
        }

        if(confirmCRList.size() > 0) {
            List<CN_Chefs_Assigned__c> caList = generateChefAssignList(confirmCRList);
            if(caList.size() > 0) {
                upsert caList CN_External_Id__c;
            }
        }
        if(unConfirmCRList.size() > 0) {
            List<CN_Chefs_Assigned__c> caList = getDeleteChefAssignList(unConfirmCRList);
            if(caList.size() > 0) {
                delete caList;
            }
        }
    }

    public List<CN_Chefs_Assigned__c> generateChefAssignList(List<CN_Chef_Request__c> confirmCRList) {
        
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();

        if(confirmCRList.size() > 0) {
            for(CN_Chef_Request__c cr: confirmCRList) {
                CN_Chefs_Assigned__c ca = new CN_Chefs_Assigned__c();
                ca.CN_Chef_Request__c = cr.Id;
                ca.CN_Chef__c = cr.OwnerId;
                ca.CN_Chef_Role__c = 'Leading Chef';
                ca.CN_Chef_Work_Start_Date__c = cr.CN_Start_Date__c;
                ca.CN_Chef_Work_End_Date__c = cr.CN_End_Date__c;
                ca.CN_External_Id__c = cr.Id + '-' + cr.OwnerId;
                ca.CN_Chef_Self_Confirm_Time__c = Datetime.now();
                caList.add(ca);
            }
        }

        return caList;
    }

    public List<CN_Chefs_Assigned__c> getDeleteChefAssignList(List<CN_Chef_Request__c> unConfirmCRList) {
        
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();

        if(unConfirmCRList.size() > 0) {
            Set<Id> crIdSet = new Set<Id>();
            for(CN_Chef_Request__c cr: unConfirmCRList) {
                crIdSet.add(cr.Id);
            }
            if(crIdSet.size() > 0) {
                caList = [SELECT Id, CN_Chef_Request__c FROM CN_Chefs_Assigned__c WHERE CN_Chef_Request__c in: crIdSet];
            }
        }

        return caList;
    }
}
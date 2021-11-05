/**************************************************************************************************
 * Name           : CN_Chef_Request_Auto_Confirm_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-11-01
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Request_Auto_Confirm_Handler implements Triggers.Handler {

    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }

    public void handleAfterUpdate() {

        List<CN_Chef_Request__c> crList = new List<CN_Chef_Request__c>();
        List<CN_Chef_Request__c> crList_confirm = new List<CN_Chef_Request__c>();

        Id chefRequestChefSelfRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_SELF_RT_API_NAME).getRecordTypeId();

        for(CN_Chef_Request__c cr: (List<CN_Chef_Request__c>)Trigger.new) {
            if(cr.RecordTypeId == chefRequestChefSelfRTId) {
                CN_Chef_Request__c oldCr = (CN_Chef_Request__c)Trigger.oldMap.get(cr.Id);
                if(oldCr.CN_Status__c!=cr.CN_Status__c && cr.CN_Status__c=='Approved') {
                    crList.add(cr);
                }
            }
        }
        if(crList.size()>0){
            crList_confirm = autoConfirmChefRequest(crList);
        }

        if(crList_confirm.size()>0){
            update crList_confirm;
        }
        
    }

    public List<CN_Chef_Request__c> autoConfirmChefRequest(List<CN_Chef_Request__c> confirmCRList) {
        
        List<CN_Chef_Request__c> crList_confirm = new List<CN_Chef_Request__c>();

        if(confirmCRList.size() > 0) {
            for(CN_Chef_Request__c cr: confirmCRList) {
                CN_Chef_Request__c cr_confirm = new CN_Chef_Request__c();
                cr_confirm.Id = cr.Id;
                cr_confirm.CN_Confirmed__c = true;
                cr_confirm.CN_Confirm_From_Apex_DateTime__c = Datetime.now();
                crList_confirm.add(cr_confirm);
            }
        }
        return crList_confirm;
    }
}
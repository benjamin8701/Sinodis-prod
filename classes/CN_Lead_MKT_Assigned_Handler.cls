/**************************************************************************************************
 * Name           : CN_Lead_MKT_Assigned_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-22
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Lead_MKT_Assigned_Handler implements Triggers.Handler{
    public void handle() {
		if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    public void handleBeforeUpdate() {
        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        for(Lead lead: (List<Lead>)Trigger.new) {
            Lead oldLead = (Lead)Trigger.oldMap.get(lead.Id);
            if(lead.Status != oldLead.Status && Constants.CN_LEAD_STATUS_MKT_QUALIFIED.equals(lead.Status)) {
                lead.OwnerId = settings.CN_Sales_MDM_UserId__c;
            }
        }
    }
}
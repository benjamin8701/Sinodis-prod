/**************************************************************************************************
 * Name           : CN_ShipTo_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-11
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_ShipTo_Prevent_Delete_Handler implements Triggers.Handler{
	
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }        
    }
    
    public void handleBeforeDelete() {
        Id shipToRTId = Schema.SObjectType.CN_Ship_to_Party__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SHIPTO_RT_API_NAME).getRecordTypeId();
        List<CN_Ship_to_Party__c> shipToList = new List<CN_Ship_to_Party__c>();
        for(CN_Ship_to_Party__c shipTo : (List<CN_Ship_to_Party__c>)Trigger.Old){
            if(
                shipTo.recordTypeId == shipToRTId && 
                (
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED.equals(shipTo.CN_Account_Status__c) || 
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL.equals(shipTo.CN_Account_Status__c) || 
                    Constants.CN_ACCOUNT_ACCOUNT_STATUS_SUBMITTED_FOR_APPROVAL.equals(shipTo.CN_Account_Status__c)
                )
            ){
                shipToList.add(shipTo);
            }         
        }
        if(shipToList.size()>0){
            preventDeleteShipTo(shipToList);
        }
    }
    
    public void preventDeleteShipTo(List<CN_Ship_to_Party__c> shipToList) {
        for(CN_Ship_to_Party__c shipTo : shipToList){
            shipTo.addError(system.Label.CN_ShipTo_Account_Approved_Or_Has_Synced);
        }
    }
}
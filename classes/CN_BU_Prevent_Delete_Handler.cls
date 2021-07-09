/**************************************************************************************************
 * Name           : CN_BU_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_BU_Prevent_Delete_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    
    public void handleBeforeDelete() {
        Id businessUnitRTId = Schema.SObjectType.CN_Business_Unit__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_BU_RT_API_NAME).getRecordTypeId();
        for(CN_Business_Unit__c bu : (List<CN_Business_Unit__c>)Trigger.Old) {
            if(businessUnitRTId.equals(bu.recordTypeId) &&  String.isNotBlank(bu.CN_Business_Unit_Code__c)
            ){
                bu.addError(system.Label.CN_BusinessUnit_Synced_Prevent_Delete);
            }
        }
    }
          
}
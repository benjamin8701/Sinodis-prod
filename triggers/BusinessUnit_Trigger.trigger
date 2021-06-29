/**************************************************************************************************
 * Name           : BusinessUnit_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
trigger BusinessUnit_Trigger on CN_Business_Unit__c (before delete) {
    if(Untils.isTriggerEnabled() && Constants.BU_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_BU_TRIGGER_ON) {
            if(Constants.CN_BUSINESSUNIT_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_BU_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
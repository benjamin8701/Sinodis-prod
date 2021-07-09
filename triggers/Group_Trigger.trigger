/**************************************************************************************************
 * Name           : Group_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
trigger Group_Trigger on CN_Group__c (before delete) {
    if(Untils.isTriggerEnabled() && Constants.GR_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_GR_TRIGGER_ON) {
            if(Constants.CN_GROUP_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Group_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
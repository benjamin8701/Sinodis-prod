/**************************************************************************************************
 * Name           : CN_Promotion_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
trigger CN_Promotion_Trigger on CN_Promotion__c (after update, before delete) {
    if(Untils.isTriggerEnabled() && Constants.PROMOTION_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_PROMOTION_TRIGGER_ON) {
            if(Constants.CN_PROMOTION_PREVENT_DELETE_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Promotion_Prevent_Delete_Handler());
            }
            if(Constants.CN_PROMOTION_VALIDATION_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Promotion_Validation_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
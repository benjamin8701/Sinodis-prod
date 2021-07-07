/**************************************************************************************************
 * Name           : Brand_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
trigger Brand_Trigger on CN_Brand__c (before delete) {
    if(Untils.isTriggerEnabled() && Constants.BR_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_BR_TRIGGER_ON) {
            if(Constants.CN_BRAND_PREVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Brand_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
/**************************************************************************************************
 * Name           : QTP_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-12
 * Modify History : 
 **************************************************************************************************/
trigger QTP_Trigger on CN_Quote_To_Promotion__c (before insert ,before delete) {
    if(Untils.isTriggerEnabled() && Constants.QTP_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_QTP_TRIGGER_ON) {
            if(Constants.CN_QTP_PREVENT_CHANGE_APPROVED_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_QTP_Prevent_Change_Approved_Handler());
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_QTP_Prevent_Change_Approved_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
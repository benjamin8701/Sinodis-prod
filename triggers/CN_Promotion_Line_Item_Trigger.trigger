/**************************************************************************************************
 * Name           : CN_Promotion_Line_Item_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
trigger CN_Promotion_Line_Item_Trigger on CN_Promotion_Line_Item__c (before delete) {
    if(Untils.isTriggerEnabled() && Constants.PROMOTION_LINE_ITEM_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_PROMOTION_LINE_ITEM_TRIGGER_ON) {
            if(Constants.CN_PROMOTION_LINE_ITEM_PREVENT_DELETE_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_PromotionLI_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
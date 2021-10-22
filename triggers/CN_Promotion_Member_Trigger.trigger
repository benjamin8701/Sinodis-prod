/**************************************************************************************************
 * Name           : CN_Promotion_Member_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
trigger CN_Promotion_Member_Trigger on CN_Promotion_Member__c (before insert, before update, before delete) {
    if(Untils.isTriggerEnabled() && Constants.PROMOTION_MEMBER_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_PROMOTION_MEMBER_TRIGGER_ON) {
            if(Constants.CN_PROMOTION_MEMBER_PREVENT_DELETE_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_PromotionM_Prevent_Delete_Handler());
            }
            if(Constants.CN_PROMOTION_MEMBER_SET_ACCOUNT_OWNER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_PromotionM_Set_Account_Handler());
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_PromotionM_Set_Account_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
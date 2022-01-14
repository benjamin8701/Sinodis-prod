/**************************************************************************************************
 * Name           : Product_Trigger
 * Object         : Product
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wan Houchen
 * Create Date    : 2022-01-04
 * Modify History : 
 **************************************************************************************************/
trigger Product_Trigger on Product2 (before insert, after insert, after update, before update,before delete) {
    if(Untils.isTriggerEnabled() && Constants.CN_PRODUCT_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Constants.CN_BRAND_OWNER_CHECK_HANDLER_TRIGGER_ON) {            
            triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Product_Description_Check_Handler());            
        }

        triggersObj.execute();
    }
}
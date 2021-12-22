/**************************************************************************************************
 * Name           : CN_PresetPrice_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-12-21
 * Modify History : 
 **************************************************************************************************/
trigger CN_PresetPrice_Trigger on CN_Preset_PriceBook_Entry__c (before insert,before update) {
    if(Untils.isTriggerEnabled() && Constants.PPBE_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_PPBE_TRIGGER_ON) {
            if(Constants.CN_PRESETPRICE_PRODUCT_VALIDATION_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_PresetPrice_Product_Validation());
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_PresetPrice_Product_Validation());
            }
        }
        triggersObj.execute(); 
    }
}
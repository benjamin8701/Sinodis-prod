/**************************************************************************************************
 * Name           : Sample_Product_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wang Jessica
 * Create Date    : 2021-08-19
 * Modify History : 
 **************************************************************************************************/
trigger Sample_Product_Trigger on CN_Sample_Product__c (before insert, before update, before delete) {
    if(Untils.isTriggerEnabled() && Constants.SAMPLE_PRODUCT_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_SAMPLE_PRODUCT_TRIGGER_ON) {
            if(Constants.CN_SP_POPULATE_FIELDS_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_SP_Populate_Fields_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_SP_Populate_Fields_Handler());
            }
            if(Constants.CN_SP_PREVENT_DELETE_HANDLER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.beforeDelete, new CN_SP_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
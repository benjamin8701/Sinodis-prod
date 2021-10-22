/**************************************************************************************************
 * Name           : CN_Demo_Used_Product_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
trigger CN_Demo_Used_Product_Trigger on CN_Demo_Used_Product__c (after insert, after update) {
    if(Untils.isTriggerEnabled() && Constants.DEMO_USED_PRODUCT_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_DEMO_USED_PRODUCT_TRIGGER_ON) {
            if(Constants.CN_DEMO_USED_PRODUCT_ACCUMULATE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterInsert, new CN_Demo_Used_Product_Accumulate_Handler());
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Demo_Used_Product_Accumulate_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
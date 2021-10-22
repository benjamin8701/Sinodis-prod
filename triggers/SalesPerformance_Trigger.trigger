/**************************************************************************************************
 * Name           : SalesPerformance_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-09-08
 * Modify History : 
 **************************************************************************************************/
trigger SalesPerformance_Trigger on CN_Sales_Performance__c (before insert,before update) {
	if(Untils.isTriggerEnabled() && Constants.SALESPERFOR_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_SALESPERFOR_TRIGGER_ON) {
            if(Constants.CN_SALESPERFOR_POPULATE_PRODUCT_HANDLER_ON) {
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_SP_Populate_Product_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_SP_Populate_Product_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
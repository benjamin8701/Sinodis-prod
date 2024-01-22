/**************************************************************************************************
 * Name           : ShipTo_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-11
 * Modify History : Leo 2023-08-07 add before update\before insert
 **************************************************************************************************/
trigger ShipTo_Trigger on CN_Ship_to_Party__c (before delete,before update,after insert,before insert,after update,after delete,after undelete) {
    if(Untils.isTriggerEnabled() && Constants.SHIPTO_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_SHIPTO_TRIGGER_ON) {
            if(Constants.CN_SHIPTO_PREVENT_DELETE_HANDLER_ON) {
                triggersObj.bind(Triggers.Evt.beforeDelete, new CN_ShipTo_Prevent_Delete_Handler());
            }
            //add by leo 2023.08.07:Mark shipto update only EC
            if(Constants.CN_SHIPTO_SEND_MG_CREATE_HANDLER_ON) {
                triggersObj.bind(Triggers.Evt.beforeInsert, new CN_ShipTo_Send_Mg_Handler());
                triggersObj.bind(Triggers.Evt.beforeUpdate, new CN_ShipTo_Send_Mg_Handler());
            }
            //add by leo 2023.08.07:Mark shipto update only EC
        }
        triggersObj.execute(); 
    }
}
/**************************************************************************************************
 * Name           : ShipTo_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-11
 * Modify History : 
 **************************************************************************************************/
trigger ShipTo_Trigger on CN_Ship_to_Party__c (before delete,after insert,after update,after delete,after undelete) {
    if(Untils.isTriggerEnabled() && Constants.SHIPTO_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_SHIPTO_TRIGGER_ON) {
            if(Constants.CN_SHIPTO_PREVENT_DELETE_HANDLER_ON) {
                triggersObj.bind(Triggers.Evt.beforeDelete, new CN_ShipTo_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
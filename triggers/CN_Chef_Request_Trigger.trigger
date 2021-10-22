/**************************************************************************************************
 * Name           : CN_Chef_Request_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
trigger CN_Chef_Request_Trigger on CN_Chef_Request__c (before insert, before update, after update, before delete) {
    if(Untils.isTriggerEnabled() && Constants.CHEF_REQUEST_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CHEF_REQUEST_TRIGGER_ON) {
            if(Constants.CN_CHEF_REQUEST_ASSIGN_APPROVER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Chef_Request_Assign_Approver_Handler());
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Chef_Request_Assign_Approver_Handler());
            }
            if(Constants.CN_CHEF_REQUEST_SET_ACCOUNT_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Chef_Request_Set_Acc_Handler());
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Chef_Request_Set_Acc_Handler());
            }
            if(Constants.CN_CHEF_REQUEST_EVENT_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Chef_Request_Event_Handler());
            }
            if(Constants.CN_CHEF_REQUEST_CHEF_ASSIGN_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Chef_Request_Chef_Assign_Handler());
            }
            if(Constants.CN_CHEF_REQUEST_PEVENT_DELETE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Chef_Request_Prevent_Delete_Handler());
            }
        }
        triggersObj.execute(); 
    }
}
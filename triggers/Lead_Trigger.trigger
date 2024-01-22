/**************************************************************************************************
 * Name           : Lead_Trigger
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-07-21
 * Modify History : 
 **************************************************************************************************/
trigger Lead_Trigger on Lead (before update,before insert,after update,after insert) {
    if(Untils.isTriggerEnabled() && Constants.LEAD_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_LEAD_TRIGGER_ON) {
            if(Constants.CN_LEAD_OWNER_CHANGED_CUSTOM_NOTIFICATION_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeupdate, new CN_Lead_Owner_Changed_Custom_Notify());
            }
            if(Constants.CN_LEAD_MKT_ASSIGNED_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.beforeupdate, new CN_Lead_MKT_Assigned_Handler());
                 // add by  Zhang Zhihao 2023.11.03 Allocation state
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Lead_MKT_Assigned_Handler());
                // add by  Zhang Zhihao 2023.11.03 Allocation state
            }
	    // add by leo 2023.08.23 mark Lead status change only EC
            if(Constants.CN_LEAD_STATUS_SEND_MG_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Lead_Status_Send_Mg_Handler());
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Lead_Status_Send_Mg_Handler());
                triggersObj.bind(Triggers.Evt.AfterInsert, new CN_Lead_status_Send_Mg_Handler());
                triggersobj.bind(Triggers.Evt.AfterUpdate, new CN_Lead_status_Send_Mg_Handler());
            }
	    // add by leo 2023.08.23 mark Lead status change only EC
        }
        triggersObj.execute(); 
    }
}
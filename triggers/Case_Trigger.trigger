/**************************************************************************************************
 * Name           : Case_Trigger
 * Object         : Case
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-08-16
 * Modify History : 
 **************************************************************************************************/
trigger Case_Trigger on Case (before update,before delete,after update,before insert,after insert) {
    if(Untils.isTriggerEnabled() && Constants.CA_TRIGGER_ON) {
        Triggers triggersObj = new Triggers();
        if(Context.ApplyTo(Constants.CN_Code) && Constants.CN_CA_TRIGGER_ON) {
            triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Case_Upsert_To_Mg_Handler());
            
            if(Constants.CN_CA_CREATOR_TO_OWNER_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Complaint_Populate_Status_Handler());
            }
            if(Constants.CN_CA_PREVENT_DELETE_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeDelete, new CN_Complaint_Prevent_Delete_Handler());
            }
            if(Constants.CN_CA_SHARE_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Case_Share_Handler());
            }
            //add by  Zhang Zhihao 2023.11.7 Insertion assignment
            if(Constants.CN_CA_CHECK_fIELD_INSERT_HANDLER_TRIGGER_ON) {
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Complaint_Check_Field_Insert_Handler());
            }
             //add by  Zhang Zhihao 2023.11.7 Insertion assignment
              //add by  Zhang Zhihao 2024.1.14 Submitter assignment
            if(Constants.CN_CA_SUBMITTER_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.BeforeUpdate, new CN_Complaint_Submitter_Handler());
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Complaint_Submitter_Handler());
            }
            //add by  Zhang Zhihao 2024.1.14 Submitter assignment

            //add by  Zhang Zhihao 2024.1.14 Message notifications sent to sales
            if(Constants.CN_CA_STATUS_CHANGE_NOTIFICATION_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.AfterUpdate, new CN_Complaint_Status_Change_Notify());
                triggersObj.bind(Triggers.Evt.AfterInsert, new CN_Complaint_Status_Change_Notify());
            }
            //add by  Zhang Zhihao 2024.1.14 Message notifications sent to sales

            //add by He Peng 2024.1.24  insert Offline owner => CS Queue
            if(Constants.CN_CA_Offline_TRIGGER_ON){
                triggersObj.bind(Triggers.Evt.BeforeInsert, new CN_Complaint_Offline_Handler());
            }

        }
        triggersObj.execute(); 
    }
}
/**************************************************************************************************
 * Name           : CN_Lead_MKT_Assigned_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-22
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Lead_MKT_Assigned_Handler implements Triggers.Handler{
    public void handle() {
		if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
        //Zhang Zhihao adds lead insert trigger 2023.11.14 start
        if(Trigger.isBefore && Trigger.isInsert){
            handleBeforeInsert();
        }
         //Zhang Zhihao adds lead insert trigger 2023.11.14 end
    }
    public void handleBeforeUpdate() {
        CN_MG_Customer_Settings__c customerSetting =  CN_MG_Customer_Settings__c.getInstance();
        String salesMdmId  = customerSetting.CN_Sales_MDM_Id__c;
        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        for(Lead lead: (List<Lead>)Trigger.new) {
            Lead oldLead = (Lead)Trigger.oldMap.get(lead.Id);
            if(lead.Status != oldLead.Status && Constants.CN_LEAD_STATUS_MKT_QUALIFIED.equals(lead.Status)) {
                lead.OwnerId = settings.CN_Sales_MDM_UserId__c;
            }
             //Zhang Zhihao modifies the lead status according to the lead sales owner 2023.11.14 start
            else if(Constants.CN_LEAD_SOURCE_ECOMMERCE.equals(lead.LeadSource)&&(lead.ownerId!=oldLead.ownerId)){
                if(salesMdmId!=null&&salesMdmId.equals(lead.ownerId)) {
                      //Zhang Zhihao modifies the lead status  2023.11.26 start
                    lead.Status = Constants.CN_LEAD_STATUS_MKT_QUALIFIED;
                } else {
                     //Zhang Zhihao modifies the lead status  2023.11.26 start
                    if(salesMdmId!=null&&oldLead.ownerId!=salesMdmId){
                        lead.Status = Constants.CN_LEAD_STATUS_ASSIGNED;
                    }
                }
            }
        }
    }

 //Zhang Zhihao modifies the lead status according to the lead sales owner 2023.11.14 start
    public void handleBeforeInsert(){
        CN_MG_Customer_Settings__c customerSetting =  CN_MG_Customer_Settings__c.getInstance();
        String salesMdmId  = customerSetting.CN_Sales_MDM_Id__c;
        List<Lead> newLeads = Trigger.new;
        for(Lead lead : newLeads) {
            if(Constants.CN_LEAD_SOURCE_ECOMMERCE.equals(lead.LeadSource)) {
            //Zhang Zhihao modifies the lead status according to the lead sales owner 2023.11.26 start
                if(salesMdmId!=null&&salesMdmId.equals(lead.ownerId)) {
                    
                    lead.Status = Constants.CN_LEAD_STATUS_MKT_QUALIFIED;
                } else {
                    lead.Status = Constants.CN_LEAD_STATUS_ASSIGNED;
                }
              //Zhang Zhihao modifies the lead status according to the lead sales owner 2023.11.26 start   
            }
        }

    }
 //Zhang Zhihao modifies the lead status according to the lead sales owner 2023.11.14 end
 


}
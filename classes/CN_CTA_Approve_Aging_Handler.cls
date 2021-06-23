/**************************************************************************************************
 * Name           : CN_CTA_Approve_Aging_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-13
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CTA_Approve_Aging_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.IsUpdate) {
            handleBeforeUpdate();
        }
    }
    
    public void handleBeforeUpdate() {
        Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();
        List<CN_Credit_Term_Application__c> ctaList = new List<CN_Credit_Term_Application__c>();
        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New) {          
            if(Constants.CN_CTA_STATUS_SUBMITTED_FOR_APPROVAL.equals(cta.CN_Status__c) && String.isNotBlank(cta.CN_Approve_Step__c) && cta.CN_Approve_Step__c <> ((CN_Credit_Term_Application__c)Trigger.oldMap.get(cta.Id)).CN_Approve_Step__c ){
                ctaList.add(cta);
            }
        }
        if(ctaList.size() > 0){
            updateTriggerTimeAndApprover(ctaList);
        }        
    }
    
    public void updateTriggerTimeAndApprover(List<CN_Credit_Term_Application__c> ctaList){
        for(CN_Credit_Term_Application__c cta : ctaList){
            Integer hours = NUll;
            
            Map<String,Id> ApproveStepStringApproverIdMap = new Map<String,Id>();
            ApproveStepStringApproverIdMap.put('step1',cta.CN_Approver_1__c);
            ApproveStepStringApproverIdMap.put('step2',cta.CN_Approver_2__c);
            ApproveStepStringApproverIdMap.put('step3',cta.CN_Approver_3__c);
            Integer str_Approve_Step_num = Integer.valueOf(cta.CN_Approve_Step__c.Right(1));
            for(Integer n=str_Approve_Step_num;n<=3;n++){
                if(String.isNotBlank(ApproveStepStringApproverIdMap.get('step'+n))){
                    cta.CN_Current_Approver__c = ApproveStepStringApproverIdMap.get('step'+ n);
                    cta.CN_Approve_Step__c = 'step'+n;
                    break;
                }else if(n==3){
                    return;
                }
            }
            
            List<CN_Approval_Aging_Setting__mdt> approvalAgingSettings =  CN_Approval_Aging_Setting__mdt.getAll().values();
            for(CN_Approval_Aging_Setting__mdt approvalAgingSetting : approvalAgingSettings){
                if(approvalAgingSetting.CN_Approval_Aging_Setting_Step__c == cta.CN_Approve_Step__c && approvalAgingSetting.CN_Approval_Aging_Setting_Object__c == 'CN_Credit_Term_Application__c'){
                    hours = (Integer)approvalAgingSetting.CN_Approval_Aging_Setting_Hours__c;
                    break;
                }
            }
            
            if(hours <> null){
                cta.CN_Approve_Aging_Trigger_Datetime__c = Untils.calculateBusinessTime(DateTime.now(),hours,Constants.CN_BUSINESS_HOURS_NAME);
            }else{
                cta.AddError(system.Label.CN_CTA_CustomLabel_Hour_Is_NULL);
            }
        }
    }
}
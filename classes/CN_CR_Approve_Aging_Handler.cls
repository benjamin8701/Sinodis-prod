/**************************************************************************************************
 * Name           : CN_CR_Approve_Aging_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-19
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Approve_Aging_Handler implements Triggers.Handler {
    Set<Id> cnRTIdSet = new Set<Id>();
    Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
    Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
    Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
    Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
    Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();

    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    public void handleBeforeUpdate() {
        cnRTIdSet.add(updateAccountRTId);
        cnRTIdSet.add(updateContactRTId);
        cnRTIdSet.add(updateShiptoRTId);
        cnRTIdSet.add(newContactRTId);
        cnRTIdSet.add(newShiptoRTId);
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c changeRequest : (List<CN_Change_Request__c>)Trigger.new){
            if(Constants.CN_CR_STATUS_SUBMITTED_FOR_APPROVAL.equals(changeRequest.CN_Change_Request_Status__c) && cnRTIdSet.contains(changeRequest.recordTypeId)){
                crList.add(changeRequest);
            }
        }
        if(crList.size()>0){
            updateTriggerTimeAndApprover(crList);
        }
    }

    public void updateTriggerTimeAndApprover(List<CN_Change_Request__c> crList){
        for(CN_Change_Request__c cr : crList){
            Integer hours = NUll;
            
            Map<String,Id> ApproveStepStringApproverIdMap = new Map<String,Id>();
            ApproveStepStringApproverIdMap.put('step1',cr.CN_Approver_1__c);
            ApproveStepStringApproverIdMap.put('step2',cr.CN_Approver_2__c);
            ApproveStepStringApproverIdMap.put('step3',cr.CN_Approver_3__c);
            ApproveStepStringApproverIdMap.put('step4',cr.CN_Approver_4__c);

            if(cr.CN_Approve_Step__c == NULL){
                return;
            }
            Integer str_Approve_Step_num = Integer.valueOf(cr.CN_Approve_Step__c.Right(1));
            for(Integer n=str_Approve_Step_num;n<=4;n++){
                if(String.isNotBlank(ApproveStepStringApproverIdMap.get('step'+n))){
                    cr.CN_Current_Approver__c = ApproveStepStringApproverIdMap.get('step'+ n);
                    cr.CN_Approve_Step__c = 'step'+n;
                    break;
                }else if(n==4){
                    return;
                }
            }
            
            List<CN_Approval_Aging_Setting__mdt> approvalAgingSettings =  CN_Approval_Aging_Setting__mdt.getAll().values();
            for(CN_Approval_Aging_Setting__mdt approvalAgingSetting : approvalAgingSettings){
                if(approvalAgingSetting.CN_Approval_Aging_Setting_Step__c == cr.CN_Approve_Step__c && approvalAgingSetting.CN_Approval_Aging_Setting_Object__c == 'CN_Change_Request__c'){
                	hours = (Integer)approvalAgingSetting.CN_Approval_Aging_Setting_Hours__c;
                    break;
                }
            }
            
            if(hours <> null){
                cr.CN_Approve_Aging_Trigger_Datetime__c = Untils.calculateBusinessTime(DateTime.now(),hours,Constants.CN_BUSINESS_HOURS_NAME);
            }else{
                cr.AddError(system.Label.CN_CR_CustomLabel_Hour_Is_NULL);
            }
        }
    }
}
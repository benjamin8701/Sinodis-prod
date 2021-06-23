/**************************************************************************************************
 * Name           : CN_Account_Approve_Aging_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-05-07
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Approve_Aging_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.IsUpdate) {
            handleBeforeUpdate();
        }
    }
    
    public void handleBeforeUpdate() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId();
        List<Account> accList = new List<Account>();
        for(Account acc : (List<Account>)Trigger.New) {          
            if(acc.recordTypeId == accRTId && Constants.CN_ACCOUNT_ACCOUNT_STATUS_SUBMITTED_FOR_APPROVAL.equals(acc.CN_Account_Status__c) && String.isNotBlank(acc.CN_Approve_Step__c) && acc.CN_Approve_Step__c <> ((Account)Trigger.oldMap.get(acc.Id)).CN_Approve_Step__c ){
                accList.add(acc);
            }
        }
        if(acclist.size() > 0){
            updateTriggerTimeAndApprover(accList);
        }        
    }
    
    public void updateTriggerTimeAndApprover(List<Account> accList){
        for(Account acc : accList){
            Integer hours = NUll;
            
            Map<String,Id> ApproveStepStringApproverIdMap = new Map<String,Id>();
            ApproveStepStringApproverIdMap.put('step1',acc.CN_Approver_1__c);
            ApproveStepStringApproverIdMap.put('step2',acc.CN_Approver_2__c);
            ApproveStepStringApproverIdMap.put('step3',acc.CN_Approver_3__c);
            ApproveStepStringApproverIdMap.put('step4',acc.CN_Approver_4__c);
            ApproveStepStringApproverIdMap.put('step5',acc.CN_Approver_5__c);

            Integer str_Approve_Step_num = Integer.valueOf(acc.CN_Approve_Step__c.Right(1));
            for(Integer n=str_Approve_Step_num;n<=5;n++){
                if(String.isNotBlank(ApproveStepStringApproverIdMap.get('step'+n))){
                    acc.CN_Current_Approver__c = ApproveStepStringApproverIdMap.get('step'+ n);
                    acc.CN_Approve_Step__c = 'step'+n;
                    break;
                }else if(n==5){
                    return;
                }
            }
            
            List<CN_Approval_Aging_Setting__mdt> approvalAgingSettings =  CN_Approval_Aging_Setting__mdt.getAll().values();
            for(CN_Approval_Aging_Setting__mdt approvalAgingSetting : approvalAgingSettings){
                if(approvalAgingSetting.CN_Approval_Aging_Setting_Step__c == acc.CN_Approve_Step__c && 'Account'.equals(approvalAgingSetting.CN_Approval_Aging_Setting_Object__c)){
                	hours = (Integer)approvalAgingSetting.CN_Approval_Aging_Setting_Hours__c;
                    break;
                }
            }
            
            if(hours <> null){
                acc.CN_Approve_Aging_Trigger_Datetime__c = Untils.calculateBusinessTime(DateTime.now(),hours,Constants.CN_BUSINESS_HOURS_NAME);
            }else{
                acc.AddError(system.Label.CN_Account_CustomLabel_Hour_Is_NULL);
            }
        }
    }
}
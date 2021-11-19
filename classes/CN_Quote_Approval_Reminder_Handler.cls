/**************************************************************************************************
 * Name           : CN_Quote_Approval_Reminder_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wan Houchen
 * Create Date    : 2021-10-27
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Approval_Reminder_Handler implements Triggers.Handler{
    
    public void handle() {
        for(Quote qu:(List<Quote>) trigger.new){
            Quote oldQu = (Quote) trigger.oldMap.get(qu.Id);
            if(qu.CN_Approve_Step__c != oldQu.CN_Approve_Step__c && String.isNotBlank(qu.CN_Approve_Step__c)){
                
                qu.CN_Approval_Reminder_Datetime__c = Untils.calculateBusinessTime(DateTime.now(),Constants.CN_QUOTE_APPROVAL_REMINDER_HOURS,Constants.CN_BUSINESS_HOURS_NAME);
                system.debug('CN_Approve_Step__c==>'+qu.CN_Approve_Step__c);
                Integer stepNum = Integer.valueOf(qu.CN_Approve_Step__c.Right(1));
                system.debug('stepNum==>'+stepNum);
                String nextApproverId;
                qu.CN_Current_Approver__c = null;
                do{
                    nextApproverId = String.valueof(qu.get('CN_Approver_'+stepNum+'__c'));
                    qu.CN_Current_Approver__c = nextApproverId;
                    if(String.isNotBlank(nextApproverId)) {
                        qu.CN_Latest_Approver__c = nextApproverId;
                    }
                    qu.CN_Approve_Step__c = 'Step'+stepNum;
                    stepNum ++;                    
                }while(String.isBlank(nextApproverId) && stepNum<10);
                system.debug('step==>'+qu.CN_Approve_Step__c);

            }
        }
    }
}
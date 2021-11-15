/**************************************************************************************************
* Name           : CN_Quote_Finance_Notice_LC_Ctrl
* Object         : 
* Requirement    : 
* Target         : 
* Refer classes  :
* Author         : Wan Houchen
* Create Date    : 2021-10-29
* Modify History : 
**************************************************************************************************/
public without sharing class CN_Quote_Finance_Notice_LC_Ctrl {
    
    @AuraEnabled
    public static void sendNotifyEmail(String QuoteId){
        system.debug('QuoteId==>'+QuoteId);
        try {
            CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();            
            String recipientId = settings.CN_Finance_MDM_UserId__c;
            Quote qu = [Select Id,CN_Finance_Notify_DateTime__c,Opportunity.Account.CN_Customer_Code__c,Opportunity.Account.CN_Sales_Team_UI__r.Name,Opportunity.Account.Name From Quote Where Id = :QuoteId];
            system.debug('quote==>'+qu);
            EmailTemplate template = [Select Id, DeveloperName from EmailTemplate Where DeveloperName = 'CN_Quote_Notify_Finance' limit 1];
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.Id,recipientId,QuoteId);
            String CNsubject = '请在SAP中维护SKU报价 for - '+ qu.Opportunity.Account.CN_Customer_Code__c +' – '+ qu.Opportunity.Account.CN_Sales_Team_UI__r.Name +' - '+ qu.Opportunity.Account.Name;
            String ENsubject = 'Please Maintain SKU Quote Price in SAP for customer - '+ qu.Opportunity.Account.CN_Customer_Code__c +' – '+ qu.Opportunity.Account.CN_Sales_Team_UI__r.Name +' - '+ qu.Opportunity.Account.Name;
            system.debug('CNsubject==>'+CNsubject);
            email.setSubject(CNsubject+'/'+ENsubject);
            email.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            qu.CN_Finance_Notify_DateTime__c = system.now();
            update qu;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
/**************************************************************************************************
 * Name           : CN_CTA_Populate_FinanceMDM_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-06-09
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CTA_Populate_FinanceMDM_Handler implements Triggers.Handler{
    Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();
	public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    
    public void handleBeforeInsert() {
        List<CN_Credit_Term_Application__c> CTAList = new List<CN_Credit_Term_Application__c>();
        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New) {
            if(cta.RecordTypeId == ctaRTId) {
                CTAList.add(cta);
            }
        }
        if(CTAList.size() > 0) {
            populateFinanceMDM(CTAList);
        }
    }

    public void handleBeforeUpdate() {
        List<CN_Credit_Term_Application__c> CTAList = new List<CN_Credit_Term_Application__c>();
        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.New) {
            if(cta.RecordTypeId == ctaRTId) {
                CTAList.add(cta);
            }
        }
        if(CTAList.size() > 0) {
            populateFinanceMDM(CTAList);
        }
    }

    public void populateFinanceMDM(List<CN_Credit_Term_Application__c> CTAList) {
        for(CN_Credit_Term_Application__c cta : CTAList){
            cta.CN_Finance_MDM__c = CN_Approve_Process_Settings__c.getInstance().CN_Finance_MDM_UserId__c;
        }
    }

}
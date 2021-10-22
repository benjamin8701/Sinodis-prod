/**************************************************************************************************
 * Name           : CN_Opportunity_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-23
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Opportunity_Populate_Fields_Handler implements Triggers.Handler{
    Set<Id> CN_RTIds = new Set<Id>();
    
    public void handle() {
        CN_RTIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.CN_OP_RT_API_NAME_NEW).getRecordTypeId());
        
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
    }
    
    public void handleBeforeInsert() {
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : (List<Opportunity>)Trigger.New){
            if(CN_RTIds.contains(opp.recordTypeID) && opp.CN_Generate_From_Lead_Id__c != null){
                opp.CloseDate = System.Today().addDays(90);
            }
        }
    }
}
/**************************************************************************************************
* Name           : CN_CST_Populate_Owner_Batch
* Object         : 
* Requirement    : 
* Target         : 
* Refer classes  :
* Author         : Du Dezheng
* Create Date    : 2021-10-11
* Modify History : 
**************************************************************************************************/
global class CN_CST_Populate_Owner_Batch implements Database.Batchable<SObject>,Database.Stateful{
    
    global String queryString = '';
    
    public CN_CST_Populate_Owner_Batch() {
        queryString='Select Id,OwnerId,CN_Customer_Owner__c From CN_Customer_Status_Trend__c Where CN_Is_Populated_Owner__c = FALSE';
    }
    
    global Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(queryString);
	}

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Savepoint sp = Database.setSavePoint();
        List<CN_Customer_Status_Trend__c> scopeList = (List<CN_Customer_Status_Trend__c>)scope;
        List<CN_Customer_Status_Trend__c> cstList_update = new List<CN_Customer_Status_Trend__c>();
		try{
            for(CN_Customer_Status_Trend__c cst : scopeList){
                CN_Customer_Status_Trend__c cst_update = new CN_Customer_Status_Trend__c(
                	Id = cst.Id,
                    OwnerId = cst.CN_Customer_Owner__c
                );
                cstList_update.add(cst_update);
            }
            System.debug('cstList_update:        ' + cstList_update);
            if (cstList_update.size() > 0) {
                update cstList_update;
            }				
		} catch (Exception e) {
			Database.rollback(sp);
			throw e;
		} finally {

		}
	}

	global void finish(Database.BatchableContext BC) {

	}
    
    
}
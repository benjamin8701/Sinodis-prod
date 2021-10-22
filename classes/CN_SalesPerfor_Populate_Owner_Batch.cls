/**************************************************************************************************
 * Name           : CN_SalesPerfor_Populate_Owner_Batch
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-09-08
 * Modify History : 
 **************************************************************************************************/
global class CN_SalesPerfor_Populate_Owner_Batch implements Database.Batchable<SObject>,Database.Stateful{
	global String queryString = '';
    List<CN_Sales_Performance__c> perList = new List<CN_Sales_Performance__c>();

    public CN_SalesPerfor_Populate_Owner_Batch() {
        queryString='Select Id,CN_Is_Customer_Owner_Changed__c,CN_Customer_Owner__c From CN_Sales_Performance__c Where CN_Is_Customer_Owner_Changed__c = true';
    }

    global Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(queryString);
	}

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Savepoint sp = Database.setSavePoint();

        List<CN_Sales_Performance__c> scopeList = (List<CN_Sales_Performance__c>)scope;
        List<CN_Sales_Performance__c> perList_update = new List<CN_Sales_Performance__c>();

		try{
            for(CN_Sales_Performance__c per : scopeList){
                if( per.CN_Is_Customer_Owner_Changed__c==true){
                    perList_update.add(new CN_Sales_Performance__c(Id = per.Id,OwnerId = per.CN_Customer_Owner__c));
                }
            }
            if (perList_update.size() > 0) {
                Constants.CN_SALESPERFOR_TRIGGER_ON = false;
                update perList_update;
                Constants.CN_SALESPERFOR_TRIGGER_ON = true;
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
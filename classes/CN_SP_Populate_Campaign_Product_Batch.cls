/**************************************************************************************************
 * Name           : CN_SP_Populate_Campaign_Product_Batch
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-09-22
 * Modify History : 
 **************************************************************************************************/
global class CN_SP_Populate_Campaign_Product_Batch implements Database.Batchable<SObject>,Database.Stateful{

    global String queryString = '';
    List<CN_Campaign_Product__c> campProduct = new List<CN_Campaign_Product__c>();
    Map<Id,Id> productIdCampaignProductIdMap = new Map<Id,Id>();
    
    public CN_SP_Populate_Campaign_Product_Batch() {
        queryString = 
            'Select  Id,CN_Product__c From CN_Sample_Product__c Where CN_Is_Created_Yesterday__c = TRUE';
    }
    public CN_SP_Populate_Campaign_Product_Batch(String queryString) {
        this.queryString = queryString;
    }

    global Database.QueryLocator start(Database.BatchableContext ctx) {
        List<CN_Campaign_Product__c> cpList = [Select Id,CN_Product__c,CN_Campaign__c 
                                                From CN_Campaign_Product__c 
                                                Where CN_Campaign__r.CN_New_Product_Launch__c = TRUE And CN_Campaign__r.CN_Is_Within_6_Months__c = TRUE
                                                ORDER BY CN_Campaign__r.StartDate ];
        for(CN_Campaign_Product__c cp : cpList){
            productIdCampaignProductIdMap.put(cp.CN_Product__c,cp.Id);
        }
        Set<Id> productIdSet = productIdCampaignProductIdMap.keySet();
		return Database.getQueryLocator(queryString + ' AND CN_Product__c IN :productIdSet');
	}

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Savepoint sp = Database.setSavePoint();
        List<CN_Sample_Product__c> scopeList = (List<CN_Sample_Product__c>)scope;
        List<CN_Sample_Product__c> spList_update = new List<CN_Sample_Product__c>();
		try{
            for(CN_Sample_Product__c sproduct : scopeList){
                if(productIdCampaignProductIdMap.containsKey(sproduct.CN_Product__c)){
                    CN_Sample_Product__c sproduct_update = new CN_Sample_Product__c();
                    sproduct_update.Id = sproduct.Id;
                    sproduct_update.CN_Campaign_Product__c = productIdCampaignProductIdMap.get(sproduct.CN_Product__c);
                    spList_update.add(sproduct_update);
                }
            }
            if (spList_update.size() > 0) {
                Constants.CN_SAMPLE_PRODUCT_TRIGGER_ON = false;
                update spList_update;
                Constants.CN_SAMPLE_PRODUCT_TRIGGER_ON = true;
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
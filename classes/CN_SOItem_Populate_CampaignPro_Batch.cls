/**************************************************************************************************
 * Name           : CN_SOItem_Populate_CampaignPro_Batch
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-09-22
 * Modify History : 
 **************************************************************************************************/
global class CN_SOItem_Populate_CampaignPro_Batch implements Database.Batchable<SObject>,Database.Stateful{

    global String queryString = '';
    List<CN_Campaign_Product__c> campProduct = new List<CN_Campaign_Product__c>();
    Map<Id,Id> productIdCampaignProductIdMap = new Map<Id,Id>();
    
    public CN_SOItem_Populate_CampaignPro_Batch() {
        queryString = 
            'Select  Id,CN_Material_Number__c From CN_Sales_Order_Item__c Where CN_Is_Created_Yesterday__c = TRUE';
    }
    public CN_SOItem_Populate_CampaignPro_Batch(String queryString) {
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
		return Database.getQueryLocator(queryString + ' AND CN_Material_Number__c IN :productIdSet');
	}

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Savepoint sp = Database.setSavePoint();
        List<CN_Sales_Order_Item__c> scopeList = (List<CN_Sales_Order_Item__c>)scope;
        List<CN_Sales_Order_Item__c> soiList_update = new List<CN_Sales_Order_Item__c>();
		try{
            for(CN_Sales_Order_Item__c soi : scopeList){
                if(productIdCampaignProductIdMap.containsKey(soi.CN_Material_Number__c)){
                    CN_Sales_Order_Item__c soi_update = new CN_Sales_Order_Item__c();
                    soi_update.Id = soi.Id;
                    soi_update.CN_Campaign_Product__c = productIdCampaignProductIdMap.get(soi.CN_Material_Number__c);
                    soiList_update.add(soi_update);
                }
            }
            if (soiList_update.size() > 0) {
                update soiList_update;
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
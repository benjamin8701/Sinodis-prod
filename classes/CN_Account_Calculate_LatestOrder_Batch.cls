/**************************************************************************************************
 * Name           : CN_Account_Calculate_LatestOrder_Batch
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-27
 * Modify History : 
 **************************************************************************************************/
global class CN_Account_Calculate_LatestOrder_Batch implements Database.Batchable<SObject>,Database.Stateful{

    global String queryString = '';
    global Set<Id> accIdSet = new Set<Id>();
    
    public CN_Account_Calculate_LatestOrder_Batch() {
        queryString='Select CN_Sold_To_Account_Name__c, CN_SAP_Create_Date__c,CN_Sold_To_Account_Name__r.CN_Latest_Order_Create_Date__c from CN_Sales_Order__c Where CN_Is_Within_6_Months__c = TRUE Order BY CN_SAP_Create_Date__c DESC';
    }

    global Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(queryString);
	}

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Savepoint sp = Database.setSavePoint();
        List<CN_Sales_Order__c> scopeList = (List<CN_Sales_Order__c>)scope;
        List<Account> accList = new List<Account>();
		try{
            for(CN_Sales_Order__c order : scopeList){
                if(!accIdSet.contains(order.CN_Sold_To_Account_Name__c) && (order.CN_Sold_To_Account_Name__r.CN_Latest_Order_Create_Date__c==null || order.CN_SAP_Create_Date__c>order.CN_Sold_To_Account_Name__r.CN_Latest_Order_Create_Date__c)){
                    accList.add(new Account(Id = order.CN_Sold_To_Account_Name__c,CN_Latest_Order_Create_Date__c = order.CN_SAP_Create_Date__c));
                    accIdSet.add(order.CN_Sold_To_Account_Name__c);
                }
            }
            if (accList.size() > 0) {
                Constants.CN_ACCOUNT_TRIGGER_ON = false;
                update accList;
                Constants.CN_ACCOUNT_TRIGGER_ON = true;
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
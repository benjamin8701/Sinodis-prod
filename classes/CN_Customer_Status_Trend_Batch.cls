/**************************************************************************************************
 * Name           : CN_Customer_Status_Trend_Batch
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-11-15
 * Modify History : 
 **************************************************************************************************/
global class CN_Customer_Status_Trend_Batch implements Database.Batchable<SObject> {

    global String queryString = '';

    public CN_Customer_Status_Trend_Batch() {
        this.queryString = 'SELECT Id, Name, CN_Customer_Status__c, CN_Category__c, CN_Subcategory__c, CN_Sales_Person_Name__c, CN_License_Name_EN__c, Owner.Name, OwnerId FROM Account';
    }

    public CN_Customer_Status_Trend_Batch(String queryString) {
        this.queryString = queryString;
    }

    global Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(queryString);
	}

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Savepoint sp = Database.setSavePoint();
        List<Account> scopeList = (List<Account>)scope;
        List<CN_Customer_Status_Trend__c> cstList = new List<CN_Customer_Status_Trend__c>();
		try{
            for(Account acc : scopeList){
                CN_Customer_Status_Trend__c cst = new CN_Customer_Status_Trend__c();
                cst.CN_Category__c = acc.CN_Category__c;
                cst.CN_Customer_Owner__c = acc.OwnerId;
                cst.CN_Customer_Status__c = acc.CN_Customer_Status__c;
                cst.CN_Execution_Time__c = Date.today();
                cst.CN_License_Name_CN__c = acc.Name;
                cst.CN_License_Name_EN__c = acc.CN_License_Name_EN__c;
                cst.CN_Subcategory__c = acc.CN_Subcategory__c;
                cstList.add(cst);
            }
            if (cstList.size() > 0) {
                insert cstList;
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
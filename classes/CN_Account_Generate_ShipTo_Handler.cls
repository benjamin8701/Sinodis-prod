/**************************************************************************************************
 * Name           : CN_Account_Generate_Shipto_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-04-30
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Generate_ShipTo_Handler implements Triggers.Handler{
	public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
    }
    
    public void handleAfterInsert() {
        Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
        List<Account> directAccList = new List<Account>();
        for(Account acc : (List<Account>)Trigger.New) {
            if(acc.RecordTypeId == newDirectRTId) {
                directAccList.add(acc);
            }
        }
        if(directAccList.size() > 0) {
            List<CN_Ship_to_Party__c> shipToList = new List<CN_Ship_to_Party__c>();
            shipToList = generateShipTos(directAccList);
            if(shipToList.size() > 0) {
				insert shipToList;
            }
        }
    }
    
    public List<CN_Ship_to_Party__c> generateShipTos(List<Account> accList) {
        List<CN_Ship_to_Party__c> shipToList = new List<CN_Ship_to_Party__c>();
        for(Account acc : accList) {
             CN_Ship_to_Party__c shipTo = new CN_Ship_to_Party__c(
                 CN_Sold_To_Party_Customer__c = acc.Id,
                 CN_Customer_Type__c = '0002',
                 CN_Delivery_Address_CN__c = acc.CN_Invoicing_Address_and_Phone__c,
                 CN_Delivery_Plant__c = acc.CN_Delivery_Plant__c,
                 CN_Province_CN__c = acc.CN_Province_CN__c,
                 CN_City_CN__c = acc.CN_City_CN__c,
                 CN_Delivery_Address_EN__c = acc.CN_Invoicing_Address_EN__c
             );
            shipToList.add(shipTo);
        }
        return shipToList;
    }
}
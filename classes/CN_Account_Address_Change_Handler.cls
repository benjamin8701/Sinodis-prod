/**************************************************************************************************
 * Name           : CN_Account_Address_Change_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Wan Houchen
 * Create Date    : 2021-08-03
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Address_Change_Handler implements Triggers.Handler {
	
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert){
            for(Account acc : (List<Account>)Trigger.New) {
                if(String.isNotBlank(acc.CN_Visit_Addr_CN__c)){
                    acc.CN_Need_Sync_Geolocation__c = true;
                }
            }
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            for(Account acc : (List<Account>)Trigger.New) {
                Account oldacc = (Account)Trigger.oldmap.get(acc.Id);
                if(String.isNotBlank(acc.CN_Visit_Addr_CN__c) && acc.CN_Visit_Addr_CN__c != oldacc.CN_Visit_Addr_CN__c){
                    acc.CN_Need_Sync_Geolocation__c = true;
                }
            }
        }
    }
    
    
}
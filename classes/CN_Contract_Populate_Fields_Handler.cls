/**************************************************************************************************
 * Name           : CN_Contract_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Contract_Populate_Fields_Handler implements Triggers.Handler{
    Set<Id> CN_RTIds = new Set<Id>();
    
    public void handle() {
        CN_RTIds.add(Schema.SObjectType.CN_Contract__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTRACT_RT_API_NAME_NEW).getRecordTypeId());
        
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
    }
    
    public void handleBeforeInsert() {
        List<CN_Contract__c> conList = new List<CN_Contract__c>();
        for(CN_Contract__c con : (List<CN_Contract__c>)Trigger.New){
            if(CN_RTIds.contains(con.RecordTypeId)) {
                conList.add(con);
            }
        }
        updateContractNumber(conList);
        populateContractSalesPeople(conList);
    }
    
    public void updateContractNumber(List<CN_Contract__c> conList) {
        List<CN_Contract_Number_Setting__c> settingList = [SELECT Id,CN_Contract_Number__c,CN_DateTime__c FROM CN_Contract_Number_Setting__c];
        CN_Contract_Number_Setting__c setting = settingList[0];
        Integer year_setting = setting.CN_DateTime__c.year();

        DateTime todayDateTime = DateTime.now();
        Integer year_today = todayDateTime.year();

        String str_todayDate = todayDateTime.format('YYYY');

        for(CN_Contract__c con : conList){
            if(year_setting==year_today){
                Integer num = Integer.valueOf(++setting.CN_Contract_Number__c);
                String text = String.valueOf(num);
                while (text.length() < 6)  { 
                    text = '0' + text; 
                }
                con.CN_Contract_Number__c = str_todayDate + text;
            }else{
                setting.CN_Contract_Number__c = 0;
                setting.CN_DateTime__c = todayDateTime;
                Integer num = Integer.valueOf(++setting.CN_Contract_Number__c);
                String text = String.valueOf(num);
                while (text.length() < 6)  { 
                    text = '0' + text;
                }
                con.CN_Contract_Number__c = str_todayDate + text;
            }
        }
        update setting;
    }

    public void populateContractSalesPeople(List<CN_Contract__c> conList){
        for(CN_Contract__c contract : conList){
            contract.CN_Sales_People__c = UserInfo.getUserId();
        }
    }
}
/**************************************************************************************************
 * Name           : CN_Demo_Used_Product_Accumulate_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Demo_Used_Product_Accumulate_Handler implements Triggers.Handler{

    public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }

    public void handleAfterInsert() {

        Set<Id> demoReportIdSet = new Set<Id>();
        for(CN_Demo_Used_Product__c dup: (List<CN_Demo_Used_Product__c>)Trigger.new) {
            demoReportIdSet.add(dup.CN_Demo_Report__c);
        }
        if(demoReportIdSet.size() > 0) {
            List<CN_Demo_Report__c> demoReportList = generateDemoReportListForUpdate(demoReportIdSet);
            if(demoReportList.size() > 0) {
                update demoReportList;
            }
        }
    }

    public void handleAfterUpdate() {
        Set<Id> demoReportIdSet = new Set<Id>();
        for(CN_Demo_Used_Product__c dup: (List<CN_Demo_Used_Product__c>)Trigger.new) {
            CN_Demo_Used_Product__c oldDup = (CN_Demo_Used_Product__c)Trigger.oldMap.get(dup.Id);
            if(oldDup.CN_Product__c != dup.CN_Product__c) {
                demoReportIdSet.add(dup.CN_Demo_Report__c);
            }
        }
        if(demoReportIdSet.size() > 0) {
            List<CN_Demo_Report__c> demoReportList = generateDemoReportListForUpdate(demoReportIdSet);
            if(demoReportList.size() > 0) {
                update demoReportList;
            }
        }
    }

    public List<CN_Demo_Report__c> generateDemoReportListForUpdate(Set<Id> demoReportIdSet) {

        List<CN_Demo_Report__c> demoReportList = new List<CN_Demo_Report__c>();

        if(demoReportIdSet.size() > 0) {
            List<CN_Demo_Used_Product__c> dupList = [SELECT Id, CN_Product__r.Name, CN_Demo_Report__c FROM CN_Demo_Used_Product__c WHERE CN_Demo_Report__c in: demoReportIdSet];
            
            Map<Id, Set<String>> drIdSKUNameMap = new Map<Id, Set<String>>();
            if(dupList.size() > 0) {
                for(CN_Demo_Used_Product__c dup: dupList) {
                    if(drIdSKUNameMap.containsKey(dup.CN_Demo_Report__c)) {
                        drIdSKUNameMap.get(dup.CN_Demo_Report__c).add(dup.CN_Product__r.Name);
                    } else {
                        drIdSKUNameMap.put(dup.CN_Demo_Report__c, new Set<String>{dup.CN_Product__r.Name});
                    }
                }
                if(drIdSKUNameMap.size() > 0) {
                    for(Id drId: drIdSKUNameMap.keySet()) {
                        CN_Demo_Report__c demoReport = new CN_Demo_Report__c();
                        demoReport.Id = drId;
                        demoReport.CN_Demo_Used_Products__c = String.join(new List<String>(drIdSKUNameMap.get(drId)), ';');
                        demoReportList.add(demoReport);
                    }
                }
            }
        }

        return demoReportList;
    }
}
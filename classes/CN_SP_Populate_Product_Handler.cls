/**************************************************************************************************
 * Name           : CN_SP_Populate_Product_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-09-08
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_SP_Populate_Product_Handler implements Triggers.Handler{

    Id SalesPerforRTId = Schema.SObjectType.CN_Sales_Performance__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SP_RT_API_NAME_PERFORMANCE).getRecordTypeId();
    
	public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    
    public void handleBeforeInsert() {
        Set<String> productCodeSet = new Set<String>();
        for(CN_Sales_Performance__c sp : (List<CN_Sales_Performance__c>)Trigger.NEW){
            if(sp.recordTypeId==SalesPerforRTId && String.isNotBlank(sp.CN_Material_SAP__c)){
                productCodeSet.add(sp.CN_Material_SAP__c);
            }
        }
        if(productCodeSet.size()>0){
            populateProduct(productCodeSet);
        }
    }
    
    public void handleBeforeUpdate() {
		Set<String> productCodeSet = new Set<String>();
        for(CN_Sales_Performance__c sp : (List<CN_Sales_Performance__c>)Trigger.NEW){
            if(sp.recordTypeId==SalesPerforRTId && sp.CN_Material_SAP__c != ((CN_Sales_Performance__c)Trigger.OldMap.get(sp.Id)).CN_Material_SAP__c){
                productCodeSet.add(sp.CN_Material_SAP__c);
            }
        }
        if(productCodeSet.size()>0){
            populateProduct(productCodeSet);
        }        
    }

    public void populateProduct(Set<String> productCodeSet){
        Map<String,Id> proCodeProIdMap = new Map<String,Id>();
        List<Product2> proList = [SELECT Id,CN_SKU_Code__c FROM Product2 WHERE CN_SKU_Code__c IN: productCodeSet];
        for(Product2 pro : proList){
            proCodeProIdMap.put(pro.CN_SKU_Code__c,pro.Id);
        }
        for(CN_Sales_Performance__c sp : (List<CN_Sales_Performance__c>)Trigger.New){
            if(sp.recordTypeId==SalesPerforRTId && String.isNotBlank(sp.CN_Material_SAP__c)){
                Id productId = proCodeProIdMap.get(sp.CN_Material_SAP__c);
                sp.CN_Product__c = productId;
            }else if(sp.recordTypeId==SalesPerforRTId){
                sp.CN_Product__c = null;
            }
        } 
    }
}
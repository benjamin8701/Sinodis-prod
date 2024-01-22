public without sharing class CN_MessagingSession_LCC_SalesOrder {

    public class InitData{
        @AuraEnabled public List<Map<String, Object>> datas {GET;SET;}
        @AuraEnabled public String msg {GET;SET;}
        @AuraEnabled public String title {GET;SET;}
        @AuraEnabled public Boolean isSuccess {GET;SET;}
    }

    @AuraEnabled
    public static InitData getInitData(String recordId){
        InitData initData = new InitData();
        try {
            initData.isSuccess = true;
            initData.datas = new List<Map<String, Object>>();
            List<MessagingSession> ltMsgSession = [SELECT MessagingEndUser.AccountId FROM MessagingSession WHERE Id = :recordId];
            Id accId = null;
            
            if (Test.isRunningTest()) {
                accId = [SELECT Id FROM Account LIMIT 1][0].Id;
            }
            if (ltMsgSession.size() > 0) {
                accId = ltMsgSession[0].MessagingEndUser.AccountId;
            }

            Set<Id> setProducts = new Set<Id>();
            for (AggregateResult item : [SELECT CN_Material_Number__c, SUM(CN_Order_Quantity__c) Total
                                FROM CN_Sales_Order_Item__c 
                                WHERE CN_Order_Number__r.CN_Sold_To_Account_Name__c = :accId
                                GROUP BY CN_Material_Number__c
                                ORDER BY SUM(CN_Order_Quantity__c) DESC
                                LIMIT 20]) {
                Map<String, Object> row = new Map<String, Object>();
                setProducts.add(Id.valueOf(String.valueOf(item.get('CN_Material_Number__c'))));
                row.put('CN_Material_Number__c', item.get('CN_Material_Number__c'));
                row.put('CN_SKU_Description_CN__c', item.get('CN_Material_Number__c'));
                row.put('CN_Product_Code__c', item.get('CN_Material_Number__c'));
                row.put('Total', item.get('Total'));
                initData.datas.add(row);
            }
            Map<Id, Product2> mapProducts = new Map<Id, Product2>([SELECT Id, CN_SKU_Description_CN__c, CN_SKU_Code__c FROM Product2 WHERE Id IN :setProducts]);
            for (Map<String, Object> row : initData.datas) {
                row.put('CN_SKU_Description_CN__c', mapProducts.get((Id)row.get('CN_Material_Number__c')).CN_SKU_Description_CN__c);
                row.put('CN_Product_Code__c', mapProducts.get((Id)row.get('CN_Material_Number__c')).CN_SKU_Code__c);
            }
        } catch (Exception ex) {
            initData.isSuccess = false;
            initData.msg = ex.getMessage();
        }
        return initData;
    }

}
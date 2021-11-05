global without sharing class CN_Sample_Product_Get_LC_Ctrl {
    global Id sampleRequestId {get; set;}
    global List<CN_Sample_Product__c> spList {get
        {
            List<CN_Sample_Product__c> spList = [SELECT Name,
                                                    CN_Sample_SKU_Code__c,
                                                    CN_SKU_Chinese_Description__c,
                                                    CN_SKU_English_Description__c,
                                                    CN_Qty_per_Carton__c,
                                                    CN_Unit__c,
                                                    CN_List_Price__c,
                                                    CN_Sample_Unit_List_Price__c,
                                                    CN_Quantity_Needed__c,
                                                    CN_Sample_Cost__c,
                                                    CN_Sample_Unit__c
                                             FROM CN_Sample_Product__c
                                             WHERE CN_Sample_Request__c = :sampleRequestId];
        return spList;
        } 
        set;
    }
}
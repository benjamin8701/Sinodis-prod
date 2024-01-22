/**************************************************************************************************
 * Name           : CN_PresetPrice_Effect_Batch
 * Object         : 
 * Requirement    : preset pricebook entry price,when the effective date is reached,the price effect.
 * Target         : Bacth to listen the preset pricebook entry every day in 1:00AM,
 *                  when there is any effective date is eraly than today,copy the price to pricebook entry.
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-12-20
 * Modify History : 1. 20230508 modify by dezheng.du, enforce preset price function to support preset price for new lanuach product
 **************************************************************************************************/
global class CN_PresetPrice_Effect_Batch implements Database.Batchable<SObject>,Database.Stateful{
    global String queryString = '';

    Map<String,Id> channelProductidStringPBEntryIdMap = new Map<String,Id>();
    Map<Id,Id> prePBEntryIdPBEntryIdMap = new Map<Id,Id>();
    
    public CN_PresetPrice_Effect_Batch() {
        queryString = 
            'Select Id,CN_Product__c,CN_Channel__c,CN_Discount_Price__c,CN_Is_Need_Effected__c,CN_Effective_Date__c,CN_Max_Discount_Price__c,CN_UnitPrice__c,CN_Product_Code__c,CN_Standard_List_Price__c'
            +' From CN_Preset_PriceBook_Entry__c Where CN_Is_Effected__c = FALSE AND CN_Is_Need_Effected__c = True' ;
    }
    public CN_PresetPrice_Effect_Batch(String queryString) {
        this.queryString = queryString;
    }

    global Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(queryString);
	}

    //modify by dezheng 20230413 ---- start
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Savepoint sp = Database.setSavePoint();
        List<CN_Preset_PriceBook_Entry__c> prePBEList = (List<CN_Preset_PriceBook_Entry__c>)scope;

        //Concatenate channel(WS、DS) and ProductId to be unique identification，to form one-to-one relationship between Preset PriceBook Entry and PriceBook Entry
        Set<Id> productIdSet = new Set<Id>();
        for(CN_Preset_PriceBook_Entry__c ppbe : prePBEList){
            productIdSet.add(ppbe.CN_Product__c);
        }

        List<PricebookEntry> pbEntryList = [Select Id,CN_Price_Book_Code__c,Product2Id,UnitPrice,CN_Max_Discount_Price__c,CN_Discount_Price__c ,Pricebook2Id
                                                FROM PricebookEntry 
                                                WHERE Product2ID IN :productIdSet];
        for(PricebookEntry pbe : pbEntryList){
            if(pbe.CN_Price_Book_Code__c!=null){
                String channelProductIDString_PBEntry = pbe.CN_Price_Book_Code__c + pbe.Product2Id;
                channelProductidStringPBEntryIdMap.put(channelProductIDString_PBEntry, pbe.Id);
            }
        }

        Id standardPricebookId = null;
        if(Test.isRunningTest()) {
            standardPricebookId = Test.getStandardPricebookId();
        }else{
            standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        }

        Map<String,String> channelStringPBIdMap = new Map<String,String>();
        CN_Price_Book_Setting__c pbSettings = CN_Price_Book_Setting__c.getInstance();
        channelStringPBIdMap.put(Constants.CN_PRESETPRICE_CHANNEL_LP,standardPricebookId);
        channelStringPBIdMap.put(Constants.CN_PRESETPRICE_CHANNEL_DS,pbSettings.CN_Price_Book1__c);
        channelStringPBIdMap.put(Constants.CN_PRESETPRICE_CHANNEL_KA,pbSettings.CN_Price_Book2__c);
        channelStringPBIdMap.put(Constants.CN_PRESETPRICE_CHANNEL_WS,pbSettings.CN_Price_Book3__c);
        channelStringPBIdMap.put(Constants.CN_PRESETPRICE_CHANNEL_QSR,pbSettings.CN_Price_Book4__c);
        channelStringPBIdMap.put(Constants.CN_PRESERPRICE_CHANNEL_B2B,pbSettings.CN_Price_Book5__c);


        List<PricebookEntry> priceBookEntryList_New_Channel = new List<PricebookEntry>();
        List<PricebookEntry> priceBookEntryList_New_Standard = new List<PricebookEntry>();
        List<PricebookEntry> priceBookEntryList_Update_Channel = new List<PricebookEntry>();
        List<PricebookEntry> priceBookEntryList_Update_Standard = new List<PricebookEntry>();
        List<Product2> productList = new List<Product2>();
        Set<Id> product2IdSet = new Set<Id>();

        List<CN_Preset_PriceBook_Entry__c> ppbe_updateList = new List<CN_Preset_PriceBook_Entry__c>();
        for(CN_Preset_PriceBook_Entry__c ppbe : prePBEList){
            //active products
            if(!product2IdSet.contains(ppbe.CN_Product__c)){
                product2IdSet.add(ppbe.CN_Product__c);
                productList.add(new Product2(Id = ppbe.CN_Product__c,Isactive = true,CN_Apex_Update_DateTime__c=DateTime.now()));
            }
            String channelProductIDString_PrePBEntry = ppbe.CN_Channel__c + ppbe.CN_Product__c;
            if(channelProductidStringPBEntryIdMap.keySet().contains(channelProductIDString_PrePBEntry)){
                priceBookEntry pbe_update = new priceBookEntry();
                pbe_update.Id = channelProductidStringPBEntryIdMap.get(channelProductIDString_PrePBEntry);
                pbe_update.IsActive = true;
                if(ppbe.CN_Channel__c!= Constants.CN_PRESETPRICE_CHANNEL_LP){
                    //without null judgement because fields are required on pagelayout
                    pbe_update.CN_Max_Discount_Price__c = ppbe.CN_Max_Discount_Price__c;
                    pbe_update.CN_Discount_Price__c = ppbe.CN_Discount_Price__c;
                    pbe_update.UnitPrice = ppbe.CN_UnitPrice__c;
                    priceBookEntryList_Update_Channel.add(pbe_update);
                }else{
                    pbe_update.UnitPrice = ppbe.CN_Standard_List_Price__c;
                    pbe_update.CN_Apex_Update_DateTime__c = DateTime.now();
                    priceBookEntryList_Update_Standard.add(pbe_update);
                }
            }else{
                priceBookEntry pbe_new = new priceBookEntry();
                pbe_new.Pricebook2Id = channelStringPBIdMap.get(ppbe.CN_Channel__c);
                pbe_new.Product2Id = ppbe.CN_Product__c;
                pbe_new.IsActive = true;
                pbe_new.CN_Price_Book_Entry_Code__c = ppbe.CN_Channel__c + ppbe.CN_Product_Code__c;
                if(ppbe.CN_Channel__c!= Constants.CN_PRESETPRICE_CHANNEL_LP){
                    pbe_new.CN_Max_Discount_Price__c = ppbe.CN_Max_Discount_Price__c;
                    pbe_new.CN_Discount_Price__c = ppbe.CN_Discount_Price__c;
                    pbe_new.UnitPrice = ppbe.CN_UnitPrice__c;
                    priceBookEntryList_New_Channel.add(pbe_new);
                }else{
                    pbe_new.UnitPrice = ppbe.CN_Standard_List_Price__c;
                    pbe_new.CN_Apex_Update_DateTime__c = DateTime.now();
                    priceBookEntryList_New_Standard.add(pbe_new);
                }
            }
            //set the CN_Is_Effected__c of the preset Pricebook entry to true
            CN_Preset_PriceBook_Entry__c ppbe_update = new CN_Preset_PriceBook_Entry__c(
                Id = ppbe.Id,
                CN_Is_Effected__c = true
            );
            ppbe_updateList.add(ppbe_update);
        }

        try{
            if(productList.size()>0){
                update productList;
            }
            if(priceBookEntryList_New_Standard.size()>0){
                insert priceBookEntryList_New_Standard;
            }
            if(priceBookEntryList_New_Channel.size()>0){
                insert priceBookEntryList_New_Channel;
            }
            if(priceBookEntryList_Update_Standard.size()>0){
                update priceBookEntryList_Update_Standard;
            }
            if(priceBookEntryList_Update_Channel.size()>0){
                update priceBookEntryList_Update_Channel;
            }
            if(ppbe_updateList.size()>0){
                update ppbe_updateList;
            }
        }catch(Exception e){
            Database.rollback(sp);
		    throw e;
        }finally{

        }
	}
    //modify by dezheng 20230413 ---- end

	global void finish(Database.BatchableContext BC) {

	}

}
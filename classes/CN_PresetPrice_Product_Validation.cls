/**************************************************************************************************
 * Name           : CN_PresetPrice_Product_Validation
 * Object         : 
 * Requirement    : 
 * Target         : Prevent add the products to Preset Price Book Entry which is not in standard price book entry
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-12-21
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_PresetPrice_Product_Validation implements Triggers.Handler {
    
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        } 
    }

    public void handleBeforeInsert() {
        //Exclude Integration User
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = profileList[0].Name;
        if(myProflieName.equals(Constants.CN_PROFILE_NAME_INTEGRATION)){
            return;
        }

        Set<Id> productIdSet_Preset = new Set<Id>();
        for(CN_Preset_PriceBook_Entry__c prePBEntry: (List<CN_Preset_PriceBook_Entry__c>)Trigger.New) {
            productIdSet_Preset.add(prePBEntry.CN_Product__c);
        }

        Set<Id> productIdSet_pbEntry = new Set<Id>();
        List<PricebookEntry> pbEntryList= new List<PricebookEntry>();
        //standard pricebook can't be queried with the formula field
        if(Test.isRunningTest()) {
            pbEntryList = [Select Id,Product2Id From PricebookEntry 
                                                    WHERE Product2Id IN :productIdSet_Preset AND Pricebook2Id =: Test.getStandardPricebookId()];
        }else{
            pbEntryList = [Select Id,Product2Id From PricebookEntry 
                                                    WHERE Product2Id IN :productIdSet_Preset AND CN_Price_Book_Code__c = :Constants.CN_PRESETPRICE_CHANNEL_LP];
        }
        
        for(PricebookEntry pbe : pbEntryList){
            productIdSet_pbEntry.add(pbe.Product2Id);
        }

        for(CN_Preset_PriceBook_Entry__c prePBEntry: (List<CN_Preset_PriceBook_Entry__c>)Trigger.New) {
            if(!productIdSet_pbEntry.contains(prePBEntry.CN_Product__c)){
                prePBEntry.addError(System.label.CN_PresetPrice_Product_Validation_MSG);
            }
        }
    }
    public void handleBeforeUpdate() {
        //Exclude Integration User
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = profileList[0].Name;
        if(myProflieName.equals(Constants.CN_PROFILE_NAME_INTEGRATION)){
            return;
        }

        Set<Id> productIdSet_Preset = new Set<Id>();

        for(CN_Preset_PriceBook_Entry__c prePBEntry: (List<CN_Preset_PriceBook_Entry__c>)Trigger.New) {
            productIdSet_Preset.add(prePBEntry.CN_Product__c);
        }

        Set<Id> productIdSet_pbEntry = new Set<Id>();
        //standard pricebook can't be queried with the formula field
        List<PricebookEntry> pbEntryList= new List<PricebookEntry>();
        if(Test.isRunningTest()) {
            pbEntryList = [Select Id,Product2Id From PricebookEntry 
                                                    WHERE Product2Id IN :productIdSet_Preset AND Pricebook2Id =: Test.getStandardPricebookId()];
        }else{
            pbEntryList = [Select Id,Product2Id From PricebookEntry 
                                                    WHERE Product2Id IN :productIdSet_Preset AND CN_Price_Book_Code__c = :Constants.CN_PRESETPRICE_CHANNEL_LP];
        }
        for(PricebookEntry pbe : pbEntryList){
            productIdSet_pbEntry.add(pbe.Product2Id);
        }

        for(CN_Preset_PriceBook_Entry__c prePBEntry: (List<CN_Preset_PriceBook_Entry__c>)Trigger.New) {
            if(!productIdSet_pbEntry.contains(prePBEntry.CN_Product__c)){
                prePBEntry.addError(System.label.CN_PresetPrice_Product_Validation_MSG);
            }
        }
    }
}
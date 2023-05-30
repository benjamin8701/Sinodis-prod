/**************************************************************************************************
 * Name           : CN_PresetPrice_Effect_Batch_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-12-21
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_PresetPrice_Effect_Batch_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_PresetPrice_Effect_Batch_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        CN_Price_Book_Setting__c pbSettings = CN_Price_Book_Setting__c.getInstance();
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        Id SalesPerforRTId = Schema.SObjectType.CN_Sales_Performance__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SP_RT_API_NAME_PERFORMANCE).getRecordTypeId();
        List<Product2> SKUList = [SELECT Id, Name, CN_SKU_Code__c FROM Product2];

        Test.startTest();
        List<PricebookEntry> pbEntryList = [Select Id,Product2Id,CN_Max_Discount_Price__c,CN_Discount_Price__c,UnitPrice From PricebookEntry Where Pricebook2Id =: pbSettings.CN_Price_Book1__c];
        
        //off validation rule switch,because of CN_Effective_Date__c,Price VR
        List<Trigger_Switcher_Setting__c> switcherSettingList = [Select Id From Trigger_Switcher_Setting__c Where SetupOwnerId =: UserInfo.getOrganizationId()];
        Trigger_Switcher_Setting__c switcherSettings_close = new Trigger_Switcher_Setting__c();
        switcherSettings_close.Id = switcherSettingList[0].Id;
        switcherSettings_close.EnableValidationRule__c = false;
        update switcherSettings_close;

        List<CN_Preset_PriceBook_Entry__c> prePBEntryList = new List<CN_Preset_PriceBook_Entry__c>();
        CN_Preset_PriceBook_Entry__c prePBEntry_1 = new CN_Preset_PriceBook_Entry__c(
            //Channel and existing pricebook entry
            CN_Channel__c = Constants.CN_PRESETPRICE_CHANNEL_DS,
            CN_Product__c = pbEntryList[0].Product2Id,
            CN_Max_Discount_Price__c = pbEntryList[0].CN_Max_Discount_Price__c+1,
            CN_Discount_Price__c = pbEntryList[0].CN_Discount_Price__c+1,
            CN_UnitPrice__c = pbEntryList[0].UnitPrice + 1,
            CN_Effective_Date__c = Date.today(),
            CN_Is_Effected__c = FALSE
        );
        prePBEntryList.add(prePBEntry_1);

        for(Product2 prod : SKUList){
            if(prod.CN_SKU_Code__c == 'P00003'){
                CN_Preset_PriceBook_Entry__c prePBEntry_2 = new CN_Preset_PriceBook_Entry__c(
                    //Channel and not existing pricebook entry
                    CN_Channel__c = Constants.CN_PRESETPRICE_CHANNEL_DS,
                    CN_Product__c = prod.Id,
                    CN_Max_Discount_Price__c = 10+1,
                    CN_Discount_Price__c = 20+1,
                    CN_UnitPrice__c = 30+1,
                    CN_Effective_Date__c = Date.today(),
                    CN_Is_Effected__c = FALSE
                );
                prePBEntryList.add(prePBEntry_2);
            }
        }

        insert prePBEntryList;

        //on validation rule switch
        Trigger_Switcher_Setting__c switcherSettings_open = new Trigger_Switcher_Setting__c();
        switcherSettings_open.Id = switcherSettingList[0].Id;
        switcherSettings_open.EnableValidationRule__c = true;
        update switcherSettings_open;

        try{
            CN_PresetPrice_Effect_Batch_SCH sch = new CN_PresetPrice_Effect_Batch_SCH();
            System.schedule('CN_PresetPrice_Effect_Batch_SCH' + Datetime.now(), '20 30 8 10 2 ?', sch);
        }catch(Exception e){

        }
        Test.stopTest();
    }
}
/**************************************************************************************************
 * Name           : CN_SOItem_Populate_CampaignP_Batch_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-10-14
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_SOItem_Populate_CampaignP_Batch_Test {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_SOItem_Populate_CampaignP_Batch_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        List<Account> accListFactory = testFactory.makeFactoryAccount();
        //add by Zhangzhihao  Create a TalendSetting 2024/4/6
        testFactory.makeTalendSetting();    
        //add by Zhangzhihao  Create a TalendSetting 2024/4/6

        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef', 'CCE1_KA')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }

        User salesRep = lastNameUserMap.get('Sales1');
        Account acc_factory = accListFactory[0];
        List<Product2> SKUList = [SELECT Id, Name FROM Product2];

        campaign cam = testFactory.makeCampaign();
        cam.CN_New_Product_Launch__c = true;
        cam.StartDate = Date.today().addMonths(-5);
        cam.EndDate = Date.today().addMonths(-5).addDays(13);
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
        System.runAs(salesRep) {
            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc_factory.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Material_Number__c = SKUList[0].Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);
        
            insert orderItemList;

        }

        Test.setCreatedDate(orderItemList[0].Id, Date.today().addDays(-1));
        test.startTest();
        
        CN_SOItem_Populate_CampaignPro_SCH sch = new CN_SOItem_Populate_CampaignPro_SCH();
        System.schedule('CN_SOItem_Populate_CampaignPro_SCH' + Datetime.now(), '20 30 8 10 2 ?', sch);

        CN_SOItem_Populate_CampaignPro_Batch batch = new CN_SOItem_Populate_CampaignPro_Batch();
        Database.executeBatch(batch);
        CN_SOItem_Populate_CampaignPro_Batch batch2 = new CN_SOItem_Populate_CampaignPro_Batch('Select  Id,CN_Material_Number__c From CN_Sales_Order_Item__c Where CN_Is_Created_Yesterday__c = TRUE');
        Database.executeBatch(batch2);
        
        test.stopTest();
    }
}
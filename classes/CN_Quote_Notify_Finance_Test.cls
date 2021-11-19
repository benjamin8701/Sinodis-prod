/**************************************************************************************************
 * Name           : CN_Quote_Notify_Finance_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-11-17
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Quote_Notify_Finance_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_Quote_Notify_Finance_Template_Ctrl_Test() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<Account> accFactroy_List = TestDataFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }

        User cce = lastNameUserMap.get('CCE1_KA');
        User salesRep = lastNameUserMap.get('Sales1');
        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        testDataFactory.approveAccount(acc_factory);

        Id cnQuoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_Quote_RT_API_NAME).getRecordTypeId();
        List<Product2> productList = [Select Id,name From Product2 LIMIT 2];
        PricebookEntry pbEntry = [Select Id,Product2Id From PricebookEntry Where Pricebook2Id =: Test.getStandardPricebookId() And Product2Id  =: productList[0].Id];

        CN_Promotion__c promotion = new CN_Promotion__c(
            Name = 'TestPromotion',
            CN_Start_Date__c = Date.today().addMonths(3),
            CN_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Promotion_Type__c = 'Discount',
            Channel__c = 'KA',
            CN_Status__c = 'Planned',
            Customer_Category__c = 'BAPA',
            CN_Sales_Office__c = 'K010'
        );

        CN_Promotion_Member__c pm = new CN_Promotion_Member__c ();
        Opportunity opp = new Opportunity();
        Quote q = new Quote ();

        System.runAs(cce) {
            insert promotion;

            promotion.CN_Status__c = Constants.CN_PROMOTION_STATUS_READY;
            try {
                update promotion;
            } catch (Exception e) {}

            CN_Promotion_Line_Item__c pli = new CN_Promotion_Line_Item__c(
                CN_Promotion__c = promotion.Id,
                CN_Product__c = productList[0].Id,
                CN_Promotion_Price__c = 99.9
            );
            insert pli;

            CN_Promotion_Generate_ProMember_LC_Ctrl.generateProMember(promotion.Id);

            pm = new CN_Promotion_Member__c(
                CN_Promotion__c = promotion.Id,
                CN_Account__c = acc_factory.Id
            );
            insert pm;

            promotion.CN_Status__c = Constants.CN_PROMOTION_STATUS_READY;
            update promotion;
            CN_Promotion_Publish_LC_Ctrl.prmtPublish(promotion.Id);
        }

        System.runAs(salesRep) {

            opp = testDataFactory.makeOpp(acc_factory);
            insert opp;

            Opportunity opp_update = new Opportunity();
            opp_update.Id = opp.Id;
            opp_update.Pricebook2Id = Test.getStandardPricebookId();
            update opp_update;

            OpportunityLineItem oppItem = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id  = productList[0].Id
            );
            insert oppItem;

            q = new Quote(
                Name = 'Quote Name',
                CN_Effective_Date__c = Date.Today()+1,
                ExpirationDate = Date.Today() + 7,
                OpportunityId = opp.Id,
                Pricebook2Id  = Test.getStandardPricebookId()
            );
            insert q;

            CN_Quote_To_Promotion__c quoteToPromo = new CN_Quote_To_Promotion__c(
                CN_Quote__c = q.Id,
                CN_Promotion_Member__c = pm.Id
            );
            insert quoteToPromo;
    
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem quoteItem = new QuoteLineItem(
                QuoteId = q.Id,
                Product2Id = productList[1].Id,
                Quantity = 1,
                UnitPrice = 1,
                PricebookEntryId = pbEntry.Id
            );
            QuoteLineItem quoteItem1 = new QuoteLineItem(
                QuoteId = q.Id,
                Product2Id = productList[0].Id,
                Quantity = 1,
                UnitPrice = 1,
                PricebookEntryId = pbEntry.Id
            );
            qliList.add(quoteItem);
            qliList.add(quoteItem1);
            insert qliList;
            quoteItem.UnitPrice = 1;
            update quoteItem;
            quoteItem1.UnitPrice = 100;
            quoteItem1.CN_Promotion_Member__c = pm.Id;
            update quoteItem1;

            CN_Quote_Sharing_Handler_Handler.isTrisTriggerRunigger = true;
            CN_Quote_Populate_Approver_Handler.isTrisTriggerRunigger = true;
            q.Status = 'Ready for Approval';
            q.CN_Effective_Date__c = Date.today().addMonths(3).addDays(1);
            q.ExpirationDate = Date.today().addMonths(3).addDays(13).addDays(-1);
            update q;
            CN_Quote_Sharing_Handler_Handler.isTrisTriggerRunigger = true;
            CN_Quote_Populate_Approver_Handler.isTrisTriggerRunigger = true;
            q.Status = 'Submitted for Approval';
            q.CN_Approve_Step__c = 'Step1';
            update q;

            Test.startTest();
            CN_Quote_Notify_Finance_Template_Ctrl ctrl = new CN_Quote_Notify_Finance_Template_Ctrl();
            ctrl.QId = q.Id;
            ctrl.getItems();
            ctrl.getQuoteURL();
            Test.stopTest();
        }
    }

    @isTest
    private static void CN_Quote_Finance_Notice_LC_Ctrl_Test() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<Account> accFactroy_List = TestDataFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }

        User cce = lastNameUserMap.get('CCE1_KA');
        User salesRep = lastNameUserMap.get('Sales1');
        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        testDataFactory.approveAccount(acc_factory);

        Id cnQuoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_Quote_RT_API_NAME).getRecordTypeId();
        List<Product2> productList = [Select Id,name From Product2 LIMIT 2];
        PricebookEntry pbEntry = [Select Id,Product2Id From PricebookEntry Where Pricebook2Id =: Test.getStandardPricebookId() And Product2Id  =: productList[0].Id];

        CN_Promotion__c promotion = new CN_Promotion__c(
            Name = 'TestPromotion',
            CN_Start_Date__c = Date.today().addMonths(3),
            CN_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Promotion_Type__c = 'Discount',
            Channel__c = 'KA',
            CN_Status__c = 'Planned',
            Customer_Category__c = 'BAPA',
            CN_Sales_Office__c = 'K010'
        );

        CN_Promotion_Member__c pm = new CN_Promotion_Member__c ();
        Opportunity opp = new Opportunity();
        Quote q = new Quote ();

        System.runAs(cce) {
            insert promotion;

            promotion.CN_Status__c = Constants.CN_PROMOTION_STATUS_READY;
            try {
                update promotion;
            } catch (Exception e) {}

            CN_Promotion_Line_Item__c pli = new CN_Promotion_Line_Item__c(
                CN_Promotion__c = promotion.Id,
                CN_Product__c = productList[0].Id,
                CN_Promotion_Price__c = 99.9
            );
            insert pli;

            CN_Promotion_Generate_ProMember_LC_Ctrl.generateProMember(promotion.Id);

            pm = new CN_Promotion_Member__c(
                CN_Promotion__c = promotion.Id,
                CN_Account__c = acc_factory.Id
            );
            insert pm;

            promotion.CN_Status__c = Constants.CN_PROMOTION_STATUS_READY;
            update promotion;
            CN_Promotion_Publish_LC_Ctrl.prmtPublish(promotion.Id);
        }

        System.runAs(salesRep) {

            opp = testDataFactory.makeOpp(acc_factory);
            insert opp;

            Opportunity opp_update = new Opportunity();
            opp_update.Id = opp.Id;
            opp_update.Pricebook2Id = Test.getStandardPricebookId();
            update opp_update;

            OpportunityLineItem oppItem = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id  = productList[0].Id
            );
            insert oppItem;

            q = new Quote(
                Name = 'Quote Name',
                CN_Effective_Date__c = Date.Today()+1,
                ExpirationDate = Date.Today() + 7,
                OpportunityId = opp.Id,
                Pricebook2Id  = Test.getStandardPricebookId()
            );
            insert q;

            CN_Quote_To_Promotion__c quoteToPromo = new CN_Quote_To_Promotion__c(
                CN_Quote__c = q.Id,
                CN_Promotion_Member__c = pm.Id
            );
            insert quoteToPromo;
    
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem quoteItem = new QuoteLineItem(
                QuoteId = q.Id,
                Product2Id = productList[1].Id,
                Quantity = 1,
                UnitPrice = 1,
                PricebookEntryId = pbEntry.Id
            );
            QuoteLineItem quoteItem1 = new QuoteLineItem(
                QuoteId = q.Id,
                Product2Id = productList[0].Id,
                Quantity = 1,
                UnitPrice = 1,
                PricebookEntryId = pbEntry.Id
            );
            qliList.add(quoteItem);
            qliList.add(quoteItem1);
            insert qliList;
            quoteItem.UnitPrice = 1;
            update quoteItem;
            quoteItem1.UnitPrice = 100;
            quoteItem1.CN_Promotion_Member__c = pm.Id;
            update quoteItem1;

            CN_Quote_Sharing_Handler_Handler.isTrisTriggerRunigger = true;
            CN_Quote_Populate_Approver_Handler.isTrisTriggerRunigger = true;
            q.Status = 'Ready for Approval';
            q.CN_Effective_Date__c = Date.today().addMonths(3).addDays(1);
            q.ExpirationDate = Date.today().addMonths(3).addDays(13).addDays(-1);
            update q;
            CN_Quote_Sharing_Handler_Handler.isTrisTriggerRunigger = true;
            CN_Quote_Populate_Approver_Handler.isTrisTriggerRunigger = true;
            q.Status = 'Submitted for Approval';
            q.CN_Approve_Step__c = 'Step1';
            update q;

            Test.startTest();
            CN_Quote_Finance_Notice_LC_Ctrl.sendNotifyEmail(q.Id);
            Test.stopTest();
        }
    }
}
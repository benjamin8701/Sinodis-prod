/**************************************************************************************************
 * Name           : CN_Quote_Send_To_SAP_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Quote_Send_To_SAP_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void controllerTest_200() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<Account> accFactroy_List = TestDataFactory.makeFactoryAccount();
        List<Product2> productList = [Select Id,name, CN_SKU_Code__c From Product2 LIMIT 1];
        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/400';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/400';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/400';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/400';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/200';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/400';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/400';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200?ProductCode=' + productList[0].CN_SKU_Code__c + '&IsSuccess=S';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200?ProductCode=' + productList[0].CN_SKU_Code__c + '&IsSuccess=S';
        insert talendSetting;

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

        PricebookEntry pbEntry = [Select Id,Product2Id, CN_Pricing_Unit__c, CN_Unit_of_Measure__c From PricebookEntry Where Pricebook2Id =: Test.getStandardPricebookId() And Product2Id  =: productList[0].Id];

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
        }

        CN_Quote_To_Promotion__c quoteToPromo = new CN_Quote_To_Promotion__c(
            CN_Quote__c = q.Id,
            CN_Promotion_Member__c = pm.Id
        );
        insert quoteToPromo;

        QuoteLineItem quoteItem = new QuoteLineItem(
            QuoteId = q.Id,
            Product2Id = productList[0].Id,
            Quantity = 2,
            UnitPrice = 12,
            PricebookEntryId = pbEntry.Id
        );
        insert quoteItem;

        q.Status = 'Approved';
        update q;

        quoteItem.CN_Customer_Acceptance__c = 'Accepted';
        quoteItem.CN_Finance_Acceptance__c = 'Accepted';
        update quoteItem;

        CN_Quote_Send_To_SAP_LC_Ctrl.getQuoteInfoAndCheckEditPermisison(q.Id);
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
        

        CN_Quote_Send_To_SAP_LC_Ctrl.sendQuote(q.Id);

        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.getQuoteInfoAndCheckEditPermisison('');
        } catch (Exception e) {
            
        }
        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.getQuoteInfoAndCheckEditPermisison('001000000000000');
        } catch (Exception e) {
            
        }
        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.sendQuote('');
        } catch (Exception e) {
            
        }
        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.sendQuote('001000000000000');
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    @isTest
    private static void controllerTest_200_Failed() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<Account> accFactroy_List = TestDataFactory.makeFactoryAccount();
        List<Product2> productList = [Select Id,name, CN_SKU_Code__c From Product2 LIMIT 1];
        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/400';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/400';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/400';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/400';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/200';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/400';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/400';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200?ProductCode=' + productList[0].CN_SKU_Code__c + '&IsSuccess=E';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200?ProductCode=' + productList[0].CN_SKU_Code__c + '&IsSuccess=E';
        insert talendSetting;

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

        PricebookEntry pbEntry = [Select Id,Product2Id, CN_Pricing_Unit__c, CN_Unit_of_Measure__c From PricebookEntry Where Pricebook2Id =: Test.getStandardPricebookId() And Product2Id  =: productList[0].Id];

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
        }

        CN_Quote_To_Promotion__c quoteToPromo = new CN_Quote_To_Promotion__c(
            CN_Quote__c = q.Id,
            CN_Promotion_Member__c = pm.Id
        );
        insert quoteToPromo;

        QuoteLineItem quoteItem = new QuoteLineItem(
            QuoteId = q.Id,
            Product2Id = productList[0].Id,
            Quantity = 2,
            UnitPrice = 12,
            PricebookEntryId = pbEntry.Id
        );
        insert quoteItem;

        q.Status = 'Approved';
        update q;

        quoteItem.CN_Customer_Acceptance__c = 'Accepted';
        quoteItem.CN_Finance_Acceptance__c = 'Accepted';
        update quoteItem;

        CN_Quote_Send_To_SAP_LC_Ctrl.getQuoteInfoAndCheckEditPermisison(q.Id);
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
        

        CN_Quote_Send_To_SAP_LC_Ctrl.sendQuote(q.Id);

        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.getQuoteInfoAndCheckEditPermisison('');
        } catch (Exception e) {
            
        }
        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.getQuoteInfoAndCheckEditPermisison('001000000000000');
        } catch (Exception e) {
            
        }
        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.sendQuote('');
        } catch (Exception e) {
            
        }
        try {
            CN_Quote_Send_To_SAP_LC_Ctrl.sendQuote('001000000000000');
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
}
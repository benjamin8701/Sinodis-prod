/**************************************************************************************************
 * Name           : CN_Quote_Accept_All_Items_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-10-13
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Quote_Accept_All_Items_LC_Ctrl_Test {

    static List<Account> accList_factory = null;
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleTest() {
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
        Id cnQuoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_Quote_RT_API_NAME_NEW).getRecordTypeId();
        List<Product2> productList = [Select Id,name From Product2 LIMIT 1];
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
        Quote q = new Quote();

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

            q = new Quote(
                Name = 'Quote Name',
                CN_Effective_Date__c = Date.Today()+1,
                ExpirationDate = Date.Today() + 7,
                OpportunityId = opp.Id
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

        Test.startTest();
        try {
            CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.getIfAcceptedAllItems(q.Id);
        } catch (Exception e) {}
        try {
            CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.acceptOrDenyAllQuoteItems(q.Id,false);
        } catch (Exception e) {}

        Quote q_update = new Quote(
            Id = q.Id,
            Status = Constants.CN_QUOTE_STATUS_APPROVED
        );
        update q_update;

        CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.getIfAcceptedAllItems(q.Id);
        CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.acceptOrDenyAllQuoteItems(q.Id,false);

        try {
            CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.getIfAcceptedAllItems('');
        } catch (Exception e) {}

        try {
            CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.getIfAcceptedAllItems('001000000000000');
        } catch (Exception e) {}

        try {
            CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.acceptOrDenyAllQuoteItems('',false);
        } catch (Exception e) {}

        try {
            CN_Quote_AcceptORDeny_All_Items_LC_Ctrl.acceptOrDenyAllQuoteItems('001000000000000',false);
        } catch (Exception e) {}


        CN_Quote_To_Promotion__c quoteToPromo2 = new CN_Quote_To_Promotion__c(
            CN_Quote__c = q.Id,
            CN_Promotion_Member__c = pm.Id
        );
        try {
            insert quoteToPromo2;
        } catch (Exception e) {}

        CN_Quote_To_Promotion__c quoteToPromo_delete = new CN_Quote_To_Promotion__c(
            Id = quoteToPromo.Id
        );
        try {
            delete quoteToPromo_delete;
        } catch (Exception e) {}

        Test.stopTest();
    }
    

}
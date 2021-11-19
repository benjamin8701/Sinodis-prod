/**************************************************************************************************
 * Name           : CN_Quote_Populate_Approver_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-08-04
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Populate_Approver_Handler implements Triggers.Handler {
    public static Boolean isTrisTriggerRunigger = true;
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            //handleBeforeInsert();
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            if(isTrisTriggerRunigger) {
                handleBeforeUpdate();
                isTrisTriggerRunigger = false;
            }
        }
    }
    
    public void handleBeforeUpdate() {
        Id quoteRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_QUOTE_RT_API_NAME).getRecordTypeId();
        List<Quote> quoteListForward = new List<Quote>();
        List<Quote> quoteListBackward = new List<Quote>();
        for(Quote quo : (List<Quote>)Trigger.new) {
            Quote oldQuote = (Quote)Trigger.oldMap.get(quo.Id);
            if(quoteRTId == quo.RecordTypeId && oldQuote.Status != quo.Status && Constants.CN_QUOTE_STATUS_READY.equals(quo.Status)) {
                quoteListForward.add(quo);
            } else if(quoteRTId == quo.RecordTypeId && oldQuote.Status != quo.Status 
                    && Constants.CN_QUOTE_STATUS_NEW.equals(quo.Status)) {
                quoteListBackward.add(quo);
            }
        }
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        if(quoteListForward.size() > 0) {
            qliList = populateApprover(quoteListForward);
        }
        if(quoteListBackward.size() > 0) {
            qliList = clearApprovalFields(quoteListBackward);
        }
        if(qliList.size() > 0) {
            for(QuoteLineItem qli: qliList) {
                qli.CN_Latest_Ready_DateTime__c = System.now();
            }
            update qliList;
        }
    }

    public List<QuoteLineItem> clearApprovalFields(List<Quote> quoteList) {

        List<QuoteLineItem> qliListForUpdate = new List<QuoteLineItem>();

        Set<Id> quoIdSet = new Set<Id>();
        for(Quote quo: quoteList) {
            quoIdSet.add(quo.Id);
        }
        List<QuoteLineItem> QLIList = [SELECT Id, 
                                            QuoteId,
                                            CN_List_Price__c, 
                                            CN_Channel_Price__c, 
                                            CN_Discount_Price__c, 
                                            CN_Max_Discount_Price__c, 
                                            CN_Promotion_Price__c, 
                                            CN_Is_Applied_Promotion__c, 
                                            CN_Approval_Type__c, 
                                            CN_Approve_Type_Code__c,
                                            CN_Approver_Id_List__c, 
                                            CN_Commets_for_Approver__c, 
                                            CN_Approver_Required__c,
                                            CN_Approval_Status_Required__c
                                        FROM QuoteLineItem 
                                        WHERE QuoteId IN: quoIdSet];

        for(QuoteLineItem qli: QLIList) {
            QuoteLineItem qliForUpdate = new QuoteLineItem();
            qliForUpdate.Id = qli.Id;
            qliForUpdate.CN_Is_Approval_Completed__c = false;
            qliForUpdate.CN_Approval_Status__c = '';
            qliForUpdate.CN_Approval_Status_Required__c = null;
            qliForUpdate.CN_Commets_for_Approver__c = null;
            qliForUpdate.CN_Approver_Id_List__c = null;
            qliForUpdate.CN_Approver_Required__c = null;
            qliListForUpdate.add(qliForUpdate);
        }
        
        return qliListForUpdate;
    }

    public List<QuoteLineItem> updateQuoteItemPromoPrices(List<QuoteLineItem> quoteItemList) {
        System.debug(quoteItemList);
        Set<Id> pbEntryIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        for(QuoteLineItem quoteItem : quoteItemList){
            pbEntryIdSet.add(quoteItem.PricebookEntryId);
            productIdSet.add(quoteItem.Product2Id);
        }
        
        List<PricebookEntry> standardPbEntryList = new List<PricebookEntry>();
        if(Test.isRunningTest()) {
            standardPbEntryList = [SELECT Id,
                                            UnitPrice,
                                            Product2Id,
                                            Pricebook2.IsStandard,
                                            Pricebook2Id,
                                            CN_Unit_of_Measure__c,
                                            CN_Pricing_Unit__c
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id =: Test.getStandardPricebookId()
                                        AND Product2Id IN: productIdSet];
        } else {
            standardPbEntryList = [SELECT Id,
                                            UnitPrice,
                                            Product2Id,
                                            Pricebook2.IsStandard,
                                            Pricebook2Id,
                                            CN_Unit_of_Measure__c,
                                            CN_Pricing_Unit__c
                                    FROM PricebookEntry
                                    WHERE Pricebook2.IsStandard = true
                                        AND Product2Id IN: productIdSet];
        }
        Map<Id, PricebookEntry> productIdStandardPBMap = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbEntry : standardPbEntryList){
            productIdStandardPBMap.put(pbEntry.Product2Id, pbEntry);
        }

        List<PricebookEntry> pbEntryList = [SELECT Id,
                                                    Product2Id,
                                                    Pricebook2Id,
                                                    CN_Discount_Price__c,
                                                    CN_Max_Discount_Price__c,
                                                    UnitPrice
                                            FROM PricebookEntry
                                            WHERE Id IN :pbEntryIdSet];
        Map<Id,PricebookEntry> pbEntryIdPbEntryMap = new Map<Id,PricebookEntry>();
        for(PricebookEntry pbEntry : pbEntryList){
            pbEntryIdPbEntryMap.put(pbEntry.Id, pbEntry);
        }
       
        for(QuoteLineItem quoteItem : quoteItemList){

            Decimal discountPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Discount_Price__c;
            Decimal channelPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).UnitPrice;
            if(discountPrice == null || discountPrice == 0) {
                discountPrice = channelPrice;
            }
            Decimal maxDiscountPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Max_Discount_Price__c;
            if(maxDiscountPrice == null || maxDiscountPrice == 0) {
                maxDiscountPrice = channelPrice;
            }
            quoteItem.CN_Pricing_Unit__c = productIdStandardPBMap.get(quoteItem.Product2Id).CN_Pricing_Unit__c;
            quoteItem.CN_Unit_of_Measure__c = productIdStandardPBMap.get(quoteItem.Product2Id).CN_Unit_of_Measure__c;
            quoteItem.CN_Channel_Price__c = channelPrice;
            quoteItem.CN_Discount_Price__c = discountPrice;
            quoteItem.CN_Max_Discount_Price__c = maxDiscountPrice;
            quoteItem.CN_List_Price__c = productIdStandardPBMap.get(quoteItem.Product2Id).UnitPrice;
        }
        return quoteItemList;
    }

    public List<QuoteLineItem> populateApprover(List<Quote> quoteList) {

        Set<Id> quoIdSet = new Set<Id>();
        for(Quote quo: quoteList) {
            quoIdSet.add(quo.Id);
        }
        List<QuoteLineItem> QLIList = [SELECT Id, 
                                            QuoteId,
                                            CN_List_Price__c, 
                                            CN_Channel_Price__c, 
                                            CN_Discount_Price__c, 
                                            CN_Max_Discount_Price__c, 
                                            CN_Promotion_Price__c, 
                                            CN_Is_Applied_Promotion__c, 
                                            CN_Approval_Type__c, 
                                            CN_Approve_Type_Code__c,
                                            CN_Approver_Id_List__c, 
                                            CN_Commets_for_Approver__c, 
                                            CN_Approver_Required__c,
                                            CN_Approval_Status_Required__c,
                                            PricebookEntryId,
                                            Product2Id,
                                            UnitPrice 
                                        FROM QuoteLineItem 
                                        WHERE QuoteId IN: quoIdSet];
        system.debug(QLIList);
        Map<Id, String> quoteIDApproveTypeMap = getApprovalType(QLIList);

        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        
        Set<String> CreatedByIdSet = new Set<String>();
        for(Quote quo : quoteList) {
            CreatedByIdSet.add(quo.CreatedById);
        }
		List<User> creatorList = [SELECT Id,
                                        CN_Sales_Team__c,
                                		Title,
                                		ManagerId,
                                		Manager.Title,
                                		Manager.ManagerId,
                                		Manager.Manager.Title,
                                		Manager.Manager.ManagerId,
                                		Manager.Manager.Manager.Title,
                                		Manager.Manager.Manager.ManagerId,
                                		Manager.Manager.Manager.Manager.Title,
                                		Manager.Manager.Manager.Manager.ManagerId,
                                		Manager.Manager.Manager.Manager.Manager.Title
                               FROM User
                               WHERE Id in: CreatedByIdSet];
        Map<Id, User> creatorMap = new Map<Id, User>(creatorList);

        Set<String> STCodeSet = new Set<String>();
        for(User u : creatorList){
            STCodeSet.add(u.CN_Sales_Team__c);
        }
        List<CN_Sales_Team__c> stList= [SELECT Id,
                                        Name,
                                        CN_Sales_Team_Code__c
                                FROM CN_Sales_Team__c
                                WHERE CN_Sales_Team_Code__c in :STCodeSet];

        Map<String, String> sTCodeSTNameMap = new Map<String, String>();
        for(CN_Sales_Team__c st : stList){
            sTCodeSTNameMap.put(st.CN_Sales_Team_Code__c,st.Name);
        }
        Map<Id, String> userIdSTNameStringMap = new Map<Id, String>();
        for(User u : creatorList){
            userIdSTNameStringMap.put(u.Id,sTCodeSTNameMap.get(u.CN_Sales_Team__c));
        }

        Map<Id, Decimal> quoteIdApprovalCodeMap = new Map<Id, Decimal>();
        Map<Id, List<Id>> quoteIdApproverIdListMap = new Map<Id, List<Id>>();
        for(Quote quo : quoteList) {

            String approvalType = quoteIDApproveTypeMap.get(quo.Id);

            quo.CN_Approver_1__c = null;
            quo.CN_Approver_2__c = null;
            quo.CN_Approver_3__c = null;
            quo.CN_Approver_4__c = null;
            quo.CN_Approver_5__c = null;
            quo.CN_Approver_6__c = null;
            quo.CN_Approver_7__c = null;
            quo.CN_Approver_8__c = null;
            quo.CN_Approver_9__c = null;
            quo.CN_Is_Auto_Approved__c = false;

            User creator = creatorMap.get(quo.CreatedById);
            Map<String, String> titleUserIdMap = new Map<String, String>();
            if(String.isNotBlank(creator.ManagerId)) {
            	titleUserIdMap.put(creator.Manager.Title, creator.ManagerId);
            }
            if(String.isNotBlank(creator.Manager.ManagerId)) {
            	titleUserIdMap.put(creator.Manager.Manager.Title, creator.Manager.ManagerId);
            }
            if(String.isNotBlank(creator.Manager.Manager.ManagerId)) {
            	titleUserIdMap.put(creator.Manager.Manager.Manager.Title, creator.Manager.Manager.ManagerId);
            }
            if(String.isNotBlank(creator.Manager.Manager.Manager.ManagerId)) {
            	titleUserIdMap.put(creator.Manager.Manager.Manager.Manager.Title, creator.Manager.Manager.Manager.ManagerId);
            }
            if(String.isNotBlank(creator.Manager.Manager.Manager.Manager.ManagerId)) {
            	titleUserIdMap.put(creator.Manager.Manager.Manager.Manager.Manager.Title, creator.Manager.Manager.Manager.Manager.ManagerId);
            }

            String ManagerUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_MANAGER);
            String ARMUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_ARM);
            String RMUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_RM);
            String CMUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_CM);
            String CDUserId = titleUserIdMap.get(Constants.CN_USER_TITLE_CD);

            Map<String, Integer> levelMap = new Map<String, Integer>();
            levelMap.put(Constants.CN_USER_TITLE_MANAGER, 0);
            levelMap.put(Constants.CN_USER_TITLE_ARM, 1);
            levelMap.put(Constants.CN_USER_TITLE_RM, 2);
            levelMap.put(Constants.CN_USER_TITLE_CM, 3);
            levelMap.put(Constants.CN_USER_TITLE_CD, 4);

            List<String> levelList = new List<String>();
            levelList.add(ManagerUserId);
            levelList.add(ARMUserId);
            levelList.add(RMUserId);
            levelList.add(CMUserId);
            levelList.add(CDUserId);

            if(System.Label.CN_Quote_Approve_Type_0.equals(approvalType) || System.Label.CN_Quote_Approve_Type_1.equals(approvalType)) {
                quo.CN_Is_Auto_Approved__c = true;
                if(ManagerUserId != null) {
                    quo.CN_Approver_1__c = ManagerUserId;
                } else {
                    quo.CN_Approver_1__c = getLatestApprover(Constants.CN_USER_TITLE_MANAGER, levelMap, levelList);
                }
            } else {
                quo.CN_Is_Auto_Approved__c = false;

 
                if(System.Label.CN_Quote_Approve_Type_2.equals(approvalType)) {
                    quo.CN_Approver_1__c = ManagerUserId;
                    if(RMUserId == null) {
                        quo.CN_Approver_2__c = getLatestApprover(Constants.CN_USER_TITLE_RM, levelMap, levelList);
                    } else {
                        quo.CN_Approver_2__c = RMUserId;
                    }
                } else if(System.Label.CN_Quote_Approve_Type_3.equals(approvalType)) {
                    quo.CN_Approver_1__c = ManagerUserId;
                    quo.CN_Approver_2__c = RMUserId;
                    quo.CN_Approver_3__c = CMUserId;
                    quo.CN_Approver_4__c = CDUserId;
                    String sTName = userIdSTNameStringMap.get(quo.createdById);
                    if(Constants.CN_SALES_TEAM_NAME_KA.equals(sTName)){
                        quo.CN_Approver_5__c = settings.CN_CCE1_KA__c;
                    }else if(Constants.CN_SALES_TEAM_NAME_DS.equals(sTName)){
                        quo.CN_Approver_6__c = settings.CN_CCE2_DS__c;
                    }else if(Constants.CN_SALES_TEAM_NAME_WS.equals(sTName)){
                        quo.CN_Approver_7__c = settings.CN_CCE3_WS__c;
                    }
                } else if(System.Label.CN_Quote_Approve_Type_4.equals(approvalType)) {
                    quo.CN_Approver_1__c = ManagerUserId;
                    quo.CN_Approver_2__c = RMUserId;
                    quo.CN_Approver_3__c = CMUserId;
                    quo.CN_Approver_4__c = CDUserId;
                    quo.CN_Approver_8__c = settings.CN_CCE_Director_UserId__c;
                    quo.CN_Approver_9__c = settings.CN_CEO_UserId__c;
                }
            }
            Decimal approvalCode = 0;
            quoteIdApproverIdListMap.put(quo.Id, new List<Id>());
            if(quo.CN_Approver_1__c != null) {
                approvalCode = approvalCode + 256;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_1__c);
            } 
            if(quo.CN_Approver_2__c != null) {
                approvalCode = approvalCode + 128;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_2__c);
            }
            if(quo.CN_Approver_3__c != null) {
                approvalCode = approvalCode + 64;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_3__c);
            }
            if(quo.CN_Approver_4__c != null) {
                approvalCode = approvalCode + 32;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_4__c);
            }
            if(quo.CN_Approver_5__c != null) {
                approvalCode = approvalCode + 16;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_5__c);
            }
            if(quo.CN_Approver_6__c != null) {
                approvalCode = approvalCode + 8;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_6__c);
            }
            if(quo.CN_Approver_7__c != null) {
                approvalCode = approvalCode + 4;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_7__c);
            }
            if(quo.CN_Approver_8__c != null) {
                approvalCode = approvalCode + 2;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_8__c);
            }
            if(quo.CN_Approver_9__c != null) {
                approvalCode = approvalCode + 1;
                quoteIdApproverIdListMap.get(quo.Id).add(quo.CN_Approver_9__c);
            }
            
            
            quoteIdApprovalCodeMap.put(quo.Id, approvalCode);
        }
        List<QuoteLineItem> QLIUpdateList = new List<QuoteLineItem>();
        QLIUpdateList = updateQuoteItemPromoPrices(QLIList);
        QLIUpdateList = setQuoteLineItemApprovalRequiredFields(QLIList, quoteIdApprovalCodeMap, quoteIdApproverIdListMap, quoteIDApproveTypeMap);
        return QLIUpdateList;

    }

    public List<QuoteLineItem> setQuoteLineItemApprovalRequiredFields(List<QuoteLineItem> quoList, Map<Id, Decimal> quoteIdApprovalCodeMap, Map<Id, List<Id>> quoteIdApproverIdListMap, Map<Id, String> quoteIDApproveTypeMap) {

        Set<Id> approverIdSet = new Set<Id>();
        for(Id quoteId: quoteIdApproverIdListMap.keySet()) {
            approverIdSet.addAll(quoteIdApproverIdListMap.get(quoteId));
        }
        approverIdSet.remove(null);
        Map<Id, String> approverIdNameMap = new Map<Id, String>();
        if(approverIdSet.size() > 0) {
            List<User> userList = [SELECT Id, LastName, FirstName FROM User WHERE Id IN: approverIdSet];
            for(User usr: userList) {
                String userName = '';
                if(String.isNotBlank(usr.LastName)) {
                    userName = userName + usr.LastName;
                }
                if(String.isNotBlank(usr.FirstName)) {
                    if(String.isNotBlank(usr.LastName)) {
                        userName = userName + ' ';
                    }
                    userName = userName + usr.LastName;
                }
                approverIdNameMap.put(usr.Id, usr.LastName + ' ' + usr.FirstName);
            }
        }

        List<QuoteLineItem> quoUpdateList = new List<QuoteLineItem>();
        for(QuoteLineItem qli: quoList) {
            QuoteLineItem qliUpdate = new QuoteLineItem();
            qliUpdate.Id = qli.Id;
            qliUpdate.CN_Is_Approval_Completed__c = false;
            qliUpdate.CN_Approval_Status__c = '';
            qliUpdate.CN_Approval_Status_Required__c = null;
            qliUpdate.CN_Commets_for_Approver__c = null;
            qliUpdate.CN_Channel_Price__c = qli.CN_Channel_Price__c;
            qliUpdate.CN_Discount_Price__c = qli.CN_Discount_Price__c;
            qliUpdate.CN_Max_Discount_Price__c = qli.CN_Max_Discount_Price__c;
            qliUpdate.CN_List_Price__c = qli.CN_List_Price__c;

            Integer requiredApproverCnt = 0;
            List<Id> approverIdAllList = quoteIdApproverIdListMap.get(qli.QuoteId);
            Integer approverIdAllListSize = approverIdAllList.size();

            if(System.Label.CN_Quote_Approve_Type_0.equals(qli.CN_Approval_Type__c) || System.Label.CN_Quote_Approve_Type_1.equals(qli.CN_Approval_Type__c)) {
                qliUpdate.CN_Approval_Status_Required__c = 0;
                qliUpdate.CN_Approver_Id_List__c = '';
                if(System.Label.CN_Quote_Approve_Type_0.equals(qli.CN_Approval_Type__c)) {
                    qliUpdate.CN_Commets_for_Approver__c = System.Label.CN_Quote_Approve_Type_0;
                } else {
                    qliUpdate.CN_Commets_for_Approver__c = System.Label.CN_Quote_Approve_Type_1;
                }
                qliUpdate.CN_Approver_Required__c = '';
            } else {
                if(System.Label.CN_Quote_Approve_Type_2.equals(qli.CN_Approval_Type__c)) {
                    qliUpdate.CN_Approval_Status_Required__c = Integer.valueOf(256 + 128) & Integer.valueOf(quoteIdApprovalCodeMap.get(qli.QuoteId)); // 110000000 & actual approver status
                    qliUpdate.CN_Commets_for_Approver__c = System.Label.CN_Quote_Approve_Type_2;
                    requiredApproverCnt = 2;

                } else if(System.Label.CN_Quote_Approve_Type_3.equals(qli.CN_Approval_Type__c)) {
                    // Quote Line Item follow Quote's Approval Process if there're Type 4 existed for Type 3 Item
                    if(System.Label.CN_Quote_Approve_Type_4.equals(quoteIDApproveTypeMap.get(qli.QuoteId))) {
                        qliUpdate.CN_Approval_Status_Required__c = Integer.valueOf(256 + 128 + 64 + 32 + 2 + 1) & Integer.valueOf(quoteIdApprovalCodeMap.get(qli.QuoteId)); // 111100011 & actual approver status
                        qliUpdate.CN_Commets_for_Approver__c = System.Label.CN_Quote_Approve_Type_3;
                        requiredApproverCnt = 6;

                    } else {
                        qliUpdate.CN_Approval_Status_Required__c = Integer.valueOf(256 + 128 + 64 + 32 + 16 + 8 + 4) & Integer.valueOf(quoteIdApprovalCodeMap.get(qli.QuoteId)); // 111111100 & actual approver status
                        qliUpdate.CN_Commets_for_Approver__c = System.Label.CN_Quote_Approve_Type_3;
                        requiredApproverCnt = 5;
                    }
                } else if(System.Label.CN_Quote_Approve_Type_4.equals(qli.CN_Approval_Type__c)) {
                    qliUpdate.CN_Approval_Status_Required__c = Integer.valueOf(256 + 128 + 64 + 32 + 2 + 1) & Integer.valueOf(quoteIdApprovalCodeMap.get(qli.QuoteId)); // 111100011 & actual approver status
                    qliUpdate.CN_Commets_for_Approver__c = System.Label.CN_Quote_Approve_Type_4;
                    requiredApproverCnt = 6;
                }

                Integer approverLimit = requiredApproverCnt > approverIdAllListSize? approverIdAllListSize: requiredApproverCnt;
                List<Id> approverIdList = new List<Id>();
                for(Integer i = 0; i < approverLimit; i++) {
                    approverIdList.add(approverIdAllList[i]);
                }
                qliUpdate.CN_Approver_Id_List__c = String.join(approverIdList, ';');
                List<String> approverNameList = new List<String>();
                for(Id approverId: approverIdList) {
                    if(approverIdNameMap.containsKey(approverId)) {
                        approverNameList.add(approverIdNameMap.get(approverId));
                    }
                }
                qliUpdate.CN_Approver_Required__c = String.join(approverNameList, ';');
            }
            quoUpdateList.add(qliUpdate);
        }
        return quoUpdateList;
    }

    public String getLatestApprover(String title, Map<String, Integer> levelMap, List<String> levelList) {
        String latestApproverId = null;
        if(levelMap.containsKey(title)) {
            if(levelMap.get(title) <= levelList.size()) {
                if(String.isBlank(levelList[levelMap.get(title)])) {
                    for(Integer i = levelMap.get(title); i < levelList.size(); i++) {
                        if(String.isNotBlank(levelList[i])) {
                            latestApproverId = levelList[i];
                            break;
                        }
                    }
                } else {
                    latestApproverId = levelList[levelMap.get(title)];
                }
            }
        }
        return latestApproverId;
    }

    public Map<Id, String> getApprovalType(List<QuoteLineItem> QLIList) {

        Map<Id, String> quoteIdApproveTypeMap = new Map<Id, String>();

        if(QLIList.size() > 0) {

            Map<Id, Decimal> quoteIdApproveTypeCodeMap = new Map<Id, Decimal>();
            for(QuoteLineItem qli: QLIList) {
                if(quoteIdApproveTypeCodeMap.containsKey(qli.QuoteId)) {
                    if(qli.CN_Approve_Type_Code__c != 99 && qli.CN_Approve_Type_Code__c > quoteIdApproveTypeCodeMap.get(qli.QuoteId)) {
                        quoteIdApproveTypeCodeMap.put(qli.QuoteId, qli.CN_Approve_Type_Code__c);
                    } 
                } else {
                    quoteIdApproveTypeCodeMap.put(qli.QuoteId, qli.CN_Approve_Type_Code__c);
                }
            }
            for(Id quoId: quoteIdApproveTypeCodeMap.keySet()) {
                if(quoteIdApproveTypeCodeMap.get(quoId) == 0) {
                    quoteIdApproveTypeMap.put(quoId, System.label.CN_Quote_Approve_Type_0);
                } else if(quoteIdApproveTypeCodeMap.get(quoId) == 1) {
                    quoteIdApproveTypeMap.put(quoId, System.label.CN_Quote_Approve_Type_1);
                } else if(quoteIdApproveTypeCodeMap.get(quoId) == 2) {
                    quoteIdApproveTypeMap.put(quoId, System.label.CN_Quote_Approve_Type_2);
                } else if(quoteIdApproveTypeCodeMap.get(quoId) == 3) {
                    quoteIdApproveTypeMap.put(quoId, System.label.CN_Quote_Approve_Type_3);
                } else if(quoteIdApproveTypeCodeMap.get(quoId) == 4) {
                    quoteIdApproveTypeMap.put(quoId, System.label.CN_Quote_Approve_Type_4);
                }
            }            
        }
        return quoteIdApproveTypeMap;
    }

}
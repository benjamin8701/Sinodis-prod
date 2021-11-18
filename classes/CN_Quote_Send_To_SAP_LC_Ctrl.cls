/**************************************************************************************************
 * Name           : CN_Quote_Send_To_SAP_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Send_To_SAP_LC_Ctrl {
    public static String moduleName = System.Label.CN_Quote_Name;
    @AuraEnabled
    public static Map<String, Object> getQuoteInfoAndCheckEditPermisison(String recordId){
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Not_Found, new List<String>{moduleName}));
        }
        
        Boolean hasCreatePermission = false;
        String errorMsg = '';
        Quote quo = new Quote();
        hasCreatePermission = true;
        // if(!hasCreatePermission) {
        //     throw new AuraHandledException(String.format(System.Label.CN_Quote_No_Permission, new List<String>{moduleName}));
        // }
        
        List<QuoteLineItem> qliList = [SELECT Id,
                                    LineNumber,
                                    CN_Condition_Type_API__c,
                                    CN_Condition_Table_API__c,
                                    CN_Rate_API__c,
                                    CN_Rate_Unit_API__c,
                                    CN_Customer_Number_API__c,
                                    CN_Material_Number_API__c,
                                    CN_Valid_From_API__c,
                                    CN_Valid_To_API__c,
                                    PricebookEntryId,
                                    Product2Id,
                                    CN_Channel_Price__c,
                                    CN_Max_Discount_Price__c,
                                    CN_List_Price__c
                                FROM QuoteLineItem 
                                WHERE QuoteId =: recordId 
                                    AND CN_Finance_Acceptance__c = 'Accepted' 
                                    AND CN_Customer_Number_API__c != null
                                    AND CN_Customer_Acceptance__c != null
                                    AND CN_Sync_Status__c != 'Success'
                                    AND Quote.Status = 'Approved'];
        if(qliList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Quote_Send_To_SAP_ErrMsg_NoItem);
        }
        List<QuoteLineItem> qliListForUpdate = updateQuoteItemPromoPrices(qliList);
        Constants.CN_QUOTEITEM_VALIDATION_HANDLER_TRIGGER_ON = false;
        update qliListForUpdate;
        Constants.CN_QUOTEITEM_VALIDATION_HANDLER_TRIGGER_ON = true;
        return new Map<String, Object>{
            'hasCreatePermission' => hasCreatePermission,
            'errorMsg' => errorMsg
        };
    }

    @auraEnabled
    public static Map<String, Object> sendQuote(String recordId) {
        
        System.debug('Send Start');
        System.debug(Datetime.now().getTime());
        Boolean isSendSuccess = false;
        String errorMessage = '';
        
        if(String.isBlank(recordId)) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Not_Found, new List<String>{moduleName}));
        }
        
        //Boolean hasCreatePermission = Untils.checkObjectCreatePermission('Quote');
        //if(!hasCreatePermission) {
        //    throw new AuraHandledException(String.format(System.Label.CN_Quote_No_Permission, new List<String>{moduleName}));
        //}

        List<Quote> quoList = [SELECT Id, 
                                        Name,
                                        Status,
                                        CN_Sync_Status__c,
                                        CN_Sync_Time__c        //SQL
                                    FROM Quote
                                    WHERE Id =: recordId AND Status =: Constants.CN_QUOTE_STATUS_APPROVED];
        if(quoList.isEmpty()) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Not_Found, new List<String>{moduleName}));
        }

        Quote quoToSend = quoList[0];
        if(Constants.CN_QUOTE_SYNC_STATUS_SUCCESS.equals(quoToSend.CN_Sync_Status__c) ) {
            throw new AuraHandledException(String.format(System.Label.CN_Quote_Had_Synced, new List<String>{moduleName}));
        }
        if(checkTimeInterval(quoToSend)) {
            throw new AuraHandledException(System.Label.CN_Quote_Warning_Msg_Too_Frequency);      //label
        }
        
        Map<String, Object> resultMap = doCallout(quoToSend.Id);
        
        return resultMap;
    }

    public static Map<String, Object> doCallout(Id quoteId) {

        Boolean isSendSuccess = false;

        Boolean isSFDCUpdateSuccess = false;
        Boolean isSAPSendSuccess = false;

        Boolean isAllResultUpdated = false;
        String errorMsg = '';
 
        Map<String, Id> skuCodeQliIdMap = new Map<String, Id>();
        Map<Id, String> qliIdNameMap = new Map<Id, String>();

        List<QuoteLineItem> quoteLineItemAllList = getQuoteLineItem(quoteId);
        system.debug('quoteLineItemAllList');
        system.debug(quoteLineItemAllList);
        Integer qliAllCnt = quoteLineItemAllList.size();
        Integer successIntoSAPCnt = 0;
        Integer successIntoSFDCCnt = 0;

        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        for(QuoteLineItem qli: quoteLineItemAllList) {
            if(qli.CN_Sync_Status__c != 'Success') {
                quoteLineItemList.add(qli);
            }
        }
        system.debug('quoteLineItemList');
        system.debug(quoteLineItemList);
        Integer qliNeedToSendCnt = quoteLineItemList.size();

        if(qliNeedToSendCnt > 0) {
            for(QuoteLineItem qli: quoteLineItemList) {
                skuCodeQliIdMap.put(qli.CN_Material_Number_API__c, qli.Id);
                qliIdNameMap.put(qli.Id, qli.LineNumber);
            }
            String requestBody = generateRequestJSON(quoteLineItemList);
            HTTPResponse resp = sendHTTPRequest(requestBody);
            Integer resCode = resp.getStatusCode();
            String resBody = resp.getBody();
            System.debug(resBody);
            if(resCode == 200) {
                try{
                    List<QuoteLineItem> qliUpdateList = new List<QuoteLineItem>();
                    Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
                    List<Object> resultList = (List<Object>)resMap.get('results');
                    List<Id> failedIdSAPList = new List<Id>();
                    Set<String> failedSKUCodeList = new Set<String>();
                    for(Object result: resultList) {
                        QuoteLineItem qliUpdate = new QuoteLineItem();
                        Map<String, Object> resultMap = (Map<String, Object>)result;

                        String SKUCode = resultMap.containsKey('CN_Material_Number_API__c')? (String)resultMap.get('CN_Material_Number_API__c'): '';
                        if(String.isNotBlank(SKUCode) && skuCodeQliIdMap.containsKey(SKUCode)) {
                            qliUpdate.Id = skuCodeQliIdMap.get(SKUCode);
                            qliUpdate.CN_Sync_Time__c = System.now();
                            qliUpdate.CN_Sync_Error_Message__c = resultMap.containsKey('CN_Sync_Error_Message__c')? (String)resultMap.get('CN_Sync_Error_Message__c'): '';
                            if(resultMap.containsKey('CN_Sync_Status__c')) {
                                String resultStatus = (String)resultMap.get('CN_Sync_Status__c');
                                if('S'.equals(resultStatus)) {
                                    successIntoSAPCnt++;
                                    qliUpdate.CN_Sync_Status__c = 'Success';
                                } else {
                                    qliUpdate.CN_Sync_Status__c = 'Failed';
                                    failedIdSAPList.add(skuCodeQliIdMap.get(SKUCode));
                                    failedSKUCodeList.add(SKUCode);
                                }
                            }
                            qliUpdateList.add(qliUpdate);
                        }
                    }
                    if(qliNeedToSendCnt == successIntoSAPCnt) {
                        isSAPSendSuccess = true;
                    }
                    if(qliUpdateList.size() > 0) {
                        List<Id> failedIdList = new List<Id>();
                        List<String> errMsgList = new List<String>();
                        Database.SaveResult[] updateResultList = Database.update(qliUpdateList, false);
                        Integer successCnt = 0;
                        for(Database.SaveResult updateResult: updateResultList) {
                            if(updateResult.isSuccess()) {
                                successIntoSFDCCnt++;
                            } else {
                                errMsgList.add(String.join(updateResult.getErrors()[0].getFields(), ',') + ':' + updateResult.getErrors()[0].getMessage());
                                failedIdList.add(updateResult.getId());
                            }
                        }
                        if(qliNeedToSendCnt == successIntoSFDCCnt) {
                            if(qliNeedToSendCnt == successIntoSAPCnt) {
                                Quote quoUpdate = new Quote();
                                quoUpdate.Id = quoteId;
                                quoUpdate.CN_Sync_Status__c = Constants.CN_QUOTE_SYNC_STATUS_SUCCESS;
                                quoUpdate.CN_Sync_Time__c = System.now();
                                quoUpdate.CN_Sync_Error_Message__c = '';
                                update quoUpdate;
                            } else {
                                System.debug(qliNeedToSendCnt);
                                System.debug(successIntoSAPCnt);
                                System.debug(failedSKUCodeList);
                                String failedCnt = String.valueOf(qliNeedToSendCnt - successIntoSAPCnt);
                                String SKUCode = String.join(new List<String>(failedSKUCodeList), ',');
                                errorMsg = String.format(System.Label.CN_Quote_Send_To_SAP_ErrMsg_Failed, new List<String>{String.valueOf(qliNeedToSendCnt), failedCnt, SKUCode});
                                Quote quoUpdate = new Quote();
                                quoUpdate.Id = quoteId;
                                quoUpdate.CN_Sync_Status__c = Constants.CN_QUOTE_SYNC_STATUS_FAIL;
                                quoUpdate.CN_Sync_Time__c = System.now();
                                quoUpdate.CN_Sync_Error_Message__c = errorMsg;
                                update quoUpdate;
                            }
                            isSFDCUpdateSuccess = true;
                        } else {
                            String failedCnt = String.valueOf(qliNeedToSendCnt - successIntoSFDCCnt);
                            List<String> qliNameList = new List<String>();
                            for(Id qliId: failedIdList) {
                                qliNameList.add(qliIdNameMap.get(qliId));
                            }
                            String qliName = String.join(qliNameList, ',');
                            errorMsg = String.format(System.Label.CN_Quote_Send_To_SAP_ErrMsg_Failed + ' ' + String.join(errMsgList, ';'), new List<String>{String.valueOf(qliNeedToSendCnt), failedCnt, qliName});
                            Quote quoUpdate = new Quote();
                            quoUpdate.Id = quoteId;
                            quoUpdate.CN_Sync_Status__c = Constants.CN_QUOTE_SYNC_STATUS_FAIL;
                            quoUpdate.CN_Sync_Time__c = System.now();
                            quoUpdate.CN_Sync_Error_Message__c = errorMsg;
                            update quoUpdate;
                        }
                    }
                } catch(Exception e) {
                    isSendSuccess = false;
                    errorMsg = e.getMessage();
                }
            } else {
                String errorMessage = '';
                isSendSuccess = false;
                if(resCode == 500) {
                    errorMessage = System.Label.CN_Account_API_Server_Error;
                } else if(resCode == 400) { 
                    errorMessage = System.Label.CN_Account_Request_Validation_Fail;
                } else if(resCode == 401) {
                    errorMessage = System.Label.CN_Account_API_US_PW_Error;
                } else if(resCode == 404) {
                    errorMessage = System.Label.CN_Account_API_Path_Error;
                }
                errorMsg = resCode + ':' + errorMessage + System.Label.CN_Account_Contact_System_Admin;
            }
        } else {
            errorMsg = System.Label.CN_Quote_Send_To_SAP_ErrMsg_NoItem;
        }
        System.debug(errorMsg);

        Integer SAPSendFailedCnt = 0;
        Integer SFDCUpdateFailedCnt = 0;

        SAPSendFailedCnt = qliNeedToSendCnt - successIntoSAPCnt;
        SFDCUpdateFailedCnt = qliNeedToSendCnt - successIntoSFDCCnt;
        if(isSAPSendSuccess && isSFDCUpdateSuccess) {
            isSendSuccess = true;
        }

        return new Map<String, Object>{
            'isSendSuccess' => isSendSuccess,
            'errorMessage' => errorMsg,
            'qliNeedToSendCnt' => qliNeedToSendCnt,
            'isSAPSendSuccess' => isSAPSendSuccess,
            'SAPSendFailedCnt' => SAPSendFailedCnt,
            'isSFDCUpdateSuccess' => isSFDCUpdateSuccess,
            'SFDCUpdateFailedCnt' => SFDCUpdateFailedCnt
        };
    }

    public static List<QuoteLineItem> updateQuoteItemPromoPrices(List<QuoteLineItem> quoteItemList) {
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
        Map<Id, PricebookEntry> pbEntryIdPbEntryMap = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbEntry : pbEntryList){
            pbEntryIdPbEntryMap.put(pbEntry.Id, pbEntry);
        }
       
        List<QuoteLineItem> qliListForUpdate = new List<QuoteLineItem>();

        for(QuoteLineItem quoteItem : quoteItemList){

            QuoteLineItem qliForUpdate = new QuoteLineItem();
            qliForUpdate.Id = quoteItem.Id;

            Decimal discountPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Discount_Price__c;
            Decimal channelPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).UnitPrice;
            if(discountPrice == null || discountPrice == 0) {
                discountPrice = channelPrice;
            }
            Decimal maxDiscountPrice = pbEntryIdPbEntryMap.get(quoteItem.PricebookEntryId).CN_Max_Discount_Price__c;
            if(maxDiscountPrice == null || maxDiscountPrice == 0) {
                maxDiscountPrice = channelPrice;
            }
            qliForUpdate.CN_Pricing_Unit__c = productIdStandardPBMap.get(quoteItem.Product2Id).CN_Pricing_Unit__c;
            qliForUpdate.CN_Unit_of_Measure__c = productIdStandardPBMap.get(quoteItem.Product2Id).CN_Unit_of_Measure__c;
            qliForUpdate.CN_Channel_Price__c = channelPrice;
            qliForUpdate.CN_Discount_Price__c = discountPrice;
            qliForUpdate.CN_Max_Discount_Price__c = maxDiscountPrice;
            qliForUpdate.CN_List_Price__c = productIdStandardPBMap.get(quoteItem.Product2Id).UnitPrice;
            qliListForUpdate.add(qliForUpdate);
        }
        return qliListForUpdate;
    }

    public static HTTPResponse sendHTTPRequest(String requestJSON) {
        Talend_Setting__c setting = Talend_Setting__c.getInstance();
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        Blob headerValue;
        if (Untils.isSandbox()) {
            request.setEndpoint(setting.Sandbox_Quote_Endpoint__c);
            headerValue = Blob.valueOf(setting.Sandbox_User_Name__c + ':' + setting.Sandbox_Password__c);
        } else {
            request.setEndpoint(setting.Quote_Endpoint__c);
            headerValue = Blob.valueOf(setting.User_Name__c + ':' + setting.Password__c);
        }

        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setBody(requestJSON);
        request.setTimeout(120000);
        HTTPResponse resp = http.send(request);
        return resp;
    }

    public static String generateRequestJSON(List<QuoteLineItem> qliList) {
        String result = null;
        if(qliList.size() > 0) {
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('quotationlineitems');
            gen.writeStartArray();
            for(QuoteLineItem qli: qliList) {
                gen.writeStartObject();
                gen.writeIdField('Id', qli.Id);
                gen.writeStringField('CN_Condition_Type_API__c', qli.CN_Condition_Type_API__c == null? '': qli.CN_Condition_Type_API__c);
                gen.writeStringField('CN_Condition_Table_API__c', qli.CN_Condition_Table_API__c == null? '': qli.CN_Condition_Table_API__c);
                gen.writeNumberField('CN_Rate_API__c', qli.CN_Rate_API__c == null? 0: qli.CN_Rate_API__c);
                gen.writeStringField('CN_Rate_Unit_API__c', qli.CN_Rate_Unit_API__c == null? '': qli.CN_Rate_Unit_API__c);
                gen.writeStringField('CN_Customer_Number_API__c', qli.CN_Customer_Number_API__c == null? '': qli.CN_Customer_Number_API__c);
                gen.writeStringField('CN_Material_Number_API__c', qli.CN_Material_Number_API__c == null? '': qli.CN_Material_Number_API__c);
                gen.writeStringField('CN_Valid_From_API__c', qli.CN_Valid_From_API__c == null? '': qli.CN_Valid_From_API__c);
                gen.writeStringField('CN_Valid_To_API__c', qli.CN_Valid_To_API__c == null? '': qli.CN_Valid_To_API__c);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
            gen.close();
            result = gen.getAsString();
        }
        return result;
    }

    public static List<QuoteLineItem> getQuoteLineItem(Id quoteId) {
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        qliList = [SELECT Id,
                        LineNumber,
                        CN_Condition_Type_API__c,
                        CN_Condition_Table_API__c,
                        CN_Rate_API__c,
                        CN_Rate_Unit_API__c,
                        CN_Customer_Number_API__c,
                        CN_Material_Number_API__c,
                        CN_Valid_From_API__c,
                        CN_Valid_To_API__c,
                        CN_Sync_Status__c
                    FROM QuoteLineItem 
                    WHERE QuoteId =: quoteId 
                        AND CN_Finance_Acceptance__c = 'Accepted' 
                        AND CN_Customer_Number_API__c != null
                        AND CN_Customer_Acceptance__c != null
                        // AND CN_Sync_Status__c != 'Success'
                        AND Quote.Status = 'Approved'];
        return qliList;
    }

    public static Boolean checkTimeInterval(Quote quoToSend){
        Boolean isLessFiveMins = (quoToSend.CN_Sync_Status__c != null && quoToSend.CN_Sync_Time__c != null 
        && quoToSend.CN_Sync_Time__c > Datetime.now().addSeconds(-5));     
        return isLessFiveMins;
    }
}
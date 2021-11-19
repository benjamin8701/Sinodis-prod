/**************************************************************************************************
 * Name           : CN_Quote_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-04
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Quote_Populate_Fields_Handler implements Triggers.Handler{
    Set<Id> CN_RTIds = new Set<Id>();
    
    public void handle() {
        CN_RTIds.add(Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_Quote_RT_API_NAME_NEW).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(Constants.CN_Quote_RT_API_NAME).getRecordTypeId());
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }
    
    public void handleAfterUpdate() {
        List<Quote> quoList = new List<Quote>();
        for(Quote quo: (List<Quote>)Trigger.New) {
            Quote oldQuote = (Quote)Trigger.OldMap.get(quo.Id);
            if(CN_RTIds.contains(quo.RecordTypeID) 
                && oldQuote.status != quo.Status 
                && Constants.CN_QUOTE_STATUS_SUBMITTED.equals(oldQuote.Status) 
                && (Constants.CN_QUOTE_STATUS_REJECTED.equals(quo.Status) || Constants.CN_QUOTE_STATUS_APPROVED.equals(quo.Status))) {
                quoList.add(quo);
            }
        }
        if(quoList.size() > 0) {
            List<QuoteLineItem> qliList = calculateQuoteLineItemApprovalCompleteStatus(quoList);
            if(qliList.size() > 0) {
                update qliList;
            }
        }
    }

    public List<QuoteLineItem> calculateQuoteLineItemApprovalCompleteStatus(List<Quote> quoList) {
        List<QuoteLineItem> qliUpdateList = new List<QuoteLineItem>();
        if(quoList.size() > 0) {
            Set<Id> quoIdSet = new Set<Id>();
            for(Quote quo: quoList) {
                quoIdSet.add(quo.Id);
            }
            List<QuoteLineItem> qliList = [SELECT 
                                                Id, 
                                                CN_Approve_Status__c, 
                                                CN_Approval_Status__c, 
                                                CN_Approval_Status_Required__c,
                                                Quote.CN_Approver_1__c,
                                                Quote.CN_Approver_2__c,
                                                Quote.CN_Approver_3__c,
                                                Quote.CN_Approver_4__c,
                                                Quote.CN_Approver_5__c,
                                                Quote.CN_Approver_6__c,
                                                Quote.CN_Approver_7__c,
                                                Quote.CN_Approver_8__c,
                                                Quote.CN_Approver_9__c,
                                                Quote.CN_Latest_Approver__c,
                                                Quote.Status
                                            FROM QuoteLineItem 
                                            WHERE QuoteId IN: quoIdSet];
            if(qliList.size() > 0) {
                for(QuoteLineItem qli: qliList) {

                    Decimal approveStatus = 0;
                    if(qli.Quote.CN_Latest_Approver__c != null) {
                        Decimal startNum = 256;
                        for(Integer i = 1; i <= 9; i++) {
                            if(qli.getSObject('Quote').get('CN_Approver_' + i + '__c') != null) {
                                if(qli.Quote.CN_Latest_Approver__c == qli.getSObject('Quote').get('CN_Approver_' + i + '__c')) {
                                    if(Constants.CN_QUOTE_STATUS_REJECTED.equals(qli.Quote.Status)) {
                                        break;
                                    } else if(Constants.CN_QUOTE_STATUS_APPROVED.equals(qli.Quote.Status)) {
                                        if(i == 1) {
                                            approveStatus = startNum;
                                        } else {
                                            approveStatus += startNum / Math.pow(2, i - 1);
                                        }
                                        break;
                                    }
                                } else {
                                    if(i == 1) {
                                        approveStatus = startNum;
                                    } else {
                                        approveStatus += startNum / Math.pow(2, i - 1);
                                    }
                                }
                            }
                        }
                    }

                    Decimal approveResult = Integer.valueoF(approveStatus) & Integer.valueoF(qli.CN_Approval_Status_Required__c);
                    if(approveResult == qli.CN_Approval_Status_Required__c) {
                        QuoteLineItem qliUpdate = new QuoteLineItem();
                        qliUpdate.Id =qli.Id;
                        qliUpdate.CN_Is_Approval_Completed__c = true;
                        qliUpdate.CN_Latest_Reject_Approve_DateTime__c = System.now();
                        if(String.isBlank(qliUpdate.CN_Approval_Status__c )) {
                            qliUpdate.CN_Approval_Status__c = Constants.CN_QUOTEITEM_APPROVAL_STATUS_APPROVED;
                        }
                        qliUpdateList.add(qliUpdate);
                    }
                }
            }
        }
        return qliUpdateList;
    }

    public void handleBeforeInsert() {
        Map<Quote,Id>  quoteOwnerIdMap = new Map<Quote,Id>();
        List<Quote> quoList = new List<Quote>();
        quoList.addAll((List<Quote>)Trigger.New);
        for(Quote quo : (List<Quote>)Trigger.New){
            if(CN_RTIds.contains(quo.RecordTypeId)) {
                quoteOwnerIdMap.put(quo,quo.OwnerId);
            }
        }
        Set<Id> OwnerIdSet = new Set<Id>();
        OwnerIdSet.addAll(quoteOwnerIdMap.values());
        List<User> createUserList = [SELECT id,CN_User_Personnel_Number__c FROM User Where id IN :OwnerIdSet];
        updateQuoteSalesPerson(quoteOwnerIdMap,createUserList);
        updateQuoteQuoteNumber(quoList);
        setExpirationDate(quoList);
    }
    
    public void setExpirationDate(List<Quote> quoList) {
        if(quoList.size() > 0) {
            for(Quote quo: quoList) {
                if(quo.CN_Effective_Date__c != null) {
                    quo.ExpirationDate = quo.CN_Effective_Date__c.addDays(30);
                }
            }
        }
    }

    public void updateQuoteSalesPerson(Map<Quote,Id> quoteOwnerIdMap,List<User> createUserList) {
        Map<Id,String>  userIdEmployeeNumberMap = new Map<Id,String>();
        for(User u : createUserList){
            if(u.CN_User_Personnel_Number__c<>NULL){
                userIdEmployeeNumberMap.put(u.id, u.CN_User_Personnel_Number__c);
            }
        }
        Set<String> employeeNumberSet = new Set<String>();
        employeeNumberSet.addAll(userIdEmployeeNumberMap.values());
        if(employeeNumberSet.size()==0){
            for(Quote quo : quoteOwnerIdMap.keySet()){
                quo.addError(system.Label.CN_Quote_Not_Found_IN_InternalEmployee);
            }
            return;
        }
        List<CN_Internal_Employee__c> internalEmployeeList = [SELECT id,CN_Personnel_Number__c FROM CN_Internal_Employee__c WHERE CN_Personnel_Number__c IN :employeeNumberSet];

        if(internalEmployeeList.size()>0){
            Map<String,Id>  EmployeeNumberEmployeeIdMap = new Map<String,Id>();
            for(CN_Internal_Employee__c employee : internalEmployeeList){
                EmployeeNumberEmployeeIdMap.put(employee.CN_Personnel_Number__c, employee.id);               
            }
            Map<Id,Id>  userIdEmployeeIdMap = new Map<Id,Id>();
            for(Id userId : userIdEmployeeNumberMap.keySet()){
                Id EmployeeId = EmployeeNumberEmployeeIdMap.get(userIdEmployeeNumberMap.get(userId));
                if(EmployeeId <> NULL){
                    userIdEmployeeIdMap.put(userId,EmployeeId);
                }
            }
            for(Quote quo : quoteOwnerIdMap.keySet()){
                if(userIdEmployeeIdMap.keySet().contains(quo.OwnerId)){
                    quo.CN_Sales_Person_Name__c = userIdEmployeeIdMap.get(quo.OwnerId);
                }else{
                    quo.addError(system.Label.CN_Quote_Not_Found_IN_InternalEmployee);
                }
            }
        }else{
            for(Quote quo : quoteOwnerIdMap.keySet()){
                quo.addError(system.Label.CN_Quote_Not_Found_IN_InternalEmployee);
            }
            return;
        }
    }

    public void updateQuoteQuoteNumber(List<Quote> quoList) {
        List<CN_Quote_Number_Setting__c> settingList = [SELECT Id,CN_Quote_Number__c,CN_DateTime__c FROM CN_Quote_Number_Setting__c];
        CN_Quote_Number_Setting__c setting = settingList[0];
        Integer day_setting = setting.CN_DateTime__c.day();
        Integer month_setting = setting.CN_DateTime__c.month();
        Integer year_setting = setting.CN_DateTime__c.year();

        DateTime todayDateTime = DateTime.now();
        Integer day_today = todayDateTime.day();
        Integer month_today = todayDateTime.month();
        Integer year_today = todayDateTime.year();

        String str_todayDate = todayDateTime.format('YYMMdd');

        for(Quote quo : quoList){
            if(day_setting==day_today && month_setting==month_today && year_setting==year_today){
                Integer num = Integer.valueOf(++setting.CN_Quote_Number__c);
                String text = String.valueOf(num);
                while (text.length() < 10)  { 
                    text = '0' + text; 
                }
                quo.CN_Quote_Number_Setting__c = str_todayDate + text; //after中更新custom setting
            }else{
                setting.CN_Quote_Number__c = 0;
                setting.CN_DateTime__c = todayDateTime;
                Integer num = Integer.valueOf(++setting.CN_Quote_Number__c);
                String text = String.valueOf(num);
                while (text.length() < 10)  { 
                    text = '0' + text; 
                }
                quo.CN_Quote_Number_Setting__c = str_todayDate + text; 
            }
        }
        update setting;
    }
}
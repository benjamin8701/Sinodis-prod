public class CN_Quote_Split_LC_Ctrl {
    
    @AuraEnabled
    public static String splitQuote(String QuoteId){
        system.debug('QuoteId==>'+QuoteId);
        //clone(false,true,false,false)         
        //name,status??
        Quote Quote = [Select Id,Name,AccountId,OpportunityId,OwnerId,
                       CN_Effective_Date__c,ExpirationDate,Status,
                       GrandTotal,Pricebook2Id,RecordTypeId
                       From Quote Where Id = :QuoteId];
        List<QuoteLineItem> Items = [Select Id,
                                     CN_Approval_Status__c,CN_Approval_Status_Required__c,CN_Approve_Complete_Target__c,
                                     CN_Approver_Id_List__c,CN_Approver_Required__c,CN_Channel_Price__c,CN_Commets_for_Approver__c,
                                     CN_Condition_Table_API__c,CN_Condition_Type_API__c,CreatedById,
                                     CN_Customer_Acceptance__c,ServiceDate,CN_Denied_Reason__c,Discount,
                                     CN_Discount_Price__c,CN_Finance_Acceptance__c,
                                     CN_Is_Approval_Completed__c,LastModifiedById,Description,
                                     CN_List_Price__c,ListPrice,CN_Max_Discount_Price__c,CN_Minimum_Price__c,
                                     Product2Id,CN_Promo_Price_P1__c,CN_Promo_Price_P2__c,CN_Promo_Price_P3__c,
                                     CN_Promo_Price_P4__c,CN_Promotion_Member__c,CN_Promotion_Price__c,
                                     Quantity,QuoteId,CN_Rate_Unit_API__c,UnitPrice,Subtotal,CN_Tax__c,TotalPrice,
                                     PricebookEntryId,cn_qty_per_ctn_pdf__c,cn_origin_pdf__c                                     
                                     From QuoteLineItem 
                                     Where QuoteId = :QuoteId
                                     And CN_Is_Approval_Completed__c = true];
        if(Items.size() == 0){
            throw new AuraHandledException(System.Label.CN_Quote_No_items_Msg);
        }
        
        Savepoint sp = Database.setSavepoint();
        try{ 
            
            Quote newQuote = Quote.clone(false,true,false,false);
            newQuote.Name = '[Split] - '+Quote.Name;            
            newQuote.Status = 'Approved';
            newQuote.CN_Source_Quote__c = Quote.Id;                         
            insert newQuote;
            system.debug('newQuote==>'+newQuote);
                        
            List<QuoteLineItem> newItems = new List<QuoteLineItem>();
            for(QuoteLineItem item:Items){
                QuoteLineItem newItem = item.clone(false,true,false,false);
                newItem.QuoteId = newQuote.Id;               
                newItem.CN_External_Id__c = null;
                newItem.CN_From_Splited__c = true;
                newItems.add(newItem);
            }            
            system.debug('newItems==>'+newItems);
            insert newItems;
            
            List<CN_Quote_To_Promotion__c> newQTPs = new List<CN_Quote_To_Promotion__c>();
            for(CN_Quote_To_Promotion__c qtp :[SELECT Id,CN_Promotion_Member__c,CN_Quote__c FROM CN_Quote_To_Promotion__c WHERE CN_Quote__c =: QuoteId]){
                CN_Quote_To_Promotion__c newQTP = new CN_Quote_To_Promotion__c();
                newQTP.CN_Promotion_Member__c = qtp.CN_Promotion_Member__c;
                newQTP.CN_Quote__c = newQuote.Id;
                newQTPs.add(newQTP);
            }
            if(newQTPs.size()>0){
                insert newQTPs;
            }
            
            Constants.CN_QUOTEITEM_PREVENT_DELETE_HANDLER_TRIGGER_ON = false;
            delete Items;
            
            return URL.getSalesforceBaseURL().toExternalForm()+'/'+newQuote.Id;
        }catch(Exception ex){
            Database.rollback(sp);
            throw new AuraHandledException('Split error:'+ex.getMessage());
            
        }
        
    }
}
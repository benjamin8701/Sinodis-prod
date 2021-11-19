/**************************************************************************************************
 * Name           : CN_QuoteItem_Validation_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas QIu
 * Create Date    : 2021-11-10
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_QuoteItem_Validation_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }

    public void handleBeforeUpdate() {
        Map<String, Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('QuoteLineItem').getDescribe().fields.getMap();
        Set<String> allFields = new Set<String>();
        for(String fieldName: mfields.keySet()) {
            Schema.DescribeFieldResult fResult = mfields.get(fieldName).getDescribe();
            if(fResult.isCustom() && !fResult.isCalculated() && fResult.isUpdateable()) {
                allFields.add(fieldName);
            }
        }
        allfields.add('unitprice');
        //allfields.add('quantity');
        allFields.add('description');
        allfields.remove('cn_approval_status_required__c');
        allfields.remove('cn_approve_complete_target__c');
        allfields.remove('cn_approver_id_list__c');
        allfields.remove('cn_approver_required__c');
        allfields.remove('cn_channel_price__c');
        allfields.remove('cn_from_splited__c');
        allfields.remove('cn_commets_for_approver__c');
        allfields.remove('cn_condition_table_api__c');
        allfields.remove('cn_condition_type_api__c');
        allfields.remove('cn_discount_price__c');
        allfields.remove('cn_external_id__c');
        allfields.remove('cn_is_approval_completed__c');
        allfields.remove('cn_latest_ready_datetime__c');
        allfields.remove('cn_list_price__c');
        allfields.remove('cn_max_discount_price__c');
        allfields.remove('cn_rate_unit_api__c');
        allfields.remove('cn_sync_status__c');
        allfields.remove('cn_sync_time__c');
        allfields.remove('cn_sync_error_message__c');
        allfields.remove('cn_unit_of_measure__c');
        allfields.remove('cn_latest_reject_approve_datetime__c');

        for(QuoteLineItem qli: (List<QuoteLineItem>)Trigger.new) {
            Set<String> allFieldsForQli = new Set<String>();
            allFieldsForQli.addAll(allfields);

            Set<String> notAllowChangedFields = new Set<String>();
            QuoteLineItem oldQli = (QuoteLineItem)Trigger.oldMap.get(qli.Id);
            if(Constants.CN_QUOTE_STATUS_NEW.equals(qli.CN_Quote_Status__c)) {
                notAllowChangedFields.add('CN_Customer_Acceptance__c');
                notAllowChangedFields.add('CN_Denied_Reason__c');
                notAllowChangedFields.add('CN_Approval_Status__c');
                notAllowChangedFields.add('CN_Finance_Acceptance__c');
                notAllowChangedFields.add('quantity');
                if(checkFieldsChanged(notAllowChangedFields, qli, oldQli)) {
                    qli.addError(System.Label.CN_QuoteLineItem_Field_Changed_ErrMsg_Quote_New);
                }
            } else if(Constants.CN_QUOTE_STATUS_REJECTED.equals(qli.CN_Quote_Status__c)) {
                if(qli.CN_Latest_Reject_Approve_DateTime__c == oldQli.CN_Latest_Reject_Approve_DateTime__c) {
  
                    if(qli.CN_Approval_Status__c != oldQli.CN_Approval_Status__c && Constants.CN_QUOTEITEM_APPROVAL_STATUS_APPROVED.equals(qli.CN_Approval_Status__c)) {
                        qli.addError(System.Label.CN_QuoteLineItem_Approved_Item_Changed_Status_ErrMsg_Quote_Reject);
                    } else if(qli.CN_Approval_Status__c == oldQli.CN_Approval_Status__c) {
                        if(qli.UnitPrice != oldQli.UnitPrice || qli.CN_Promotion_Member__c != oldQli.CN_Promotion_Member__c) {
                            qli.CN_Approval_Status__c = '';
                            qli.CN_Is_Approval_Completed__c = false;
                        } else {
                            notAllowChangedFields.add('CN_Customer_Acceptance__c');
                            notAllowChangedFields.add('CN_Denied_Reason__c');
                            //notAllowChangedFields.add('CN_Approval_Status__c');
                            notAllowChangedFields.add('CN_Finance_Acceptance__c');
                            notAllowChangedFields.add('CN_Promotion_Member__c');
                           notAllowChangedFields.add('quantity');
                            if(checkFieldsChanged(notAllowChangedFields, qli, oldQli)) {
                                qli.addError(System.Label.CN_QuoteLineItem_Field_Changed_ErrMsg_Quote_Reject);
                            }
                        }
                    }
                }
            } else if(Constants.CN_QUOTE_STATUS_READY.equals(qli.CN_Quote_Status__c)) {
                if(qli.cn_latest_ready_datetime__c == oldQli.cn_latest_ready_datetime__c) {
                    if(checkFieldsChanged(allFieldsForQli, qli, oldQli)) {
                        qli.addError(System.Label.CN_QuoteLineItem_Field_Changed_ErrMsg_Quote_Ready);
                    }
                }
            } else if(Constants.CN_QUOTE_STATUS_SUBMITTED.equals(qli.CN_Quote_Status__c)) {
                allFieldsForQli.remove('cn_approval_status__c');
                if(checkFieldsChanged(allFieldsForQli, qli, oldQli)) {
                    qli.addError(System.Label.CN_QuoteLineItem_Field_Changed_ErrMsg_Quote_SUBMITTED);
                }
            } else if(Constants.CN_QUOTE_STATUS_APPROVED.equals(qli.CN_Quote_Status__c)) {
                if(qli.CN_Latest_Reject_Approve_DateTime__c == oldQli.CN_Latest_Reject_Approve_DateTime__c) {
                    allFieldsForQli.remove('cn_customer_acceptance__c');
                    allFieldsForQli.remove('cn_denied_reason__c');
                    allFieldsForQli.remove('cn_finance_acceptance__c');
                    if(checkFieldsChanged(allFieldsForQli, qli, oldQli)) {
                        qli.addError(System.Label.CN_QuoteLineItem_Field_Changed_ErrMsg_Quote_Approved);
                    }
                }
            }
            if(qli.CN_Is_Approval_Completed__c) {
                if(qli.CN_Latest_Reject_Approve_DateTime__c == oldQli.CN_Latest_Reject_Approve_DateTime__c) {
                    allFieldsForQli.remove('cn_customer_acceptance__c');
                    allFieldsForQli.remove('cn_denied_reason__c');
                    allFieldsForQli.remove('cn_is_approval_completed__c');
                    allFieldsForQli.remove('cn_finance_acceptance__c');
                    if(checkFieldsChanged(allFieldsForQli, qli, oldQli)) {
                        qli.addError(System.Label.CN_QuoteLineItem_Field_Changed_ErrMsg_Approval_Completed);
                    }
                }
            }
        }

    }

    public Boolean checkFieldsChanged(Set<String> fields, QuoteLineItem newQli, QuoteLineItem oldQli) {
        Boolean isChanged = false;
        for(String field: fields) {
            if(newQli.get(field) != oldQli.get(field)) {
                isChanged = true;
                break;
            }
        }
        return isChanged;
    }
}
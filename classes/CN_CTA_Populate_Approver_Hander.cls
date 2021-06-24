/**************************************************************************************************
 * Name           : CN_CTA_Populate_Approver_Hander
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-05-12
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CTA_Populate_Approver_Hander implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }
    public void handleBeforeUpdate() {
        Id ctaRTId = Schema.SObjectType.CN_Credit_Term_Application__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CTA_RT_API_NAME).getRecordTypeId();
        List<CN_Credit_Term_Application__c> ctaList = new List<CN_Credit_Term_Application__c>();
        for(CN_Credit_Term_Application__c cta : (List<CN_Credit_Term_Application__c>)Trigger.new) {
            CN_Credit_Term_Application__c oldCta = (CN_Credit_Term_Application__c)((Map<Id, CN_Credit_Term_Application__c>)Trigger.OldMap).get(cta.Id);
            if(ctaRTId.equals(cta.recordTypeId) && cta.CN_Status__c != oldCta.CN_Status__c && Constants.CN_CTA_STATUS_READY_FOR_APPROVAL.equals(cta.CN_Status__c)) {
                ctaList.add(cta);
            }
        }
        if(ctaList.size() > 0) {
            populateApprover(ctaList);
        }
    }

    public void populateApprover(List<CN_Credit_Term_Application__c> ctaList) {
        CN_Approve_Process_Settings__c settings = CN_Approve_Process_Settings__c.getInstance();
        Set<String> ownerIdSet = new Set<String>();
        for(CN_Credit_Term_Application__c cta : ctaList) {
            ownerIdSet.add(cta.CN_Account_OwnerId__c);
        }
		List<User> ownerList = [SELECT Id,
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
                               WHERE Id in: ownerIdSet];
        Map<Id, User> ownerMap = new Map<Id, User>(ownerList);
        for(CN_Credit_Term_Application__c cta : ctaList) {
            
            cta.CN_Approver_2__c = null;
            cta.CN_Approver_1__c = null;
            cta.CN_Approver_3__c = null;

            User owner = ownerMap.get(cta.CN_Account_OwnerId__c);
            Map<String, String> titleUserIdMap = new Map<String, String>();
            if(String.isNotBlank(owner.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Title, owner.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Title, owner.Manager.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Manager.Title, owner.Manager.Manager.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.Manager.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Manager.Manager.Title, owner.Manager.Manager.Manager.ManagerId);
            }
            if(String.isNotBlank(owner.Manager.Manager.Manager.Manager.ManagerId)) {
                titleUserIdMap.put(owner.Manager.Manager.Manager.Manager.Manager.Title, owner.Manager.Manager.Manager.Manager.ManagerId);
            }
            titleUserIdMap.put(Constants.CN_USER_TITLE_CEO, settings.CN_CEO_UserID__c);
            titleUserIdMap.put(Constants.CN_USER_TITLE_CFO, settings.CN_CFO_UserID__c);

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
            
            String nature = cta.CN_Nature_Of_Request__c;
            Decimal paymentDays = CN_Payment_Term_Check__mdt.getInstance(cta.CN_Payment_Term_Negotiated__c + '_' + cta.CN_Reference_Day__c).CN_Payment_Days__c;
            Decimal creditLimit = cta.CN_Credit_Limit_Incl_VAT__c;
            String approver2Ttile = '';
            Boolean hasApprover3 = false;

            if(Constants.CN_CTA_NATURE_OF_REQUEST_REGULAR.equals(nature)) {
                if(paymentDays <= 30) {
                    approver2Ttile = Constants.CN_USER_TITLE_CM;
                } else if(30 < paymentDays && paymentDays <= 60) {
                    approver2Ttile = Constants.CN_USER_TITLE_CD;
                    hasApprover3 = true;
                } else if(60 < paymentDays) {
                    approver2Ttile = Constants.CN_USER_TITLE_CEO;
                }
            } else if(Constants.CN_CTA_NATURE_OF_REQUEST_TM1.equals(nature)) {
                if(paymentDays <= 60) {
                    if(creditLimit <= 20000) {
                        approver2Ttile = Constants.CN_USER_TITLE_RM;
                    } else if(20000 < creditLimit && creditLimit <= 100000) {
                        approver2Ttile = Constants.CN_USER_TITLE_CM;
                    } else if(100000 < creditLimit && creditLimit <= 200000) {
                        approver2Ttile = Constants.CN_USER_TITLE_CD;
                    } else if(200000 < creditLimit) {
                        approver2Ttile = Constants.CN_USER_TITLE_CEO;
                    }
                } else if(60 < paymentDays) {
                    approver2Ttile = Constants.CN_USER_TITLE_CEO;
                }
            } else if(Constants.CN_CTA_NATURE_OF_REQUEST_TM2.equals(nature)) {
                if(paymentDays <= 20) {
                    if(creditLimit <= 10000) {
                        approver2Ttile = Constants.CN_USER_TITLE_RM;
                    } else if(10000 < creditLimit) {
                        approver2Ttile = Constants.CN_USER_TITLE_CD;
                    }
                } else if(20 < paymentDays) {
                    approver2Ttile = Constants.CN_USER_TITLE_CEO;
                }
            } else if(Constants.CN_CTA_NATURE_OF_REQUEST_NOC.equals(nature)) {
                if(paymentDays <= 30) {
                    if(creditLimit <= 50000) {
                        approver2Ttile = Constants.CN_USER_TITLE_CM;
                    } else if(50000 < creditLimit && creditLimit <= 100000) {
                        approver2Ttile = Constants.CN_USER_TITLE_CD;
                    } else if(10000 < creditLimit) {
                        approver2Ttile = Constants.CN_USER_TITLE_CEO;
                    }
                } else if(30 < paymentDays) {
                    approver2Ttile = Constants.CN_USER_TITLE_CEO;
                }
            }

            cta.CN_Approver_1__c = settings.CN_Finance_AR_UserId__c;
            if(String.isNotBlank(owner.Title)) {
                cta.CN_Approver_2__c = titleUserIdMap.get(approver2Ttile);
            }
            if(hasApprover3) {
                cta.CN_Approver_3__c = titleUserIdMap.get(Constants.CN_USER_TITLE_CFO);
            }
            // Set The Last Stand Approver
            if(cta.CN_Approver_2__c == null) {
                cta.CN_Approver_2__c = getLatestApprover(approver2Ttile, levelMap, levelList);
            }
        }
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
}
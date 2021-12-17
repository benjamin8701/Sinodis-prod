/**************************************************************************************************
 * Name           : CN_Account_Prevent_Edit_Approved_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-11-30
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Prevent_Edit_Approved_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
    }

    public void handleBeforeUpdate() {
        Map<String, Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        List<CN_Account_Prevent_Edit_Field__mdt> accFieldsMDTList =  CN_Account_Prevent_Edit_Field__mdt.getAll().values();
        
        Map<String,String> fieldNameProfileNameMap = new Map<String,String>();
        Set<String> allFields = new Set<String>();
        Set<String> allowedEditFields = new Set<String>();
        
        
        for(String fieldName: mfields.keySet()) {
            Schema.DescribeFieldResult fResult = mfields.get(fieldName).getDescribe();
            if(fResult.isCustom() && fResult.isUpdateable()) {
                allFields.add(fieldName);
            }
            /*
            if(fResult.isCustom() && !fResult.isCalculated() && fResult.isUpdateable()) {
                allFields.add(fieldName);
            }
			*/
        }
        allFields.add('cn_upload_bank_information_fapiao_no__c');
        allFields.add('cn_upload_business_license_no__c');
        allFields.add('cn_upload_contract_no__c');
        allFields.add('cn_upload_hygiene_certificate_no__c');
        allFields.add('cn_numbers_of_ship_to_party__c');
        allFields.add('name');
        allFields.add('ownerid');
        allFields.add('recordtypeid');
        allFields.add('description');
        
        for(CN_Account_Prevent_Edit_Field__mdt accFieldsMDT : accFieldsMDTList){
            //这里不填的话一定是空吗
            
            
            if(accFieldsMDT.Allow_Edit_Profile__c==null){
                allowedEditFields.add(accFieldsMDT.Field_Name__c.toLowerCase()); //如果有profile的不加到任何条件都通过的里面，需要进一步判断profile是否符合
            }else{
                fieldNameProfileNameMap.put(accFieldsMDT.Field_Name__c.toLowerCase(), accFieldsMDT.Allow_Edit_Profile__c);
            }
        }
        //有没有要加进去的标准字段
       
		system.debug('allowedEditFields:	'+ allowedEditFields);
        for(Account acc: (List<Account>)Trigger.new) {
            Account oldAcc = (Account)Trigger.oldMap.get(acc.Id);
            if(Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED.equals(acc.CN_Account_Status__c) && Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED.equals(oldAcc.CN_Account_Status__c)) {
                if(checkFieldsChanged(allFields,allowedEditFields, acc, oldAcc,fieldNameProfileNameMap)) {
                    acc.addError(System.Label.CN_Account_Prevent_Edit_Approved_MSG);
                }
            } 
        }

    }

    public Boolean checkFieldsChanged(Set<String> fields,Set<String> allowedEditFields, Account newAcc, Account oldAcc,Map<String,String> fieldNameProfileNameMap) {
        Boolean isChanged = true;
        
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = profileList[0].Name;
        
        for(String field: fields) {
            if(newAcc.get(field) != oldAcc.get(field)) {
                if(allowedEditFields.contains(field)){
                    system.debug('field:    ' + field);
                    isChanged = false;
                	break;
                }else if(fieldNameProfileNameMap.get(field)!=null && (fieldNameProfileNameMap.get(field).contains(myProflieName) || myProflieName.equals(Constants.CN_PROFILE_NAME_INTEGRATION))){
                    system.debug('field(myProflieName):    ' + field);
                    isChanged = false;
                	break;
                }
            }
        }
        return isChanged;
    }
}
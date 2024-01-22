/**************************************************************************************************
 * Name           : CN_CR_Write_Back_To_Contact_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica
 * Create Date    : 2021-05-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Write_Back_To_Contact_Handler implements Triggers.Handler{
    public static Boolean isTriggerRun = true;
    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            if(CN_CR_Write_Back_To_Contact_Handler.isTriggerRun) {
                handleAfterUpdate();
            }
        }
    }
    public void handleAfterUpdate() {
        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT).getRecordTypeId();
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.New){
            if(cr.RecordTypeId == crRTId && Constants.CN_CR_STATUS_APPROVALED.equals(cr.CN_Change_Request_Status__c)){
                crList.add(cr);
            }
        }
        if(crList.size()>0){
            populateContactFields(crList);
            CN_CR_Write_Back_To_Contact_Handler.isTriggerRun =false;
        }
    }
    public void populateContactFields(List<CN_Change_Request__c> crList){    
        Map<String, CN_Change_Request_Fields_Mapping__mdt> crmSettingMap = CN_Change_Request_Fields_Mapping__mdt.getAll(); 
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldNameOldfieldNameMap = new Map<String, String>();
        List<Contact> conList  = new List<Contact>();
        for(String crmSettingId : crmSettingMap.keyset()) {
            if('Contact'.equalsIgnoreCase(crmSettingMap.get(crmSettingId).CN_Object_Name__c) == False){
                continue;
            }
            CN_Change_Request_Fields_Mapping__mdt crmSetting = crmSettingMap.get(crmSettingId);
            String fieldName = crmSetting.CN_Field_Name__c;
            String fieldNameOld = crmSetting.CN_Change_Request_Field_Name__c;
            String fieldNameNew = 'New_' + fieldNameOld;
            fieldMap.put(fieldNameOld, fieldNameNew);       
            fieldNameOldfieldNameMap.put(fieldNameOld, fieldName);
        }

        Map<String, Contact> mapBillDel = new Map<String, Contact>();
        Map<String, Contact> mapBillNew = new Map<String, Contact>();

        for(CN_Change_Request__c cr : crList){
            Set<String> changedFieldSet = new Set<String>();
            for(String oldFieldName : fieldMap.keySet()) {
                if(cr.get(oldFieldName) != cr.get(fieldMap.get(oldFieldName))) {
                    if (oldFieldName == 'CN_Contact_Type__c') {
                        String fieldOldValue = (String)cr.get(oldFieldName);
                        String fieldNewValue = (String)cr.get(fieldMap.get(oldFieldName));
                        if (String.isNotBlank(fieldOldValue) && fieldOldValue.contains('01') 
                            && (String.isBlank(fieldNewValue) || !fieldNewValue.contains('01'))) {
                            mapBillDel.put(cr.New_CN_Contact_License_Name__c, null);
                        }
                        else if ((String.isBlank(fieldOldValue) || !fieldOldValue.contains('01'))
                            && String.isNotBlank(fieldNewValue) && fieldNewValue.contains('01')) {
                            mapBillNew.put(cr.New_CN_Contact_License_Name__c, null);
                        }
                    }
                    changedFieldSet.add(oldFieldName);
                }
            }
            if(changedFieldSet.size()>0){
                Contact con = new Contact();
                con.Id = cr.CN_Contact__c;
                con.CN_Change_Request__c = cr.Id;
                //add by leo 2023.12.10 CN_Has_CR_Need_Sync must be False when sync Contact to E-Commerce
                if (cr.CN_Sync_Status__c == Constants.CN_CR_SYNC_STATUS_NO_NEED_TO_SYNC) {
                    con.CN_Has_CR_Need_Sync__c = false;
                }else {
                    con.CN_Has_CR_Need_Sync__c = true;
                }
                //add by leo 2023.12.10 CN_Has_CR_Need_Sync must be False when sync Contact to E-Commerce
                for(String oldFieldName : changedFieldSet){
                    con.put(fieldNameOldfieldNameMap.get(oldFieldName),cr.get(fieldMap.get(oldFieldName)));
                }
                if (mapBillDel.containsKey(cr.New_CN_Contact_License_Name__c)) {
                    mapBillDel.put(cr.New_CN_Contact_License_Name__c, con);
                }
                else if (mapBillNew.containsKey(cr.New_CN_Contact_License_Name__c)) {
                    mapBillNew.put(cr.New_CN_Contact_License_Name__c, con);
                }
                else {
                    conList.add(con);
                }
            }
        }
        
        System.debug('crList: ' + crList.size());
        System.debug('mapBillNew: ' + mapBillNew.size());
        System.debug('mapBillDel: ' + mapBillDel.size());

        if (mapBillNew.size() > 0) {
            Map<String, Contact> mapBillNow = new Map<String, Contact>();
            Set<String> setIds = mapBillNew.keySet();

            List<Contact> ltCons = [SELECT Id,AccountId,CN_Contact_Type__c
                FROM Contact
                WHERE CN_Contact_Type__c INCLUDES ('01') AND AccountId IN :mapBillNew.keySet()];

            System.debug('mapBillNew.keySet(): ' + mapBillNew.keySet());
            System.debug('ltCons.size(): ' + ltCons.size());
            System.debug('ltCons: ' + ltCons);

            for (Contact item : ltCons) {
                mapBillNow.put(item.AccountId, item);
            }

            for(String accountCode : mapBillNew.keySet()) {
                Contact conNew = mapBillNew.get(accountCode);
                conList.add(conNew);
                
                Contact conNow = mapBillNow.get(accountCode);
                if (mapBillDel.containsKey(accountCode)) {
                    Contact conDel = mapBillDel.get(accountCode);
                    conDel.CN_Contact_Type__c = conDel.CN_Contact_Type__c.replace('01', '');
                }
                else if (conNow != null && conNow.Id != conNew.Id) {
                    conNow.CN_Contact_Type__c = conNow.CN_Contact_Type__c.replace('01', '');
                    conList.add(conNow);
                }
            }
        }

        if (mapBillDel.size() > 0) {
            for(String accountCode : mapBillDel.keySet()) {
                Contact con = mapBillDel.get(accountCode);
                if (mapBillNew.containsKey(accountCode) == false) {
                    con.CN_Contact_Type__c += ';01;';
                }
                conList.add(con);
            }
        }
        
        System.debug('conList: ' + conList);

        if(conList.size()>0) {
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList = Database.update(conList, dml);
        }         
    }
}
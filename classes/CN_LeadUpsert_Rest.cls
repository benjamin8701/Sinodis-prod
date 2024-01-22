/*
 * ************************************************************************************************
 * Name : CN_LeadUpsert_Rest
 * Object :
 * Requirement :LD-001
 * Target :
 * Refer classes :
 * Author :
 * Create Date :
 * Modify History :
 * ************************************************************************************************
 */
@RestResource(urlMapping='/LeadUpsert')
global class CN_LeadUpsert_Rest {

    private static Set<String> SET_RequireFields = new Set<String> {
        'company',
        'firstName',
        'lastName',
        'category',
        'leadSource',
        'wechatId',
        'mobilePhone',
//        'salutation',
        'province',
        'city',
        'street',
        'zip',
        'mgContactID',
        'mgAccountID',
        'uniqueId'
    };

    private static Map<String,String> MAP_Fields = new Map<String,String> {
        'company'       => 'Company',
        'firstName'     => 'FirstName',
        'lastName'      => 'LastName',
        'category'      => 'CN_Customer_Category__c',
        'leadSource'    => 'LeadSource',
        'wechatId'      => 'CN_Wechat_ID__c',
        'mobilePhone'   => 'MobilePhone',
        'companyId'     => 'CN_Company_ID__c',
        'invitationCode'=> 'CN_Invitation_Code__c',
        'email'         => 'Email',
        'phone'         => 'Phone',
        'website'       => 'Website',
        'salutation'    => 'Salutation',
        'businessVolume'        => 'CN_Volume_Size_of_Lead__c',
        'companyDescription'    => 'Description',
        'province'      => 'CN_Province__c',
        'city'          => 'CN_City__c',
        'street'        => 'CN_Street__c',
        'zip'           => 'CN_Zip_Postal_Code__c',
        'mgContactID'   => 'CN_MG_Contact_ID__c',
        'mgAccountID'   => 'CN_MG_Account_ID__c',
        'uniqueId'      => 'CN_UniqueId__c',
        'foodExperienceLicense'  => 'CN_Food_Experience_License__c',
        'bankInformation'        => 'CN_Bank_Information__c',
        'businessLicense'        => 'CN_Business_License__c',
        'storeNumber'            => 'CN_Store_Number__c',
        'invitatorName'          => 'CN_Invitator_Name__c',
        'invitatorPhoneNumber'   => 'CN_Invitator_Phone_Number__c'
    };

    private static Map<String, Map<String,String>> MAP_ConvertFields = new Map<String, Map<String,String>> {
        'city'	                => new Map<String,String>{'targetField' => 'ID','object'=>'CN_City__c','field'=>'CN_City_Code__c'},
        'province'	            => new Map<String,String>{'targetField' => 'ID','object'=>'CN_Province__c','field'=>'Province_Code__c'}
    };

    private static Map<String,String> MAP_UrlConvertFields = new Map<String,String> {
        'CN_Food_Experience_License__c'    =>   'Food Experience License',
        'CN_Bank_Information__c'           =>   'Bank Information',
        'CN_Business_License__c'           =>   'Business License'
    };

    @HttpPost
    global static void post() {

        Map<String, Object> result = new Map<String, Object>();
        CN_HelperClass_WS.WS_Log log = new CN_HelperClass_WS.WS_Log();
        System.debug(JSON.serialize(RestContext.request));
        String strBody;
        try {
            strBody = RestContext.request.requestBody.toString();
            log.SetRequest(strBody);
            Map<String,Object> mapBody = (Map<String,Object>)JSON.deserializeUntyped(strBody);
            if (mapBody.containsKey('datas') == false) {
                throw new JSONException('[datas] cannot be null or empty');
            }
            List<Map<String,Object>> ltDatas = new List<Map<String,Object>>();
            
            for (Object item : (List<Object>)mapBody.get('datas')) {
                ltDatas.add((Map<String,Object>)item);
            }
            if (ltDatas.size() > 2000) {
                throw new JSONException('date size cannot be greater than 2000');
            }

            list<Map<String,Object>> ltRet = new list<Map<String,Object>>();
              //add by Zhang Zhihao 2023/12/26
            for ( Integer i =0; i< ltDatas.size() ;i++) {
              //add by Zhang Zhihao 2023/12/26
                Map<String,Object> item = ltDatas[i];
                string errorMsg = '';
                for (string requireField : SET_RequireFields) {
                    if (item.containsKey(requireField) == false) {
                        errorMsg += 'date must have require field [' + requireField + ']; ';
                    }
                    else if (String.isBlank(String.valueOf(item.get(requireField)))) {
                        errorMsg += 'require field [' + requireField + '] can not be null; ';
                    }
                }
                if (errorMsg != '') {
                    Map<String,Object> mapRet = new Map<String,Object>();
                    Map<String,Object> errData = ltDatas.remove(i);
                    mapRet.put('sfid', null);
                    mapRet.put('errors', errorMsg);
                    mapRet.put('success', false);
                    mapRet.put('uniqueid', errData.get('uniqueId'));
                    ltRet.add(mapRet);
                    i --;
                }
            }




            List<Lead> ltDealData = (List<Lead>)CN_HelperClass_WS.convertAPIMapToSObject('Lead', MAP_Fields,MAP_ConvertFields, ltDatas);

            Map<String, List<Lead>> inviteLeadMap = new Map<String, List<Lead>>();
            List<Lead> noInviteLead = new List<Lead>();

            for(Lead item : ltDealData){
                if(String.isEmpty(item.CN_Invitation_Code__c)){
                    noInviteLead.add(item);
                }else{
                    if (inviteLeadMap.get(item.CN_Invitation_Code__c) == null){
                        inviteLeadMap.put(item.CN_Invitation_Code__c,new List<Lead>());
                    }
                    inviteLeadMap.get(item.CN_Invitation_Code__c).add(item);
                }
            }


            List<User> inviteUserList = [SELECT Id,CN_User_Personnel_Number__c FROM User WHERE CN_User_Personnel_Number__c IN :inviteLeadMap.keySet()];
            Map<String,User> inviteUserMap = new Map<String, User>();
            for(User user:inviteUserList){
                inviteUserMap.put(user.CN_User_Personnel_Number__c,user);
            }

            for (String invite : inviteLeadMap.keySet()) {
                User inviteUser = inviteUserMap.get(invite);
                //delete this record when  invite code can`t mapping employee ,add to none invite code list
                if (inviteUser == null){

                    List<Lead> errLead = inviteLeadMap.get(invite);
                    inviteLeadMap.remove(invite);
                    noInviteLead.addAll(errLead);
                }else{
                    List<Lead> leads = inviteLeadMap.get(invite);
                    for (Lead next : leads) {
                        next.OwnerId = inviteUser.Id;
                    }
                }
            }

            //has invite
            List<Lead> inviteLead = new List<Lead>();
            for (List<Lead> next : inviteLeadMap.values()) {
                inviteLead.addAll(next);
            }
            Database.DMLOptions dmlOptionsInvite = new Database.DMLOptions();
            dmlOptionsInvite.assignmentRuleHeader.useDefaultRule = false;
            dmlOptionsInvite.OptAllOrNone = false;
            List<Database.SaveResult> databaseResultByInvite = Database.insert(inviteLead,dmlOptionsInvite);

            //none invite
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.assignmentRuleHeader.useDefaultRule = true;
            dmlOptions.OptAllOrNone = false;
            List<Database.SaveResult> databaseResult = Database.insert(noInviteLead,  dmlOptions);

            List<CN_Download_By_Url_Info__c> dInfoList = new List<CN_Download_By_Url_Info__c>();
            List<Lead> leads = new List<Lead>();
            leads.addAll(inviteLead);
            leads.addAll(noInviteLead);
            for (Lead next : leads) {
                if(next == null){
                    continue;
                }
                for(String field:MAP_UrlConvertFields.keySet()){
                    if(next.get(field) == null || String.isEmpty(next.get(field).toString())){
                        continue;
                    }
                    CN_Download_By_Url_Info__c dInfo = CN_Download_By_Url_Helper.convert(next.Id,next.Company + '-' + MAP_UrlConvertFields.get(field), next.get(field).toString(),'Lead',field);
                    dInfoList.add(dInfo);
                }
            }

            insert dInfoList;





            System.debug(ltDealData);


            Map<String,String> reMAP_Fields = new Map<String,String>();
            for (String item : MAP_Fields.keySet()) {
                reMAP_Fields.put(MAP_Fields.get(item), item);
            }



            System.debug(JSON.serialize(noInviteLead));
            System.debug(JSON.serialize(databaseResult));
            System.debug(JSON.serialize(inviteLeadMap));
            System.debug(JSON.serialize(databaseResultByInvite));
            for (Integer index = 0; index < databaseResult.size(); index++) {
                Database.SaveResult item = databaseResult[index];
                Object uniqueId = noInviteLead[index].get('CN_UniqueId__c');
                if (item.id != null && noInviteLead[index].Id != item.id) {
                    throw new JSONException('Database.Result map ERROR, Please contact development.');
                }
                Map<String,Object> mapRet = CN_HelperClass_WS.convertDatabaseResultToMap(item.id, item.success, item.errors, uniqueId, reMAP_Fields);
                ltRet.add(mapRet);
            }

           for (Integer index = 0; index < databaseResultByInvite.size(); index++) {
                Database.SaveResult item = databaseResultByInvite[index];
                Object uniqueId = inviteLead[index].get('CN_UniqueId__c');
                if (item.id != null && inviteLead[index].Id != item.id) {
                    throw new JSONException('Database.Result map ERROR, Please contact development.');
                }
                Map<String,Object> mapRet = CN_HelperClass_WS.convertDatabaseResultToMap(item.id, item.success, item.errors, uniqueId, reMAP_Fields);
                ltRet.add(mapRet);
            }



            result.put('retData', ltRet);
            result.put('message', '操作成功');
            result.put('code', 1);
            log.SetResult(1, JSON.serialize(ltRet), '');

        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            result.put('retData', null);
            result.put('message', ex.getMessage()); 
            result.put('code', 0);
            log.SetResult(0, '', ex.getMessage());
        }
        
        log.SetResponse(JSON.serialize(result));
        log.Save();

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Blob responseBody = Blob.valueOf(JSON.serialize(result));
        res.responseBody = responseBody;
    }

    public static void notifyUsers(List<Lead> cnLeadList) {
        Set <String> recipientsIds = new Set <String>();
        String cnCustomNotifyType = Constants.CN_Custom_Notification_API_NAME;

        // Get the Id for our custom notification type
        CustomNotificationType notificationType =
        [SELECT Id, DeveloperName
        FROM CustomNotificationType
        WHERE DeveloperName = :cnCustomNotifyType];

        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(System.Label.CN_Lead_New_Lead_Notification_Title);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);

        // Actually send the notification
        for(Lead lead : cnLeadList) {
            if (lead.Id == null){
                continue;
            }
            notification.setBody(System.Label.CN_Lead_New_Lead_Notification_Body + ' ' + lead.FirstName + ' ' + lead.LastName);
            notification.setTargetId(lead.Id );
            recipientsIds.add(lead.OwnerId);
            notification.send(recipientsIds);
        }
    }
}
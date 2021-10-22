/**************************************************************************************************
 * Name           : CN_Mass_Change_Account_Owner_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Shuqi
 * Create Date    : 2021-08-09
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Mass_Change_Account_Owner_LC_Ctrl {
 
   @AuraEnabled 
    public static user fetchUser(){
       User u = [select id,Name,Profile.Name,username from User where id =: userInfo.getUserId()];
        return u;
    }

    @AuraEnabled
    public static Map<String, Object> searchAccount(Map<String, String> paramMap,Boolean isProcess,String CustCode){

        String UserNumber = paramMap.get('UserNumber');
        String changetype = paramMap.get('changeTypeList');
        String changeUserNumber = paramMap.get('changeUserNumber');
        system.debug('shuqi1');
        String CustomerCode = CustCode;
        isProcess = isProcess == null? false: isProcess;

        List<AccountWrapper> accountWrapperList = new List<AccountWrapper>();
        List<AccountWrapper> accountWrapperListError = new List<AccountWrapper>();
        List<Account> accountListupdate = new List<Account>();
        List<Account> accountChangeRequestList = new List<Account>();
        List<CN_Change_Request__c> changeRequestListNew = new List<CN_Change_Request__c>();
        List<CN_Mass_Change_Log__c> LogList = new List<CN_Mass_Change_Log__c>();
        List<String> customerCodeList = new List<String>();
        List<User> userid = new List<User>(); 
        List<CN_Internal_Employee__c> Financeid = new list<CN_Internal_Employee__c>();
        Map<String,RecordType> RecordTypeMap = new Map<String,RecordType>(); 
        Map<String, String> resultMaps = new Map<String, String>();
        Map<id,Account> accountMap = new Map<id,Account>();
        Map<String,User> userMap = new Map<String,User>();
        Map<String,CN_Internal_Employee__c> financeMap = new Map<String,CN_Internal_Employee__c>();
        
        if((UserNumber !=null || CustomerCode != null) && changetype != null){
            Set<String> selectedFieldsSet = new Set<String> {
                'Id','Name','OwnerId','Owner.CN_User_Personnel_Number__c','Owner.name','CN_Sinodis_Finance_AR__c','CN_Sinodis_Finance_AR__r.Name','recordtype.name',
                'CN_Sinodis_Finance_AR__r.CN_Personnel_Number__c','CN_Account_Status__c','CN_Sync_Status__c','Type',
                'CN_Customer_Code__c','CN_Route_To_Market__c'
            };
            String soqlStr = 'SELECT ' + String.join(new List<String>(selectedFieldsSet), ', ') + ' FROM Account';
            String soqlStrCr = 'Select CN_Account_Name__c, CN_Change_Request_Status__c, CN_Sync_Status__c from CN_Change_Request__c where ( CN_Change_Request_Status__c !=\'Approved\' or ( CN_Change_Request_Status__c = \'Approved\' and CN_Sync_Status__c not in(\'No Need To Sync\', \'Success\') ) ) and CN_Account_Name__c in';
            String soqlStrRecordType = 'Select id, name from RecordType where name in (\'Change Account Owner\',\'Change Account Finance AR\')';

            if( changetype == 'Change Owner' && (CustomerCode == null || CustomerCode == '') && (UserNumber != null || UserNumber != '')) {
                soqlStr = soqlStr + ' WHERE ' + ' Owner.CN_User_Personnel_Number__c = \''+UserNumber+'\'' ;
            }else if( changetype == 'Change Finance AR' && (CustomerCode == null || CustomerCode == '') && (UserNumber != null|| UserNumber!= '')) {
                soqlStr = soqlStr + ' WHERE ' + ' CN_Sinodis_Finance_AR__r.CN_Personnel_Number__c  = \''+UserNumber+'\'' + ' and CN_Customer_Code__c != null';
            }else if( changetype == 'Change Owner' && (CustomerCode != null || CustomerCode != '') && (UserNumber != null && UserNumber != '')){
                CustomerCode = CustomerCode.replaceAll(' ','');
                CustomerCode = CustomerCode.replaceAll('，',',');
                CustomerCode = CustomerCode.toUpperCase();
                customerCodeList = CustomerCode.split(',');
                soqlStr = soqlStr + ' WHERE ' + ' Owner.CN_User_Personnel_Number__c = \''+UserNumber+'\' ' + ' and CN_Customer_Code__c in: customerCodeList' ;
            }else if( changetype == 'Change Finance AR' && (CustomerCode != null || CustomerCode != '') && (UserNumber != null && UserNumber != '')) {
                CustomerCode = CustomerCode.replaceAll(' ','');
                CustomerCode = CustomerCode.replaceAll('，',',');
                CustomerCode = CustomerCode.toUpperCase();
                customerCodeList = CustomerCode.split(',');
                soqlStr = soqlStr + ' WHERE ' + ' CN_Sinodis_Finance_AR__r.CN_Personnel_Number__c  = \''+UserNumber+'\' ' + ' and CN_Customer_Code__c in: customerCodeList' ;
            }else if( changetype == 'Change Owner' && (CustomerCode != null || CustomerCode != '') && (UserNumber == null || UserNumber == '')){
                CustomerCode = CustomerCode.replaceAll(' ','');
                CustomerCode = CustomerCode.replaceAll('，',',');
                CustomerCode = CustomerCode.toUpperCase();
                customerCodeList = CustomerCode.split(',');
                soqlStr = soqlStr + ' WHERE ' + ' CN_Customer_Code__c in: customerCodeList' ;
            }else if( changetype == 'Change Finance AR' && (CustomerCode != null || CustomerCode != '') && (UserNumber == null || UserNumber == '')) {
                CustomerCode = CustomerCode.replaceAll(' ','');
                CustomerCode = CustomerCode.replaceAll('，',',');
                CustomerCode = CustomerCode.toUpperCase();
                customerCodeList = CustomerCode.split(',');
                soqlStr = soqlStr + ' WHERE ' + ' CN_Customer_Code__c in: customerCodeList' ;
            }

            List<Account> accountList = Database.query(soqlStr);
            List<RecordType> RecordTypeList = Database.query(soqlStrRecordType);
            if(RecordTypeList.size()>0){
                for(RecordType rt : RecordTypeList){
                    RecordTypeMap.put(rt.name, rt);
                }
            }         
            
            if( changeUserNumber != '' && changetype == 'Change Owner'){ 
                userid = Database.query('select id,CN_User_Personnel_Number__c,name from User where CN_User_Personnel_Number__c in ( \''+UserNumber+'\' , \''+changeUserNumber+'\') and CN_User_Personnel_Number__c != null');
                for(User ui:userid){
                    userMap.put(ui.CN_User_Personnel_Number__c,ui);
                }
            }
            if( changeUserNumber != '' && changetype == 'Change Finance AR'){ 
                Financeid = Database.query('select id,CN_Personnel_Number__c,name from CN_Internal_Employee__c where CN_Personnel_Number__c in (\''+UserNumber+'\' , \''+changeUserNumber+'\') and CN_Personnel_Number__c != null');
                for(CN_Internal_Employee__c ce : Financeid){
                    financeMap.put(ce.CN_Personnel_Number__c,ce);
                }
            }

            
            if(changetype != 'Change Owner' && changetype != 'Change Finance AR'){
                //返回需要选择change type
                resultMaps = new Map<String, String>();
                resultMaps.put('ErrorComment', 'Please choose Change Type');
                resultMaps.put('Comment', '');
                resultMaps.put('Show', 'Error');
                accountWrapperListError.add(new AccountWrapper(resultMaps));
            }else if((accountList.size() <= 0 || accountList == null) && (CustomerCode == null || CustomerCode == '')){
                //返回未找到相应的Account，请确认输入的员工号正确
                resultMaps = new Map<String, String>();
                if(changetype == 'Change Owner'){
                    resultMaps.put('Owner', userMap.get(UserNumber)?.name);
                }else if(changetype == 'Change Finance AR'){
                    resultMaps.put('Owner', financeMap.get(UserNumber)?.name);
                }
                resultMaps.put('ErrorComment', System.label.CN_Account_Mass_ErrMsg_Check_CurrentUser);
                resultMaps.put('Comment', '');
                resultMaps.put('Show', 'Error');
                accountWrapperListError.add(new AccountWrapper(resultMaps));
            }else if((accountList.size() <= 0 || accountList == null) && CustomerCode != null){
                //返回未找到相应的Account，请确认输入的Customer Code正确
                resultMaps = new Map<String, String>();
                if(changetype == 'Change Owner'){
                    resultMaps.put('Owner', userMap.get(UserNumber)?.name);
                    resultMaps.put('changeuser',userMap.get(changeUserNumber)?.name);
                }else if(changetype == 'Change Finance AR'){
                    resultMaps.put('Owner', financeMap.get(UserNumber)?.name);
                    resultMaps.put('changeuser',financeMap.get(changeUserNumber)?.name);
                }
                resultMaps.put('ErrorComment', System.label.CN_Account_Mass_ErrMsg_Check_AccountCode);
                resultMaps.put('Comment', '');
                resultMaps.put('Show', 'Error');
                accountWrapperListError.add(new AccountWrapper(resultMaps));
            }else if(isProcess == true && (userMap.get(changeUserNumber)==null && financeMap.get(changeUserNumber)==null) || (UserNumber == changeUserNumber && UserNumber != null)  ){
                //返回未找到相应的change User，请确认输入的员工号正确
                resultMaps = new Map<String, String>();
                if(changetype == 'Change Owner'){
                    resultMaps.put('Owner', userMap.get(UserNumber)?.name);
                }else if(changetype == 'Change Finance AR'){
                    resultMaps.put('Owner', financeMap.get(UserNumber)?.name);
                }
                resultMaps.put('ErrorComment', System.label.CN_Account_Mass_ErrMsg_Check_UpdateUser);
                resultMaps.put('Comment', '');
                resultMaps.put('Show', 'Error');
                accountWrapperListError.add(new AccountWrapper(resultMaps));
            }else if(isProcess == false && accountList.size()>0){
                //准备查询返回值
                for (Account accRow : accountList) {
                    resultMaps = new Map<String, String>();
                    resultMaps.put('Id', accRow.Id);
                    resultMaps.put('Name', accRow.Name);
                    resultMaps.put('CN_Customer_Code__c',accRow.CN_Customer_Code__c);
                    resultMaps.put('Type', accRow.CN_Route_To_Market__c);
                    resultMaps.put('OwnerId', accRow.Owner.Name);
                    resultMaps.put('CN_Sinodis_Finance_AR__c', accRow.CN_Sinodis_Finance_AR__r.Name);
                    resultMaps.put('CN_Account_Status__c', accRow.CN_Account_Status__c);
                    resultMaps.put('CN_Sync_Status__c', accRow.CN_Sync_Status__c);
                    if(changetype == 'Change Owner' && userMap.get(changeUserNumber) == null && UserNumber != null){
                        resultMaps.put('Owner', accRow.Owner.Name);
                    	
                    }else if(changetype == 'Change Owner'&&userMap.get(changeUserNumber) != null && UserNumber != null){
                        resultMaps.put('Owner', accRow.Owner.Name);
                    	resultMaps.put('changeuser',userMap.get(changeUserNumber).name);
                    }else if(changetype == 'Change Finance AR' && financeMap.get(changeUserNumber) == null && UserNumber != null){
                        resultMaps.put('Owner', accRow.CN_Sinodis_Finance_AR__r.Name);
                        
                    }else if(changetype == 'Change Finance AR' && financeMap.get(changeUserNumber) != null && UserNumber != null){
                        resultMaps.put('Owner', accRow.CN_Sinodis_Finance_AR__r.Name);
                        resultMaps.put('changeuser',financeMap.get(changeUserNumber).name);
                    }else if(changetype == 'Change Owner'&&userMap.get(changeUserNumber) != null && UserNumber == null){
                    	resultMaps.put('changeuser',userMap.get(changeUserNumber).name);
                    }else if(changetype == 'Change Finance AR' && financeMap.get(changeUserNumber) != null && UserNumber == null){
                        resultMaps.put('changeuser',financeMap.get(changeUserNumber).name);
                    }
                    resultMaps.put('Comment', '');
                    resultMaps.put('Show', 'Result');
                    accountWrapperList.add(new AccountWrapper(resultMaps));
                    system.debug('shuqi++'+changeUserNumber);
                }
            }else if(isProcess == true && accountList.size()>0 && ((changetype == 'Change Owner' && userMap.get(changeUserNumber)!=null) ||(changetype == 'Change Finance AR' && financeMap.get(changeUserNumber)!=null))){
                //
                 for (Account accRow : accountList) {
                    accountMap.put(accRow.Id,accRow);
                    if(accRow.RecordType.name=='Approved Direct'  && accRow.CN_Sync_Status__c != 'Success' && accRow.CN_Account_Status__c == 'Approved'){
                        //需要先同步的account
                        resultMaps = new Map<String, String>();
                        resultMaps.put('Id', accRow.Id);
                        resultMaps.put('Name', accRow.Name);
                        resultMaps.put('CN_Customer_Code__c',accRow.CN_Customer_Code__c);
                        resultMaps.put('Type', accRow.CN_Route_To_Market__c);
                        resultMaps.put('OwnerId', accRow.Owner.Name);
                        resultMaps.put('CN_Sinodis_Finance_AR__c', accRow.CN_Sinodis_Finance_AR__r.Name);
                        resultMaps.put('CN_Account_Status__c', accRow.CN_Account_Status__c);
                        resultMaps.put('CN_Sync_Status__c', accRow.CN_Sync_Status__c);
                		resultMaps.put('Show', 'Result');
                        resultMaps.put('Comment', system.label.CN_Account_Mass_ErrMsg_Notice2);
                        resultMaps.put('Comment3', system.label.CN_Account_Mass_ErrMsg_Notice3);
                        accountWrapperListError.add(new AccountWrapper(resultMaps));
                    }else if((accRow.RecordType.name=='Approved Direct' && accRow.CN_Account_Status__c != 'Approved') || ( accRow.RecordType.name!='Approved Direct')){
                        //可以直接update的数据
                        if(changetype == 'Change Owner' && userMap.get(changeUserNumber)!=null){
                            Account accUp = new Account();
                            accUp.id = accRow.Id;
                            accUp.Ownerid = userMap.get(changeUserNumber).id;
                            accountListupdate.add(accUp);
                            CN_Mass_Change_Log__c chLog = new CN_Mass_Change_Log__c();
                            chLog.CN_AccountId__c = accRow.id;
                            chLog.CN_Change_Type__c = 'Change Owner';
                            chLog.CN_Before_User_Number__c = accountList[0].Owner.CN_User_Personnel_Number__c;
                            chLog.CN_After_User_Number__c = changeUserNumber;
                            logList.add(chLog);
                        }else if(changetype == 'Change Finance AR' && financeMap.get(changeUserNumber)!=null){
                            Account accUp = new Account();
                            accUp.id = accRow.Id;
                            accUp.CN_Sinodis_Finance_AR__c = financeMap.get(changeUserNumber).id;
                            accountListupdate.add(accUp);
                            CN_Mass_Change_Log__c chLog = new CN_Mass_Change_Log__c();
                            chLog.CN_AccountId__c = accRow.Id;
                            chLog.CN_Change_Type__c = 'Change Finance AR';
                            chLog.CN_Before_User_Number__c = accountList[0].CN_Sinodis_Finance_AR__r.CN_Personnel_Number__c;
                            chLog.CN_After_User_Number__c = changeUserNumber;
                            logList.add(chLog);
                        }
                    }else{
                        //需要创建的change request的
                        accountChangeRequestList.add(accRow);
                        if(changetype == 'Change Owner'){
                            CN_Change_Request__c crList = new CN_Change_Request__c();
                            crList.CN_Account_Name__c = accRow.Id;
                            crList.CN_Account_Owner__c = accRow.ownerid;
                            crList.New_CN_Account_Owner__c = userMap.get(changeUserNumber).id;
                            crList.recordtypeid = RecordTypeMap.get('Change Account Owner').id;
                            crList.CN_Change_Request_Status__c = 'Approved' ;
                            crList.CN_External_Id__c = accRow.Id;
                            changeRequestListNew.add(crList);
                            CN_Mass_Change_Log__c chLog = new CN_Mass_Change_Log__c();
                            chLog.CN_AccountId__c = accRow.Id;
                            chLog.CN_Change_Type__c = 'Change Owner';
                            chLog.CN_Before_User_Number__c = accountList[0].Owner.CN_User_Personnel_Number__c;
                            chLog.CN_After_User_Number__c = changeUserNumber;
                            logList.add(chLog);
                        }else if(changetype == 'Change Finance AR'){
                            CN_Change_Request__c crList = new CN_Change_Request__c();
                            crList.CN_Account_Name__c = accRow.Id;
                            crList.CN_Account_Sinodis_Finance_AR__c = accRow.CN_Sinodis_Finance_AR__c;
                            crList.New_CN_Account_Sinodis_Finance_AR__c = financeMap.get(changeUserNumber).id;
                            crList.recordtypeid = RecordTypeMap.get('Change Account Finance AR').id;
                            crList.CN_Change_Request_Status__c = 'Approved' ;
                            crList.CN_External_Id__c = accRow.Id;
                            changeRequestListNew.add(crList);
                            CN_Mass_Change_Log__c chLog = new CN_Mass_Change_Log__c();
                            chLog.CN_AccountId__c = accRow.Id;
                            chLog.CN_Change_Type__c = 'Change Finance AR';
                            chLog.CN_Before_User_Number__c = accountList[0].CN_Sinodis_Finance_AR__r.CN_Personnel_Number__c;
                            chLog.CN_After_User_Number__c = changeUserNumber;
                            logList.add(chLog);
                        }

                    }
                 }

                 String accountIds = '( \''+ String.join(new List<Id>(accountMap.keySet()), '\', \'')+'\')';
                 List<CN_Change_Request__c> changeRequestList = Database.query(soqlStrCr+accountIds);
                 if(changeRequestList.size()>0){
                    for (CN_Change_Request__c crRow : changeRequestList){
                        resultMaps = new Map<String, String>();
                        resultMaps.put('Id', accountMap.get(crRow.CN_Account_Name__c).Id);
                        resultMaps.put('Name', accountMap.get(crRow.CN_Account_Name__c).Name);
                        resultMaps.put('CN_Customer_Code__c',accountMap.get(crRow.CN_Account_Name__c).CN_Customer_Code__c);
                        resultMaps.put('Type', accountMap.get(crRow.CN_Account_Name__c).CN_Route_To_Market__c);
                        resultMaps.put('OwnerId', accountMap.get(crRow.CN_Account_Name__c).Owner.Name);
                        resultMaps.put('CN_Sinodis_Finance_AR__c', accountMap.get(crRow.CN_Account_Name__c).CN_Sinodis_Finance_AR__r.Name);
                        resultMaps.put('CN_Account_Status__c', accountMap.get(crRow.CN_Account_Name__c).CN_Account_Status__c);
                        resultMaps.put('CN_Sync_Status__c', accountMap.get(crRow.CN_Account_Name__c).CN_Sync_Status__c);
                        if(changetype == 'Change Owner'){
                            resultMaps.put('Owner',  accountList[0].Owner.name);
                            resultMaps.put('changeuser',userMap.get(changeUserNumber).name);
                        }else if(changetype == 'Change Finance AR'){
                            resultMaps.put('Owner', accountList[0].CN_Sinodis_Finance_AR__r.name);
                            resultMaps.put('changeuser',financeMap.get(changeUserNumber).name);
                        }
                        resultMaps.put('Comment', System.label.CN_Account_Mass_ErrMsg_Notice);
                        resultMaps.put('Comment3', system.label.CN_Account_Mass_ErrMsg_Notice3);
                        resultMaps.put('Show', 'Result');
                        accountWrapperListError.add(new AccountWrapper(resultMaps));
                    }
                 }else{
                    if(isProcess == True && logList.size()>0){
                        Update accountListupdate;
                        Insert changeRequestListNew;
                        Insert logList;
                    }
                    //建change request
                    resultMaps = new Map<String, String>();
                    resultMaps.put('ErrorComment', System.label.CN_Account_Mass_Notice_Success	);
                    resultMaps.put('Comment', '');
                    resultMaps.put('Show', 'Error');
                    accountWrapperList.add(new AccountWrapper(resultMaps));
                 }

            }

            if(accountWrapperListError.size()>0){
                //有不能直接新建change request的Account
                //accountWrapperListError.add(accountWrapperList);
                Map<String, List<AccountWrapper>> returnMaps = new Map<String, List<AccountWrapper>>{
                    'dataList' => accountWrapperListError
                }; 
                return returnMaps;
            }else if(accountWrapperList.size()>0){
                //1.search返回查询结果
                //2.process的话，新建change request返回结果
                Map<String, Object> returnMaps = new Map<String, Object>{
                    'dataList' => accountWrapperList
                };
                return returnMaps;
            }
        }else{
            Map<String, List<Object>> returnMaps = new Map<String, List<Object>>();
            return returnMaps;
        }
        Map<String, List<Object>> returnMaps = new Map<String, List<Object>>();
        return returnMaps;
    }
	public static Map<String, Map<String, String>> getTitle(List<String> objList) {
		Map<String, List<String>> objMap = new Map<String, List<String>>();
		for (String objName : objList) {
	        objMap.put(objName, new List<String>());
	    }
        return getTitle(objMap);
    }
    @AuraEnabled
    public static Map<String, Map<String, String>> getTitleAura(Map<String, List<String>> titleMap) {
        Map<String, Map<String, String>> returnMap = getTitle(titleMap);
        return returnMap;
    }
	public static Map<String, Map<String, String>> getTitle(Map<String, List<String>> objMap) {

		Map<String, Map<String, String>> titleMaps = new Map<String, Map<String, String>>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		List<String> objList = new List<String>();
		if (objMap.size() > 0) {
			for (String objName : objMap.keySet()) {
				Map<String, String> fieldsReturnMap = new Map<String, String>();
				Schema.SObjectType ObjectSchema = schemaMap.get(objName);
				if (ObjectSchema != null) {

					Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();

					List<String> fieldList = objMap.get(objName);

					if (fieldList.size() > 0) {
						for (String fieldName : fieldList) {
							if (fieldMap.containsKey(fieldName)) {
								String fName = fieldMap.get(fieldName).getDescribe().getLabel();
								fieldsReturnMap.put(fieldName, fName);
								titleMaps.put(objName, fieldsReturnMap);
							}
						}
					} else {
						for (String fieldName: fieldMap.keySet()) { 
							String fName = fieldMap.get(fieldName).getDescribe().getLabel();
	          				fieldsReturnMap.put(fieldName, fName);
	          				titleMaps.put(objName, fieldsReturnMap);
	          			}
					}
				}
			}
		}
        return titleMaps;
    }
    class AccountWrapper {

        @AuraEnabled
        public Map<String, String> eventObj { get; set; }

        public AccountWrapper() {

        }

        public AccountWrapper(Map<String, String> eventObj) {
            this.eventObj = eventObj;
        }
    }

}
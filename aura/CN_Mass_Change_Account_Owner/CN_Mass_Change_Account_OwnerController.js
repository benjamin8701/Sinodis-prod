({	
    doInit : function(component, event, helper) {
        let titleMap = {
            "Account":[
                "Id",
                "Name",
                "CN_Customer_Code__c",
                "Ownerid",
                "CN_Sinodis_Finance_AR__c",
                "Type",
                "CN_Account_Status__c",
                "CN_Sync_Status__c"
            ]
        }
        
		let _titlePromiseHandler = helper.titleHelper(component, titleMap);
		_titlePromiseHandler.then(function(_returnMap) {
            _returnMap['titleResults'] = $A.get("$Label.c.CN_Account_Mass_Label_Results");
            _returnMap['titleNotice'] = $A.get("$Label.c.CN_Account_Mass_Label_Notice");
            _returnMap['titleCurrentUser'] = $A.get("$Label.c.CN_Account_Mass_Change_Current");
            _returnMap['titleChangeUser'] = $A.get("$Label.c.CN_Account_Mass_Change_User");
            _returnMap['titleChangeType'] = $A.get("$Label.c.CN_Account_Mass_Change_Type");
            _returnMap['buttonSearch'] = $A.get("$Label.c.CN_Account_Button_Search");
            _returnMap['buttonAssign'] = $A.get("$Label.c.CN_Account_Button_Assign");
            _returnMap['buttonCancel'] = $A.get("$Label.c.CN_Account_Button_Cancel");
            _returnMap['buttonProcess'] = $A.get("$Label.c.CN_Account_Button_Process");
            _returnMap['titleCustomerCode'] = $A.get("$Label.c.CN_Account_Mass_Customer_Code");
			component.set("v.titleMap", _returnMap);
		});
        
	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
	},
        
	jsSearch :function(component, event, helper) {
        component.set("v.showLoading", true);
        component.set("v.showResult", true);
		component.set("v.dataList", [])
        let userProfileName = component.get("v.userInfo.Profile.Name");
        if(userProfileName === "CN Sales MDM") {
            component.set("v.queryParam.changeTypeList", "Change Owner");
        } else if(userProfileName === "CN Finance MDM") {
            component.set("v.queryParam.changeTypeList", "Change Finance AR");
        }
		let _promiseHandler = helper.searchHelper(component, false);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.dataList", _returnValue["dataList"]);
			console.log(_returnValue);
		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
        
        
	},
    jsPreProcess : function(component, event, helper) {   
		component.set("v.showSuccess", true);
    },    
    jsProcess : function(component, event, helper) {
        component.set("v.showLoading", true);
		component.set("v.dataList", [])
		let _promiseHandler = helper.searchHelper(component, true);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.dataList", _returnValue["dataList"]);
            helper.showToast(component, "Success", $A.get("$Label.CN_Mass_Change_Account_Results"), "success");
			console.log(_returnValue);
            component.set("v.showSuccess", false);
		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});

	}, 
    onmousehover : function(component, event, helper) {
        console.log('=onmousehover===');
        component.set('v.isTooltip', true);
    },
    jsCloseAlert : function(component, event, helper) {
		component.set("v.showSuccess", false); 
	}
	
})
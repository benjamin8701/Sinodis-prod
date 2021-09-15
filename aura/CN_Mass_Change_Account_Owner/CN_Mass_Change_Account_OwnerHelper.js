({
	searchHelper : function(component, isProcess) {
        component.set("v.showLoading", true);
        component.set("v.queryParam.UserNumber", this.trimInput(component.get("v.queryParam.UserNumber")));
        component.set("v.queryParam.changeUserNumber", this.trimInput(component.get("v.queryParam.changeUserNumber")));
        component.set("v.queryParam.CustomerCode", this.trimInput(component.get("v.queryParam.CustomerCode")));
        let queryParam = component.get("v.queryParam");
        let action = component.get("c.searchAccount");
        console.log('queryParam' , queryParam["changeTypeList"]);
        action.setParams({
            "paramMap": queryParam,
            "isProcess":isProcess
        });
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				let _state = response.getState();
                if (_state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                	reject(new Error(response.getError()));
                }
            });
            $A.enqueueAction(action);
		});
	},
    titleHelper : function(component, titleMap) {
        let action = component.get("c.getTitleAura");
        action.setParams({
            "titleMap": titleMap
        });
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                let _state = response.getState();
                if (_state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    reject(new Error(response.getError()));
                }
            });
            $A.enqueueAction(action);
        });
    },
    showToast : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    trimInput : function(inputString) {
        if(inputString != null && inputString != undefined && inputString != {} &&  typeof inputString == 'string') {
            return inputString.trim();
        }
        return inputString;
    }
})
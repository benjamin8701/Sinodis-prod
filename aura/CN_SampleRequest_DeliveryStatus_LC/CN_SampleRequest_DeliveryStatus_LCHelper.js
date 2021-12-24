({
    callServerAction : function(component, recordId) {
        //let queryParam = component.get("v.recordId");
        let action = component.get("c.searchSampleRequest");
        action.setParams({
            "recordId": recordId
        });
        console.log("action");
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
    /*showToast : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },*/
})
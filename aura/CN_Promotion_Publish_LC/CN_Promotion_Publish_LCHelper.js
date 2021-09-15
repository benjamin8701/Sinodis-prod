({
    callServerAction : function(component, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                let _state = response.getState();
                if (_state === "SUCCESS") {
                    //resolve(response.getReturnValue());
                    var successMeg = $A.get("{!$Label.c.CN_Promotion_Publish_Success}");
                    alert(successMeg);
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    let errors = response.getError();
                    let message = "Error";
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = JSON.stringify(errors);
                    }
                    reject(new Error(message));
                }
            });
            $A.enqueueAction(action);
        });
    },
})
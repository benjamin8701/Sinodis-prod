({
    callServerAction : function(component, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                let _state = response.getState();
                if (_state === "SUCCESS") {
                    resolve(response.getReturnValue());
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
    format: function(label, args) {
        for (var k in args) {
            label = label.replace("{" + k + "}", args[k]);
        }
        return label;
    }
})
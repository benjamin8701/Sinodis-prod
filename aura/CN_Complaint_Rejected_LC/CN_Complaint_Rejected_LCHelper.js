({
    callServerAction : function(component, action) {
        return new Promise(function(resolve, reject) {
            console.log('inHelper111');
            action.setCallback(this, function(response) {
                console.log('inHelper222');
                let _state = response.getState();
                console.log('inHelper'+response.getState());
                if (_state === "SUCCESS") {
                    //console.log('returnvalue'+response.getReturnValue());
                    //resolve(response.getReturnValue());
                    resolve('123123');
                } else {
                    console.log('returnERROR');
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
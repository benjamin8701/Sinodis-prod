({

    closeModal:function(component,event,helper){        
        $A.get("e.force:closeQuickAction").fire();
    },
    notifyFin:function(component,event,helper){
        
        helper.sendEmail(component,event,helper);
             
    },
})
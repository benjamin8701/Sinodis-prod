({
	closeModal:function(component,event,helper){        
        $A.get("e.force:closeQuickAction").fire();
    },
    confirmAll:function(component,event,helper){
          
        helper.doAction(component,event,helper);             
    },
})
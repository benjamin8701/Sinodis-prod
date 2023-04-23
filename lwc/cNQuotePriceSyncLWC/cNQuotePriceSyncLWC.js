import { LightningElement ,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import CN_Quote_Notice_Fin_And_Send_To_SAP from '@salesforce/label/c.CN_Quote_Notice_Fin_And_Send_To_SAP';
import CN_Quote_Notice_Finance_Title from '@salesforce/label/c.CN_Quote_Notice_Finance_Title';
import CN_Quote_Send_To_SAP_ErrMsg_Failed_Retry from '@salesforce/label/c.CN_Quote_Send_To_SAP_ErrMsg_Failed_Retry';
import CN_Quote_Send_And_Notify_Success_Msg from '@salesforce/label/c.CN_Quote_Send_And_Notify_Success_Msg';

import CN_Quote_Name from '@salesforce/label/c.CN_Quote_Name';

import getQuoteInfoAndCheck from '@salesforce/apex/CN_Quote_Send_To_SAP_LC_Ctrl.getQuoteInfoAndCheck';
import sendQuote from '@salesforce/apex/CN_Quote_Send_To_SAP_LC_Ctrl.sendQuote';
import sendSyncAndNotifyEmail from '@salesforce/apex/CN_Quote_Finance_Notice_LC_Ctrl.sendSyncAndNotifyEmail';
import upateQuoteIsNotifyFinance from '@salesforce/apex/CN_Quote_Send_To_SAP_LC_Ctrl.upateQuoteIsNotifyFinance';




const showToast = (variant, mode, title, message) => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        mode: mode,
        variant: variant
    });
    return event;
}
export default class CNQuoteNoticeFinanceLWC extends LightningElement {

    @api recordId = '';

    isLoading = false;
    isBtnDisabled = true;
    
    errorMsg = '';
    hearderMessage;
    @track modalContentMessage;
    @track modalContentMessageRetry = '';
    @track modalContentMessageEffectiveChanged = ''

    constructor(){
        super();
        this.startLoading();
        this.hearderMessage = '...';
        this.modalContentMessage = '...';
    }

    handleCloseModal(){
        const closeActionEvent = new CustomEvent('close_action');
        this.dispatchEvent(closeActionEvent);
    }

    async handleConfirm(){
        this.startLoading();
        try {
            const result_Sync = await sendQuote({recordId: this.recordId});
            let isSendSuccess = result_Sync["isSendSuccess"];
            let qliNeedToSendCnt = result_Sync["qliNeedToSendCnt"];
            if(isSendSuccess) {
                // show toast CN_Quote_Deal_Success_Msg
                const result_Email = await sendSyncAndNotifyEmail({QuoteId: this.recordId});
                const result_NotifyFinance = await upateQuoteIsNotifyFinance({recordId: this.recordId});
                this.showSuccessMessage(this.format(CN_Quote_Send_And_Notify_Success_Msg,[CN_Quote_Name,qliNeedToSendCnt]));
                this.handleCloseModal();
            } else {
                let errorMessage = result_Sync["errorMessage"];
                this.showErrorMessage(errorMessage);
                this.modalContentMessage = errorMessage;
                this.modalContentMessageRetry = CN_Quote_Send_To_SAP_ErrMsg_Failed_Retry;
                this.isBtnDisabled = false;
            }
            this.stopLoading();
        } catch (error) {
            if (error.body && error.body.message) {
                this.showErrorMessage(error.body.message);
            } else {
                this.showErrorMessage(error.message);
            }
            // show toast
            //这里没有放header会不会有值，应该不会
            this.modalContentMessage = errorMsg;
            this.isBtnDisabled = true;
            this.stopLoading();
        }
    }

    showErrorMessage(errorMessage){
        this.stopLoading();
        this.dispatchEvent(showToast('error','sticky','Failed!',errorMessage));
    }

    showSuccessMessage(successMessage){
        this.dispatchEvent(showToast('success','pester','Success',successMessage));
    }

    startLoading(){
        this.isLoading = true;
    }

    stopLoading(){
        this.isLoading = false;
    }

    async connectedCallback() {
        if(this.recordId) {
            console.log("connectedCallback");
            try{
                const result = await getQuoteInfoAndCheck({ recordId: this.recordId });
                let errorMsg = result["errorMsg"];
                let hasCreatePermission = result["hasCreatePermission"];
                let modalContentMessageEffectiveChanged = result["modalContentMessageEffectiveChanged"];
                this.isBtnDisabled = !hasCreatePermission;
                let modalContentMessage = "";
                let hearderMessage = this.format(CN_Quote_Notice_Finance_Title,[CN_Quote_Name]);  //这里其他的应该也没给header
                console.log('errorMsg:  ' + errorMsg);
                if(errorMsg != null && errorMsg != undefined && errorMsg != {} && errorMsg != "") {
                    modalContentMessage = errorMsg;
                    this.isBtnDisabled = true;
                } else {
                    if(!hasCreatePermission){
                        modalContentMessage = CN_Quote_No_Permission;
                    }else{
                        modalContentMessage = this.format(CN_Quote_Notice_Fin_And_Send_To_SAP,[CN_Quote_Name]);
                        this.modalContentMessageEffectiveChanged = modalContentMessageEffectiveChanged;
                    }
                }
                this.hearderMessage = hearderMessage;   //这里其他的header位置应该不对
                this.modalContentMessage = modalContentMessage; //这里其他的modalContentMessage位置应该不对
                //refresh the record page
                getRecordNotifyChange([{ recordId: this.recordId }]);
                this.stopLoading();
            } catch(error) {
                let hearderMessage = this.format(CN_Quote_Notice_Finance_Title,[CN_Quote_Name]);  //这里其他的应该也没给header
                if (error.body && error.body.message) {
                    console.error('Apex method threw an AuraHandledException:', error.body.message);
                    this.showErrorMessage(error.body.message);
                    this.modalContentMessage= error.body.message;
                } else {
                    console.error(error.message, error.stack);
                    this.showErrorMessage(error.message);
                    this.modalContentMessage= error.message;
                }
                this.hearderMessage = hearderMessage;
                this.stopLoading();
            }
        }
    }
    format(label,args){
        for (var k in args) {
            label = label.replace("{" + k + "}", args[k]);
        }
        return label;
    }
}
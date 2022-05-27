<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_Document_Upload_Notification</fullName>
        <description>CN_Document_Upload_Notification</description>
        <protected>false</protected>
        <recipients>
            <field>CN_Finance_MDM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Document_Uploaded</template>
    </alerts>
    <fieldUpdates>
        <fullName>CN_Document_Populate_FinMDM</fullName>
        <field>CN_Finance_MDM_Email__c</field>
        <formula>CN_Account__r.CN_Approver_6__r.Email</formula>
        <name>CN_Document_Populate_FinMDM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Document_Populate_FinMDM</fullName>
        <actions>
            <name>CN_Document_Populate_FinMDM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,   RecordType.DeveloperName = &quot;CN_Document&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CN_Document_Upload_Notification</fullName>
        <actions>
            <name>CN_Document_Upload_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CN_Document__c.CN_Is_File_Upload__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>CN_Document__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Document</value>
        </criteriaItems>
        <criteriaItems>
            <field>CN_Document__c.CN_Document_Type__c</field>
            <operation>equals</operation>
            <value>Business License,Fapiao Information,Hygiene Certificate,Contract</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

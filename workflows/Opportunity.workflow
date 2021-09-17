<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_Opportunity_Created_Notification</fullName>
        <description>CN Opportunity Created Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Opportunity_Created_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>CN_Opp_Set_Close_Date</fullName>
        <field>CloseDate</field>
        <formula>TODAY() + 90</formula>
        <name>CN_Opp_Set_Close_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Opp_Set_Close_Date</fullName>
        <actions>
            <name>CN_Opp_Set_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Opportunity&apos;, NOT(CN_Is_Manual__c) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CN_Opportunity_Created_Notification</fullName>
        <actions>
            <name>CN_Opportunity_Created_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CN_Created_By_Others__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

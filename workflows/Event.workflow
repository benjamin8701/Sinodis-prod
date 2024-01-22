<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_Notify_Chef_Customer_Visit_By_Email</fullName>
        <description>Notify chef customer visit by email</description>
        <protected>false</protected>
        <recipients>
            <recipient>CN_Customer_Visit_Recipient_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Chef_Customer_Visit_Created</template>
    </alerts>
    <fieldUpdates>
        <fullName>CN_Event_Populate_Status_Completed</fullName>
        <field>CN_Visit_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>CN_Event_Populate_Status_Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Event_Populate_Status</fullName>
        <actions>
            <name>CN_Event_Populate_Status_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(      $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,   RecordType.DeveloperName = &quot;CN_Visit&quot;,    ISCHANGED(CN_Meeting_MInutes__c),   NOT(ISBLANK(CN_Meeting_MInutes__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

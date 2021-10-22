<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_Contact_Synced</fullName>
        <description>Contact has been Synced to SAP.</description>
        <protected>false</protected>
        <recipients>
            <field>CN_FinAR_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Contact_Synced</template>
    </alerts>
    <fieldUpdates>
        <fullName>CN_Contact_Clear_Convert_From</fullName>
        <field>CN_Converted_From__c</field>
        <name>CN_Contact_Clear_Convert_From</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Contact_Clear_Convert_From</fullName>
        <actions>
            <name>CN_Contact_Clear_Convert_From</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Contact&apos;, NOT(  ISBLANK(CN_Converted_From__c ) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CN_Contact_Sync_Notification</fullName>
        <actions>
            <name>CN_Contact_Synced</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,   OR(INCLUDES(CN_Contact_Type__c, &quot;01&quot;),INCLUDES(CN_Contact_Type__c, &quot;02&quot;) ),   OR(     AND(       ISCHANGED(CN_Sync_Status__c),       ISPICKVAL(CN_Sync_Status__c , &quot;Success&quot;)      ),     AND(       ISPICKVAL(CN_Sync_Status__c , &quot;Success&quot;),       ISCHANGED(CN_Sync_Time__c)      )   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

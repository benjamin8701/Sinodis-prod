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
    <rules>
        <fullName>CN_Contact_Sync_Notification</fullName>
        <actions>
            <name>CN_Contact_Synced</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,   OR(INCLUDES(CN_Contact_Type__c, &quot;01&quot;),INCLUDES(CN_Contact_Type__c, &quot;02&quot;) ),   OR(     AND(       ISCHANGED(CN_Sync_Status__c),       ISPICKVAL(CN_Sync_Status__c , &quot;Success&quot;)      ),     AND(       ISPICKVAL(CN_Sync_Status__c , &quot;Success&quot;),       ISCHANGED(CN_Sync_Time__c)      )   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

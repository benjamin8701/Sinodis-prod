<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_PRMT_Published_Notification</fullName>
        <description>CN_PRMT_Published_Notification</description>
        <protected>false</protected>
        <recipients>
            <field>CN_CS_Group_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CN_MKT_Group_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CN_Email_Folder/CN_Promotion_Published</template>
    </alerts>
    <rules>
        <fullName>CN_PRMT_Published_Notification</fullName>
        <actions>
            <name>CN_PRMT_Published_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c, BEGINS(RecordType.DeveloperName, &apos;CN&apos;), ISCHANGED(CN_Status__c), ISPICKVAL(CN_Status__c, &quot;Published&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

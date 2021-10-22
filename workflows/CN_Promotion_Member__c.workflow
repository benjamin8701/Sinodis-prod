<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_PRMT_Member_Published_Notification</fullName>
        <description>CN_PRMT_Member_Published_Notification</description>
        <protected>false</protected>
        <recipients>
            <field>CN_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CN_Email_Folder/CN_Promotion_Member_Published</template>
    </alerts>
    <fieldUpdates>
        <fullName>CN_PromotionMember_Set_ExternalID</fullName>
        <field>CN_External_ID__c</field>
        <formula>CN_Account__c + &quot;-&quot; +  CN_Promotion__c</formula>
        <name>CN_PromotionMember_Set_ExternalID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Promotion_Member_To_Pubished</fullName>
        <field>CN_IsPublished__c</field>
        <literalValue>1</literalValue>
        <name>CN_Promotion_Member_To_Pubished</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_PRMT_Member_Published_Notification</fullName>
        <actions>
            <name>CN_PRMT_Member_Published_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(     $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,      BEGINS(RecordType.DeveloperName, &apos;CN&apos;),      ISCHANGED(CN_IsPublished__c),     CN_IsPublished__c     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_PromotionMember_Set_ExternalID</fullName>
        <actions>
            <name>CN_PromotionMember_Set_ExternalID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Promotion_Member&apos;, ISCHANGED( CN_Account__c ) || ISCHANGED( CN_Promotion__c ) || ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Promotion_Member_To_Pubished</fullName>
        <actions>
            <name>CN_PRMT_Member_Published_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CN_Promotion_Member_To_Pubished</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>And(     $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,      BEGINS(RecordType.DeveloperName, &apos;CN&apos;),      ISPICKVAL(CN_Promotion__r.CN_Status__c , &apos;Published&apos;)    )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

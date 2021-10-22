<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_Complaint_Assign_Notification</fullName>
        <description>CN_Complaint_Assign_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Complaint_Assign_Notification</template>
    </alerts>
    <alerts>
        <fullName>CN_Complaint_Assign_Notification_Creator_And_Sales</fullName>
        <description>CN_Complaint_Assign_Notification_Creator_And_Sales</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Complaint_Assign_Notification</template>
    </alerts>
    <alerts>
        <fullName>CN_Complaint_Assign_To_Queue_Alert</fullName>
        <description>CN_Complaint_Assign_To_Queue_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Complaint_Assign_Notification</template>
    </alerts>
    <alerts>
        <fullName>CN_Compliant_Rejected_Notification</fullName>
        <description>CN_Compliant_Rejected_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Compalint_Rejected</template>
    </alerts>
    <alerts>
        <fullName>CN_Compliant_Resolved_Notification</fullName>
        <description>CN_Compliant_Resolved_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Complaint_Resolved_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>CN_Complaint_Assign_To_CS</fullName>
        <field>OwnerId</field>
        <lookupValue>CN_CS_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CN_Complaint_Assign_To_CS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Complaint_Assign_To_QA</fullName>
        <field>OwnerId</field>
        <lookupValue>CN_QA_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CN_Complaint_Assign_To_QA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Complaint_Empty_RejectedDate</fullName>
        <field>CN_Rejected_Date__c</field>
        <name>CN_Complaint_Empty_RejectedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Complaint_Empty_RejectedReason</fullName>
        <field>CN_Reject_Reason__c</field>
        <name>CN_Complaint_Empty_RejectedReason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Complaint_Populate_AcceptedDate</fullName>
        <field>CN_Accepted_Date__c</field>
        <formula>TODAY()</formula>
        <name>CN_Complaint_Populate_AcceptedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Complaint_Populate_RejectedDate</fullName>
        <field>CN_Rejected_Date__c</field>
        <formula>TODAY()</formula>
        <name>CN_Complaint_Populate_RejectedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Complaint_Populate_ResolvedDate</fullName>
        <field>CN_Resolved_Date__c</field>
        <formula>TODAY()</formula>
        <name>CN_Complaint_Populate_ResolvedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangePriorityToHigh</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Changes the case priority to high.</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Complaint_Assign_Alert</fullName>
        <actions>
            <name>CN_Complaint_Assign_Notification_Creator_And_Sales</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CN_Complaint_Empty_RejectedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CN_Complaint_Empty_RejectedReason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  RecordType.DeveloperName = &apos;CN_Complaint&apos;,
  OR(
    ISPICKVAL(PRIORVALUE(Status) ,&apos;New&apos;),
    ISPICKVAL(PRIORVALUE(Status) , &apos;Rejected&apos;)
  ),
  ISPICKVAL(Status , &apos;Assigned&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Assign_Notification</fullName>
        <actions>
            <name>CN_Complaint_Assign_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  RecordType.DeveloperName = &apos;CN_Complaint&apos;,
  OR(ISCHANGED( OwnerId ),ISNEW())
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Assign_To_CS</fullName>
        <actions>
            <name>CN_Complaint_Assign_To_Queue_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CN_Complaint_Assign_To_CS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  RecordType.DeveloperName = &apos;CN_Complaint&apos;,
  OR(
    ISPICKVAL(PRIORVALUE(Status) ,&apos;New&apos;),
    ISPICKVAL(PRIORVALUE(Status) , &apos;Rejected&apos;)
  ),
  ISPICKVAL(Status , &apos;Assigned&apos;),
  ISPICKVAL(Reason , &apos;Customer Service&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Assign_To_QA</fullName>
        <actions>
            <name>CN_Complaint_Assign_To_Queue_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CN_Complaint_Assign_To_QA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  RecordType.DeveloperName = &apos;CN_Complaint&apos;,
  OR(
    ISPICKVAL(PRIORVALUE(Status) ,&apos;New&apos;),
    ISPICKVAL(PRIORVALUE(Status) , &apos;Rejected&apos;)
  ),
  ISPICKVAL( Status, &apos;Assigned&apos;),
  NOT(ISPICKVAL(Reason , &apos;Customer Service&apos;))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Populate_AcceptedDate</fullName>
        <actions>
            <name>CN_Complaint_Populate_AcceptedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,
  RecordType.DeveloperName = &quot;CN_Complaint&quot;,
  ISPICKVAL(Status , &quot;Accepted&quot;),
  ISCHANGED(Status) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Populate_RejectedDate</fullName>
        <actions>
            <name>CN_Complaint_Populate_RejectedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,
  RecordType.DeveloperName = &quot;CN_Complaint&quot;,
  ISPICKVAL(Status , &quot;Rejected&quot;),
  ISCHANGED(Status) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Populate_ResolvedDate</fullName>
        <actions>
            <name>CN_Complaint_Populate_ResolvedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,
  RecordType.DeveloperName = &quot;CN_Complaint&quot;,
  ISPICKVAL(Status , &quot;Resolved&quot;),
  ISCHANGED(Status) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Rejected_Notification</fullName>
        <actions>
            <name>CN_Compliant_Rejected_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  RecordType.DeveloperName = &apos;CN_Complaint&apos;, 
  ISPICKVAL( Status , &apos;Rejected&apos;),
  ISCHANGED( Status ) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Complaint_Resolved_Notification</fullName>
        <actions>
            <name>CN_Compliant_Resolved_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  RecordType.DeveloperName = &apos;CN_Complaint&apos;, 
  ISPICKVAL( Status , &apos;Resolved&apos;),
  ISCHANGED( Status ) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

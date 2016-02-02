<#--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

<#assign styleTdVal = "height: 8em; width: 10em; vertical-align: top; padding: 0.5em;">

<#if periods?has_content>
  <#-- Allow containing screens to specify the URL for creating a new event -->
  <#if !newCalEventUrl??>
    <#assign newCalEventUrl = parameters._LAST_VIEW_NAME_>
  </#if>
<@table type="data-list" cellspacing="0" class="+calendar"> <#-- orig: class="basic-table calendar" -->
  <@thead>
  <@tr class="header-row">
    <@th width="1%">&nbsp;</@th>
    <#list periods as day>
      <@th>${day.start?date?string("EEEE")?cap_first}</@th>
      <#if (day_index > 5)><#break></#if>
    </#list>
  </@tr>
  </@thead>
  <#list periods as period>
    <#assign currentPeriod = false/>
    <#if (nowTimestamp >= period.start) && (nowTimestamp <= period.end)><#assign currentPeriod = true/></#if>
    <#assign indexMod7 = period_index % 7>
    <#if indexMod7 = 0>
      <#-- FIXME: rearrange without open/close -->
      <@tr open=true close=false />
        <@td style=styleTdVal>
          <a href="<@ofbizUrl>${parameters._LAST_VIEW_NAME_}?period=week&amp;start=${period.start.time?string("#")}${urlParam!}${addlParam!}</@ofbizUrl>" class="${styles.link_nav_info_desc!}">${uiLabelMap.CommonWeek} ${period.start?date?string("w")}</a>
        </@td>
    </#if>
    <#assign class><#if currentPeriod>current-period<#else><#if (period.calendarEntries?size > 0)>active-period</#if></#if></#assign>
    <@td style=styleTdVal class=class>
      <span class="h1"><a href="<@ofbizUrl>${parameters._LAST_VIEW_NAME_}?period=day&amp;start=${period.start.time?string("#")}${urlParam!}${addlParam!}</@ofbizUrl>">${period.start?date?string("d")?cap_first}</a></span>
      <a class="add-new" href="<@ofbizUrl>${newCalEventUrl}?period=month&amp;form=edit&amp;start=${parameters.start!}&amp;parentTypeId=${parentTypeId!}&amp;currentStatusId=CAL_TENTATIVE&amp;estimatedStartDate=${period.start?string("yyyy-MM-dd HH:mm:ss")}&amp;estimatedCompletionDate=${period.end?string("yyyy-MM-dd HH:mm:ss")}${urlParam!}${addlParam!}</@ofbizUrl>">${uiLabelMap.CommonAddNew}</a>
      <br class="clear"/>

      <#assign maxNumberOfPersons = 0/>
      <#assign maxNumberOfEvents = 0/>
      <#assign ranges = period.calendarEntriesByDateRange.keySet()/>
      <#list ranges as range>
          <#assign eventsInRange = period.calendarEntriesByDateRange.get(range)/>
          <#assign numberOfPersons = 0/>
          <#list eventsInRange as eventInRange>
              <#assign numberOfPersons = numberOfPersons + eventInRange.workEffort.reservPersons?default(0)/>
          </#list>
          <#if (numberOfPersons > maxNumberOfPersons)>
              <#assign maxNumberOfPersons = numberOfPersons/>
          </#if>
          <#if (eventsInRange.size() > maxNumberOfEvents)>
              <#assign maxNumberOfEvents = eventsInRange.size()/>
          </#if>
      </#list>
      <#if (maxNumberOfEvents > 0)>
          ${uiLabelMap.WorkEffortMaxNumberOfEvents}: ${maxNumberOfEvents}<br/>
      </#if>
      <#if (maxNumberOfPersons > 0)>
          ${uiLabelMap.WorkEffortMaxNumberOfPersons}: ${maxNumberOfPersons}<br/>
      </#if>
      <#if parameters.hideEvents?default("") != "Y">
      <#list period.calendarEntries as calEntry>
        <#if calEntry.workEffort.actualStartDate??>
            <#assign startDate = calEntry.workEffort.actualStartDate>
          <#else>
            <#assign startDate = calEntry.workEffort.estimatedStartDate!>
        </#if>

        <#if calEntry.workEffort.actualCompletionDate??>
            <#assign completionDate = calEntry.workEffort.actualCompletionDate>
          <#else>
            <#assign completionDate = calEntry.workEffort.estimatedCompletionDate!>
        </#if>

        <#if !completionDate?has_content && calEntry.workEffort.actualMilliSeconds?has_content>
            <#assign completionDate =  calEntry.workEffort.actualStartDate + calEntry.workEffort.actualMilliSeconds>
        </#if>    
        <#if !completionDate?has_content && calEntry.workEffort.estimatedMilliSeconds?has_content>
            <#assign completionDate =  calEntry.workEffort.estimatedStartDate + calEntry.workEffort.estimatedMilliSeconds>
        </#if>    
        <hr />
        <#if (startDate.compareTo(period.start) <= 0 && completionDate?has_content && completionDate.compareTo(period.end) >= 0)>
          ${uiLabelMap.CommonAllDay}
        <#elseif startDate.before(period.start) && completionDate?has_content>
          ${uiLabelMap.CommonUntil} ${completionDate?time?string.short}
        <#elseif !completionDate?has_content>
          ${uiLabelMap.CommonFrom} ${startDate?time?string.short} - ?
        <#elseif completionDate.after(period.end)>
          ${uiLabelMap.CommonFrom} ${startDate?time?string.short}
        <#else>
          ${startDate?time?string.short}-${completionDate?time?string.short}
        </#if>
        <br />
        ${setRequestAttribute("periodType", "month")}
        ${setRequestAttribute("workEffortId", calEntry.workEffort.workEffortId)}
        ${screens.render("component://workeffort/widget/CalendarScreens.xml#calendarEventContent")}
        <br />
      </#list>
      </#if>
    </@td>

<#--
    <@td valign="top">
      <@table type="fields" width="100%" cellspacing="0" cellpadding="0" border="0">
        <@tr>
          <@td nowrap="nowrap" class="monthdaynumber"><a href="<@ofbizUrl>day?start=${period.start.time?string("#")}<#if eventsParam?has_content>&amp;${eventsParam}</#if>${addlParam!}</@ofbizUrl>"  class="${styles.link_nav_info_number!} monthdaynumber">${period.start?date?string("d")?cap_first}</a></@td>
          <@td align="right"><a href="<@ofbizUrl>EditWorkEffort?workEffortTypeId=EVENT&amp;currentStatusId=CAL_TENTATIVE&amp;estimatedStartDate=${period.start?string("yyyy-MM-dd HH:mm:ss")}&amp;estimatedCompletionDate=${period.end?string("yyyy-MM-dd HH:mm:ss")}${addlParam!}</@ofbizUrl>" class="${styles.link_run_sys!} ${styles.action_add!}">${uiLabelMap.CommonAddNew}</a>&nbsp;&nbsp;</@td>
        </@tr>
      </@table>
      <#list period.calendarEntries as calEntry>
      <@table type="fields" width="100%" cellspacing="0" cellpadding="0" border="0">
        <@tr width="100%">
          <@td class='monthcalendarentry' width="100%" valign='top'>
            <#if (calEntry.workEffort.estimatedStartDate.compareTo(period.start)  <= 0 && calEntry.workEffort.estimatedCompletionDate.compareTo(period.end) >= 0)>
              ${uiLabelMap.CommonAllDay}
            <#elseif calEntry.workEffort.estimatedStartDate.before(period.start)>
              ${uiLabelMap.CommonUntil} ${calEntry.workEffort.estimatedCompletionDate?time?string.short}
            <#elseif calEntry.workEffort.estimatedCompletionDate.after(period.end)>
              ${uiLabelMap.CommonFrom} ${calEntry.workEffort.estimatedStartDate?time?string.short}
            <#else>
              ${calEntry.workEffort.estimatedStartDate?time?string.short}-${calEntry.workEffort.estimatedCompletionDate?time?string.short}
            </#if>
            <br />
            <a href="<@ofbizUrl>WorkEffortSummary?workEffortId=${calEntry.workEffort.workEffortId}${addlParam!}</@ofbizUrl>" class="event">${calEntry.workEffort.workEffortName?default("Undefined")}</a>&nbsp;
          </@td>
        </@tr>
      </@table>
      </#list>
    </@td>
-->
    <#if !period_has_next && indexMod7 != 6>
    <@td colspan="${6 - (indexMod7)}">&nbsp;</@td>
    </#if>
  <#if indexMod7 = 6 || !period_has_next>
  <#-- Cato: FIXME: don't want open/close -->
  <@tr close=true open=false />
  </#if>
  </#list>
</@table>

<#else>
  <@commonMsg type="result">${uiLabelMap.WorkEffortFailedCalendarEntries}!</@commonMsg>
</#if>

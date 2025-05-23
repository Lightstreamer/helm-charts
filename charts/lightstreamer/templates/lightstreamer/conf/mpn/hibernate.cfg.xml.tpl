{{/*
Copyright (C) 2025 Lightstreamer Srl

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{/*
Render the Hibernate configuration file for the MPN module
*/}}
{{- define "lightstreamer.configuration.mpn.hibernate" -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: hibernate_conf-APV-7.4.6. -->

<!DOCTYPE hibernate-configuration PUBLIC
        "-//Hibernate/Hibernate Configuration DTD 3.0//EN"
        "http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">

<hibernate-configuration>

  <session-factory>
  {{- with .Values.mpn.hibernateConfig }}
    {{- with required "mpn.hibernateConfig.connection must be set" .connection }}  

    <property name="connection.driver_class">{{ required "mpn.hibernateConfig.connection.jdbcDriverClass must be set" .jdbcDriverClass }}</property>
    <property name="connection.url">{{ required "mpn.hibernateConfig.connection.jdbcUrl must be set" .jdbcUrl }}</property>
    {{- if not .credentialsSecretRef }}
      {{ fail "mpn.hibernateConfig.connection.credentialsSecretRef must be set" }}
    {{- end }}
    <property name="connection.username">${ls_hibernate_connection_username}</property>
    <property name="connection.password">${ls_hibernate_connection_password}</property>
      {{- if .dialect }}
    <property name="dialect">{{ .dialect }}</property>
      {{- end }}
    {{- end }} {{/* with .connection */}}

    {{- range $propertyKey, $propertyValue := .optionalConfiguration }}
    <property name={{ $propertyKey | quote }}>{{ $propertyValue }}</property>
    {{- end }}

    <!-- Mapping files: these paths are relative to the current directory.
         If the Server has been started with its scripts, the samples paths
         here under are correct. But if it has been started with cron or another
         scheduler they may need to be fixed. -->
    <mapping file="../../conf/mpn/Module.hbm.xml"/>
    <mapping file="../../conf/mpn/Command.hbm.xml"/>
    <mapping file="../../conf/mpn/Device.hbm.xml"/>
    <mapping file="../../conf/mpn/Subscription.hbm.xml"/>
    <mapping file="../../conf/mpn/SubscriptionItem.hbm.xml"/>
  {{- end }} {{/* with Values.mpn.hibernateConfig */}}
  </session-factory>

</hibernate-configuration>
{{- end }}

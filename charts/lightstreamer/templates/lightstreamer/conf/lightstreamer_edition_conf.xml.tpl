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
Render the Lightstreamer edition configuration file
*/}}
{{- define "lightstreamer.configuration.edition" -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: edition_conf-APV-7.4.2. -->

<lightstreamer_edition_conf>

<!-- The elements below are used by Lightstreamer Server to setup its own
     configuration. Elements with an empty or blank value are ignored and
     considered as not defined at all. Elements described as "cumulative"
     can be inserted multiple times in the same place. Note that element
     and attribute names are handled in a case insensitive way.
     A very simple variable-expansion feature is available. See the comment
     at the end of this file for full details. -->

<!--
  =================================
  EDITION AND LICENSE CONFIGURATION
  =================================
-->

   <!-- Configure the edition, the optional features, and the type of license
        that should be used to run Lightstreamer Server. -->
   <license>
{{- with required "license must be set" $.Values.license }}

      <!-- #########################################
           CONFIGURE YOUR LIGHTSTREAMER EDITION HERE
           #########################################
           Lightstreamer edition to use.
           To know full details, open the Welcome Page or the Monitoring Dashboard
           (Edition tab) of your running Lightstreamer Server.
           Can be one of the following:
           - COMMUNITY
           - ENTERPRISE -->
  {{- if not (mustHas .edition (list "COMMUNITY" "ENTERPRISE") )}}
    {{- fail "license.edition must be one of: \"COMMUNITY\", \"ENTERPRISE\"" -}}
  {{- else }}
      <edition>{{ .edition }}</edition>
  {{- end }}

      <!-- ###############################
           IF YOU CHOSE COMMUNITY EDITION
           ############################### -->
      <community_edition_details>
         <!-- Choose the Client API to use with your Lightstreamer free license.
              Can be one (and only one) of the following:
              - javascript_client: for web browser clients
              - nodejs_client: for Node.js clients
              - android_client: for Android clients
              - ios_client: for iOS clients
              - flex_client: for Flex and AIR clients
              - silverlight_client: for Silverlight clients
              - javase_client: for Java SE clients
              - python_client: for Python clients
              - dotnet_standard_client: for .NET Standard clients
              - macos_client: for macOS clients
              - tvos_client: for tvOS clients
              - watchos_client: for watchOS clients
              - visionos_client: for visionOS clients
              - blackberry_client: for BlackBerry clients
              - javame_client: for Java ME clients
              - flash_client: for Flash clients
              - generic_client: for custom clients based on the Lightstreamer protocol
         -->
  {{- $allowedClientApis := list "javascript_client" "nodejs_client" "android_client" "ios_client" "flex_client" "silverlight_client" "javase_client" "python_client" "dotnet_standard_client" "macos_client" "tvos_client" "watchos_client" "blackberry_client" "javame_client" "flash_client" "generic_client" }}
  {{- if not (mustHas .enabledCommunityEditionClientApi $allowedClientApis)}}
    {{- fail (printf "license.enabledCommunityEditionClientApi must be one of: %s" $allowedClientApis) -}}
  {{- else }}
         <enabled_client_api>{{ .enabledCommunityEditionClientApi }}</enabled_client_api>
  {{- end }}
      </community_edition_details>

      <!-- ###############################
           IF YOU CHOSE ENTERPRISE EDITION
           ############################### -->
      <enterprise_edition_details>
  {{- if eq .edition "ENTERPRISE" }}
    {{- with required "license.enterprise must be set" .enterprise }}

         <!-- Choose the type of ENTERPRISE license.
              Can be one of the following:
              - DEMO
              - EVALUATION
              - STARTUP
              - NON-PRODUCTION-LIMITED
              - NON-PRODUCTION-FULL
              - PRODUCTION
              - HOT-STANDBY -->
      {{- if not (mustHas .licenseType (list "DEMO" "EVALUATION" "STARTUP" "NON-PRODUCTION-LIMITED" "NON-PRODUCTION-FULL" "PRODUCTION" "HOT-STANDBY")) }}
        {{- fail "license.enterprise.licenseType must be one of: \"DEMO\", \"EVALUATION\", \"STARTUP\", \"NON-PRODUCTION-LIMITED\", \"NON-PRODUCTION-FULL\", \"PRODUCTION\", \"HOT-STANDBY\"" -}}
      {{- else }}
         <license_type>{{ .licenseType }}</license_type>
      {{- end }}

         <!-- Identifier of the contract in place.
              Use "DEMO" to run with the embedded Demo license. -->
         <contract_id>{{ required "license.enterprise.contractId must be set" .contractId }}</contract_id>

         <!-- Choose between online (cloud-based) and file-based license validation.
              Can be one of the following:
              - ONLINE
                The host names below must be reachable on port 443:
                - https://clm1.lightstreamer.com/
                - https://clm2.lightstreamer.com/
              - FILE
              Based on <license_type> above, one or both the values are possible.
              For EVALUATION and STARTUP: ONLINE is mandatory.
              For PRODUCTION, HOT-STANDBY, NON-PRODUCTION-FULL, and NON-PRODUCTION-LIMITED:
              you can choose between ONLINE and FILE.
              For DEMO: the value is ignored, as no validation is done. -->
       {{- if eq .licenseType "DEMO"}}
         <!--
         <license_validation>ONLINE</license_validation>
         -->
       {{- else }}
         {{- if not (mustHas .licenseValidation (list "ONLINE" "FILE")) }}
           {{- fail "license.enterprise.licenseValidation must be one: of \"ONLINE\", \"FILE\"" -}}
         {{- end }}
         {{- if and (has .licenseType (list "EVALUATION" "STARTUP")) (ne .licenseValidation "ONLINE") }}
           {{- fail "license.enterprise.licenseValidation must be \"ONLINE\" for EVALUATION and STARTUP license types" -}}
         {{- else }}
         <license_validation>{{ .licenseValidation }}</license_validation>
         {{- end }}
       {{- end }}

         <!-- Used only if <license_validation> above set to ONLINE.
              Password used for validation of online licenses.
              Leave blank if <contract_id> set to DEMO or <license_validation>
              set to FILE. -->
       {{- if and (.licenseValidation | eq "ONLINE") (ne .licenseType "DEMO") }}
         <online_password>$env.LS_ENTERPRISE_LICENSE_ONLINE_PASSWORD</online_password>
       {{- end }}

         <!-- Used only if <license_validation> above set to FILE.
              Cumulative. Path and name of the license file, relative to the conf
              directory. If multiple occurrences of this element are supplied,
              the files are all evaluated and the first acceptable one is considered.
              Example: mylicensefile.lic -->
       {{- if .licenseValidation | eq "FILE" }}
         {{- with required "license.enterprise.filePathSecretRef.key must be set" (.filePathSecretRef).key }}
          <file_path>enterprise-license/{{ . }}</file_path>
         {{- end }}
       {{- end }}
         <!-- Restrict the feature set with respect to the license in use.
              Can be one of the following:
              - Y: use the feature set detailed in the <optional_features> element below.
                If a required feature is not allowed by the license in use, the
                server will not start
              - N: use the feature set specified by the license in use -->
         <restricted_feature_set>{{ .enableRestrictedFeaturesSet | default false | ternary "Y" "N" }}</restricted_feature_set>
    {{- end }} {{/* with .enterprise */}}
  {{- end }} {{/* if eq .edition "ENTERPRISE" */}}
      </enterprise_edition_details>

      <!-- Audit logs are produced for Per-User Licenses only.
           See the README.TXT file in the audit directory for full details. -->
      <audit_logs>

         <!-- Path of the directory in which to store the audit log files,
              relative to the conf directory.
              The main audit log reports statistics on the number of concurrent
              sessions and is produced for some types of licenses only.
              A separate audit log reports statistics on the number of concurrent
              MPN Devices served by the Push Notification service, if available;
              likewise, this log file is produced for some types of licenses
              only. -->
         <path>../audit</path>

         <!-- In case of file-based license validation, this element allows to
              activate periodic automatic upload. This makes it much easier for
              the systems admins to deliver the logs, as contractually agreed.
              In case of online license validation, the audit logs are always
              automatically uploaded to the Online License Manager, irrespective
              of this element.
              Can be one of the following:
              - Y: Perform periodic automatic audit log upload.
                   The following host name must be reachable on port 443:
                   - https://service.lightstreamer.com/
              - N: Do not perform automatic audit log upload; if audit logs are
                   required by license terms, they must be delivered manually. -->
  {{- if .enterprise.licenseValidation | eq "FILE" }}
  {{- if not ((.enterprise).enableAutomaticAuditLogUpload | quote | empty) }}
         <automatic_upload>{{ .enterprise.enableAutomaticAuditLogUpload | ternary "Y" "N" }}</automatic_upload>
  {{- else }}
         <!--
         <automatic_upload>Y</automatic_upload>
         -->
  {{- end }}
  {{- end }}
      </audit_logs>

      <!-- CONFIGURATION OF OPTIONAL FEATURES
           For the ENTERPRISE edition, the elements below can be used to restrict
           the feature set with respect to the license in use. Used only if
           <restricted_feature_set> above set to Y.
           The DEMO, EVALUATION, and STARTUP license types by default allow all the
           optional features. For the other license types, the allowed optional
           features are determined by the specific license in use.
           You cannot turn on features that are not allowed by the license in use
           (the server would not start in such case). But you can turn off any
           feature that is allowed by the license in use.
           To know more, open the Welcome Page or the Monitoring Dashboard
           (Edition tab) of your running Lightstreamer Server. -->
      <optional_features>
  {{- if (.enterprise.optionalFeatures).enableRestrictedFeaturesSet }}
    {{- with required "license.enterprise.optionalFeatures.features must be set" ((.enterprise).optionalFeatures).features }}

         <!-- Mobile Push Notifications.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableMpn | quote | empty) }}
         <feature id="mpn">{{ .enableMpn | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableMpn must be explicitly set" }}
         {{- end }}

         <!-- Max message rate (downstream).
              Can be one of the following:
              - 1: max 1 update/sec for each item
              - 3: max 3 updates/sec for each item
              - unlimited: unlimited updates/sec for each item -->
         {{- if not (mustHas .maxDownstreamRate (list "1" "3" "unlimited") ) }}
           {{- fail "license.enterprise.optionalFeatures.maxDownstreamRate must be one of: \"1\", \"3\", \"unlimited\"" }}
         {{- else }}
         <feature id="max_downstream_rate">{{ .maxDownstreamRate }}</feature>
         {{- end }}

         <!-- Bandwidth Control.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableBandwidthControl | quote | empty) }}
         <feature id="bandwidth_control">{{ .enableBandwidthControl | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableBandwidthControl must be explicitly set" }}
         {{- end }}

         <!-- TLS/SSL Support.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableTlsSsl | quote | empty) }}
         <feature id="tls_ssl">{{ .enableTlsSsl | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableTlsSsl must be explicitly set" }}
         {{- end }}

         <!-- JMX Management API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableJmx | quote | empty) }}
         <feature id="jmx">{{ .enableJmx | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableJmx must be explicitly set" }}
         {{- end }}

         <!-- JavaScript Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableJavascriptClient | quote | empty) }}
         <feature id="javascript_client">{{ .enableJavascriptClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableJavascriptClient must be explicitly set" }}
         {{- end }}

         <!-- Node.js Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableNodeJsClient | quote | empty) }}
         <feature id="nodejs_client">{{ .enableNodeJsClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableNodeJsClient must be explicitly set" }}
         {{- end }}

         <!-- Android Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableAndroidClient | quote | empty) }}
         <feature id="android_client">{{ .enableAndroidClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableAndroidClient must be explicitly set" }}
         {{- end }}

         <!-- iOS Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableIOSClient | quote | empty) }}
         <feature id="ios_client">{{ .enableIOSClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableIOSClient must be explicitly set" }}
         {{- end }}

         <!-- Flex and AIR Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableFlexClient | quote | empty) }}
         <feature id="flex_client">{{ .enableFlexClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableFlexClient must be explicitly set" }}
         {{- end }}

         <!-- Silverlight Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableSilverlightClient | quote | empty) }}
         <feature id="silverlight_client">{{ .enableSilverlightClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableSilverlightClient must be explicitly set" }}
         {{- end }}

         <!-- Java SE Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableJavaSEClient | quote | empty) }}
         <feature id="javase_client">{{ .enableJavaSEClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableJavaSEClient must be explicitly set" }}
         {{- end }}

         <!-- Python Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enablePythonClient | quote | empty) }}
         <feature id="python_client">{{ .enablePythonClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enablePythonClient must be explicitly set" }}
         {{- end }}

         <!-- .NET Standard Client API.
              Includes also the old Windows .NET libraries:
              .NET PCL Client API, Unity Client API, .NET Client API, WinRT Client API, and Windows Phone Client API.
              Can be one of the following:
               - Y: enable feature
               - N: disable feature -->
         {{- if not (.enableDotNETStandardClient | quote | empty) }}
         <feature id="dotnet_standard_client">{{ .enableDotNETStandardClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableDotNETStandardClient must be explicitly set" }}
         {{- end }}

         <!-- macOS Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableMacOSClient | quote | empty) }}
         <feature id="macos_client">{{ .enableMacOSClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableMacOSClient must be explicitly set" }}
         {{- end }}

         <!-- tvOS Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableTvOSClient | quote | empty) }}
         <feature id="tvos_client">{{ .enableTvOSClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableTvOSClient must be explicitly set" }}
         {{- end }}

         <!-- watchOS Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableWatchOSClient | quote | empty) }}
         <feature id="watchos_client">{{ .enableWatchOSClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableWatchOSClient must be explicitly set" }}
         {{- end }}

         <!-- visionOS Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableVisionOSClient | quote | empty) }}
         <feature id="visionos_client">{{ .enableVisionOSClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableVisionOSClient must be explicitly set" }}
         {{- end }}

         <!-- BlackBerry Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableBlackBerryClient | quote | empty) }}
         <feature id="blackberry_client">{{ .enableBlackBerryClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableBlackBerryClient must be explicitly set" }}
         {{- end }}

         <!-- Java ME Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableJavaMEClient | quote | empty) }}
         <feature id="javame_client">{{ .enableJavaMEClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableJavaMEClient must be explicitly set" }}
         {{- end }}

         <!-- Flash Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableFlashClient | quote | empty) }}
         <feature id="flash_client">{{ .enableFlashClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableFlashClient must be explicitly set" }}
         {{- end }}

         <!-- Generic Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         {{- if not (.enableGenericClient | quote | empty) }}
         <feature id="generic_client">{{ .enableGenericClient | ternary "Y" "N" }}</feature>
         {{- else}}
           {{- fail "license.enterprise.optionalFeatures.enableGenericClient must be explicitly set" }}
         {{- end }}
    {{- end }} {{/* with .enterprise.features */}}
  {{- end }} {{/* with .enterprise.optionalFeatures */}}
      </optional_features>

      <!-- Periodically check whether any Lightstreamer Server update is
           available. In such case, a notification is written to the log file.
           Can be one of the following:
           - Y: Perform automatic update check.
                The following host name must be reachable on port 443
                - https://service.lightstreamer.com/
           - N: Do not perform automatic update check. -->
  {{- if not (.enableAutomaticUpdateCheck | quote | empty) }}
      <automatic_update_check>{{ .enableAutomaticUpdateCheck | ternary "Y" "N" }}</automatic_update_check>
  {{- else }}
      <!--
      <automatic_update_check>Y</automatic_update_check>
      -->
  {{- end }}

   </license>


<!--
  ===================
  PROXY CONFIGURATION
  ===================
-->

   <!-- Configure a proxy server for outbound Internet access, if necessary.
        Internet access is needed, depending on the above configuration,
        to reach the Online License Manager, to upload audit logs,
        and to check for software updates.
        The host names below must be reachable from the proxy on port 443:
        - https://clm1.lightstreamer.com/    (depending on the configuration)
        - https://clm2.lightstreamer.com/    (depending on the configuration)
        - https://service.lightstreamer.com/ (regardless of the configuration)
        Several methods are provided for the proxy configuration, including
        PAC files, auto-discovery, and direct HTTP and SOCKS configuration. -->
   <proxy>
  {{- with .proxy }}

      <!-- Cumulative. HTTP Proxy Server configuration.
           If multiple occurrences of <http_proxy> are supplied, the proxies
           are all checked and the first acceptable one is used.
           If any <socks_proxy> element is configured too, it is checked
           in parallel with the <http_proxy> elements. -->
    {{- range .httpProxies }}
      <http_proxy>

      {{- if .host }}
         <!-- Hostname or IP address of the proxy server.
              Example: proxy.mycompany.com
              Example: 192.168.0.5 -->
         <proxy_host>{{ .host }}</proxy_host>

         <!-- Port number of the proxy server.
              Example: 8080 -->
         <proxy_port>{{ .port }}</proxy_port>

         <!-- Scheme "http" or "https" -->
         <proxy_scheme>{{ .scheme }}</proxy_scheme>

         <!-- User name if proxy authentication is required. -->
        {{- if .credentialsSecretRef }}
         <proxy_user>$env.LS_PROXY_{{ .credentialsSecretRef | upper | replace "-" "_" }}_USER</proxy_user>

         <!-- User password if proxy authentication is required. -->
         <proxy_password>$env.LS_PROXY_{{ .credentialsSecretRef | upper | replace "-" "_" }}_PASSWORD</proxy_password>
        {{- end }}
      {{- end }}

      </http_proxy>
    {{- end }} {{/* range .httpProxies */}}

      <!-- Cumulative. SOCKS Proxy Server configuration.
           If multiple occurrences of <socks_proxy> are supplied, the servers
           are all checked and the first acceptable one is used.
           If any <http_proxy> element is configured too, it is checked
           in parallel with the <socks_proxy> elements. -->
    {{- range .socksProxies }}
      <socks_proxy>

      {{- if .host }}
         <!-- Host name or IP address of the SOCKS server.
              Example: socks.mycompany.com
              Example: 192.168.0.9 -->
         <proxy_host>{{ .host }}</proxy_host>

         <!-- Port number of the SOCKS server.
              Example: 1080 -->
         <proxy_port>{{ .port }}</proxy_port>

         <!-- Protocol version to use.
              Can be one of the following:
              - SOCKS4
              - SOCKS4a
              - SOCKS5 -->
         <proxy_version>{{ .version }}</proxy_version>

         <!-- User name if proxy authentication is required. -->
        {{- if .credentialsSecretRef }}
         <proxy_user>$env.LS_PROXY_{{ .credentialsSecretRef | upper | replace "-" "_" }}_USER</proxy_user>

         <!-- User password if proxy authentication is required. -->
         <proxy_password>$env.LS_PROXY_{{ .credentialsSecretRef | upper | replace "-" "_" }}_PASSWORD</proxy_password>
        {{- end }}
      {{- end }}

      </socks_proxy>
    {{- end }} {{/* range .socksProxies */}}

      <!-- Configure one or multiple proxy auto-config (PAC) files, for simpler
           proxy configuration. -->
      <pac_files>
    {{- with .pacFiles }}

         <!-- Cumulative. URL of the PAC file.
              Example: http://intra.mycompany.com/company.pac -->
      {{- range .fileUrls }}
         <file_url>{{ . }}</file_url>
      {{- else }}
         <file_url></file_url>
      {{- end }} {{/* range .fileUrls */}}

         <!-- Cumulative. Path of the PAC file, in case it is stored on the file system.
              Example: C:\mypath\myfile.pac -->
      {{- range $index, $value := .filePaths }}
        {{- $name := required (printf "license.proxy.pacFiles.filePaths[%d].name must be set" $index) $value.name }}
        {{- $file := required (printf "license.proxy.pacFiles.filePaths[%d].key must be set" $index) $value.key }}
         <file_path>proxy-pac-files/{{ $name }}/{{ $file }}</file_path>
      {{- else }}
         <file_path></file_path>
      {{- end }} {{/* range .filePaths */}}

    {{- end }} {{/* with .pacFiles */}}
      </pac_files>

      <!-- In case no proxy configuration is provided or the provided
           configuration does not work, automatic proxy discovery is
           attempted (via system environment check and WPAD).
           Can be one of the following:
           - Y: perform auto-discovery;
           - N: do not perform auto-discovery. -->
      {{- if not (.enableProxyAutodiscovery | quote | empty) }}
      <proxy_autodiscovery>{{ .enableProxyAutodiscovery |  ternary "Y" "N" }}</proxy_autodiscovery>
      {{- else }}
      <!--
      <proxy_autodiscovery>Y</proxy_autodiscovery>
      -->
      {{- end }}

      <!-- Specifies a NIC to use to access the external services, with or
           without a proxy.
           Example: 200.0.0.1 -->
      <network_interface>{{ .networkInterface }}</network_interface>

  {{- end }} {{/* with .proxy */}}
   </proxy>

    <!-- Optional. If set and not empty, modifies the behavior of the
         variable-expansion feature in this configuration file (see below). -->
    <env_prefix>env.</env_prefix>

</lightstreamer_edition_conf>

<!-- A very simple variable-expansion feature is available for this file.
     Element or attribute values of the form $propname are expanded by looking for
     a corresponding JVM property (which, for instance, can be defined by adding
     -Dpropname=propvalue to the Server command line arguments in the launch
     script). If the property is not defined, then the element or attribute
     is considered as not defined at all.
     If <env_prefix> is set, it specifies a prefix such that, if a $propname
     value is found and propname starts with this prefix, the propname will
     be searched among the system environment variables rather than the JVM
     properties.
     If needed, the variable-expansion feature can be disabled for an element
     or for an element's attribute (let's say: attr) by adding prop_prefix=""
     or, respectively, attr_prop_prefix="" to the element (note that these
     "prop_prefix" attributes are handled in a special way). This also allows
     for setting a prefix other than "$".

     All the element or attribute values described as directory or file paths
     can be expressed as absolute or relative pathnames; when relative,
     they are considered as relative to the directory that contains this
     configuration file.
     Note that, on Windows, if a drive name is not specified, a double initial
     slash or backslash is needed to make a path absolute. -->
{{- end }}
{{- end }} {{/* with .license */}}

{{/* Create the Lightstreamer edition configuration file */}}
{{- define "lightstreamer.configuration.edition" -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: edition_conf-APV-7.3.0. -->

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

{{- with $.Values.edition }}
   <!-- Configure the edition, the optional features, and the type of license
        that should be used to run Lightstreamer Server. -->
   <license>
   {{- with .license }}

      <!-- #########################################
           CONFIGURE YOUR LIGHTSTREAMER EDITION HERE
           #########################################
           Lightstreamer edition to use.
           To know full details, open the Welcome Page or the Monitoring Dashboard
           (Edition tab) of your running Lightstreamer Server.
           Can be one of the following:
           - COMMUNITY
           - ENTERPRISE -->
      <edition>{{ .edition }}</edition>

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
              - blackberry_client: for BlackBerry clients
              - javame_client: for Java ME clients
              - flash_client: for Flash clients
              - generic_client: for custom clients based on the Lightstreamer protocol
         -->
         <enabled_client_api>{{ .enabledCommunityEditionClientApi | default "javascript_client" }}</enabled_client_api>
      </community_edition_details>

      <!-- ###############################
           IF YOU CHOSE ENTERPRISE EDITION
           ############################### -->
      <enterprise_edition_details>
      {{- with .enterpriseEditionDetails }}

         <!-- Choose the type of ENTERPRISE license.
              Can be one of the following:
              - DEMO
              - EVALUATION
              - STARTUP
              - NON-PRODUCTION-LIMITED
              - NON-PRODUCTION-FULL
              - PRODUCTION
              - HOT-STANDBY -->
         <license_type>{{ .licenseType }}</license_type>

         <!-- Identifier of the contract in place.
              Use "DEMO" to run with the embedded Demo license. -->
         <contract_id>{{ .contractId }}</contract_id>

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
         <license_validation>{{ .licenseValidation }}</license_validation>

         <!-- Used only if <license_validation> above set to ONLINE.
              Password used for validation of online licenses.
              Leave blank if <contract_id> set to DEMO or <license_validation>
              set to FILE. -->
         <online_password></online_password>

         <!-- Used only if <license_validation> above set to FILE.
              Cumulative. Path and name of the license file, relative to the conf
              directory. If multiple occurrences of this element are supplied,
              the files are all evaluated and the first acceptable one is considered.
              Example: mylicensefile.lic -->
         <file_path></file_path>

         <!-- Restrict the feature set with respect to the license in use.
              Can be one of the following:
              - Y: use the feature set detailed in the <optional_features> element below.
                If a required feature is not allowed by the license in use, the
                server will not start
              - N: use the feature set specified by the license in use -->
         <restricted_feature_set>{{ .enableRestrictedFeaturesSet | default false | ternary "Y" "N" }}</restricted_feature_set>

      {{- end }}
      </enterprise_edition_details>

      <!-- Audit logs are produced for Per-User Licenses only.
           See the README.TXT file in the audit directory for full details. -->
      <audit_logs>
      {{- with .auditLogs }}

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
         <automatic_upload>{{ .enableAutomaticUpload | default false | ternary "Y" "N" }}</automatic_upload>

      {{- end}}
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
      {{- with .optionalFeatures }}

         <!-- Mobile Push Notifications.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="mpn">{{ .enableMpn | default false | ternary "Y" "N" }}</feature>

         <!-- Max message rate (downstream).
              Can be one of the following:
              - 1: max 1 update/sec for each item
              - 3: max 3 updates/sec for each item
              - unlimited: unlimited updates/sec for each item -->
         <feature id="max_downstream_rate">{{ .maxDownstreamRate | default "1" }}</feature>

         <!-- Bandwidth Control.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="bandwidth_control">{{ .enableBandwidthControl | default false | ternary "Y" "N" }}</feature>

         <!-- TLS/SSL Support.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="tls_ssl">{{ .enableTlsSsl | default false | ternary "Y" "N" }}</feature>

         <!-- JMX Management API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="jmx">{{ .enableJmx | default false | ternary "Y" "N" }}</feature>

         <!-- JavaScript Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="javascript_client">{{ .enableJavascriptClient | default false | ternary "Y" "N" }}</feature>

         <!-- Node.js Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="nodejs_client">{{ .enableNodeJsClient | default false | ternary "Y" "N" }}</feature>

         <!-- Android Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="android_client">{{ .enableAndroidClient | default false | ternary "Y" "N" }}</feature>

         <!-- iOS Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="ios_client">{{ .enableIOSClient | default false | ternary "Y" "N" }}</feature>

         <!-- Flex and AIR Cient API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="flex_client">{{ .enableFlexClient | default false | ternary "Y" "N" }}</feature>

         <!-- Silverlight Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="silverlight_client">{{ .enableSilverlightClient | default false | ternary "Y" "N" }}</feature>

         <!-- Java SE Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="javase_client">{{ .enableJavaSEClient | default false | ternary "Y" "N" }}</feature>

         <!-- Python Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="python_client">{{ .enablePythonClient | default false | ternary "Y" "N" }}</feature>

         <!-- .NET Standard Client API.
              Includes also the old Windows .NET libraries:
              .NET PCL Client API, Unity Client API, .NET Client API, WinRT Client API, and Windows Phone Client API.
              Can be one of the following:
               - Y: enable feature
               - N: disable feature -->
         <feature id="dotnet_standard_client">{{ .enableDotNETStandardClient | default false | ternary "Y" "N" }}</feature>

         <!-- macOS Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="macos_client">{{ .enableMacOSClient | default false | ternary "Y" "N" }}</feature>

         <!-- tvOS Cllient API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="tvos_client">{{ .enableTvOSClient | default false | ternary "Y" "N" }}</feature>

         <!-- watchOS Cllient API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="watchos_client">{{ .enableWatchOSClient | default false | ternary "Y" "N" }}</feature>

         <!-- BlackBerry Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="blackberry_client">{{ .enableBlackBerryClient | default false | ternary "Y" "N" }}</feature>

         <!-- Java ME Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="javame_client">{{ .enableJavaMEClient | default false | ternary "Y" "N" }}</feature>

         <!-- Flash Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="flash_client">{{ .enableFlashClient | default false | ternary "Y" "N" }}</feature>

         <!-- Generic Client API.
              Can be one of the following:
              - Y: enable feature
              - N: disable feature -->
         <feature id="generic_client">{{ .enableGenericClient | default false | ternary "Y" "N" }}</feature>

      {{- end }}
      </optional_features>

      <!-- Periodically check whether any Lightstreamer Server update is
           available. In such case, a notification is written to the log file.
           Can be one of the following:
           - Y: Perform automatic update check.
                The following host name must be reachable on port 443
                - https://service.lightstreamer.com/
           - N: Do not perform automatic update check. -->
      {{- if hasKey . "enableAutomaticUpdateCheck" }}
      <automatic_update_check>{{ .enableAutomaticUpdateCheck | ternary "Y" "N" }}</automatic_update_check>
      {{- else }}
      <automatic_update_check>Y</automatic_update_check>
      {{- end }}

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
      <http_proxy>
      {{- with .httpProxy }}

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
         <proxy_user></proxy_user>

         <!-- User password if proxy authentication is required. -->
         <proxy_password></proxy_password>

      {{- end }}
      </http_proxy>

      <!-- Cumulative. SOCKS Proxy Server configuration.
           If multiple occurrences of <socks_proxy> are supplied, the servers
           are all checked and the first acceptable one is used.
           If any <http_proxy> element is configured too, it is checked
           in parallel with the <socks_proxy> elements. -->
      <socks_proxy>
      {{- with .socksProxy }}

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
         <proxy_user></proxy_user>

         <!-- User password if proxy authentication is required. -->
         <proxy_password></proxy_password>

      {{- end }}
      </socks_proxy>

      <!-- Configure one or multiple proxy auto-config (PAC) files, for simpler
           proxy configuration. -->
      <pac_files>
      {{- with .pacFiles }}

         <!-- Cumulative. URL of the PAC file.
              Example: http://intra.mycompany.com/company.pac -->
         <file_url></file_url>

         <!-- Cumulative. Path of the PAC file, in case it is stored on the file system.
              Example: C:\mypath\myfile.pac -->
         <file_path></file_path>

      {{- end }}
      </pac_files>

      <!-- In case no proxy configuration is provided or the provided
           configuration does not work, automatic proxy discovery is
           attempted (via system environment check and WPAD).
           Can be one of the following:
           - Y: perform auto-discovery;
           - N: do not perform auto-discovery. -->
      <proxy_autodiscovery>{{ .enableProxyAutodiscovery | default false | ternary "Y" "N" }}</proxy_autodiscovery>

      <!-- Specifies a NIC to use to access the external services, with or
           without a proxy.
           Example: 200.0.0.1 -->
      <network_interface>{{ .networkInterface }}</network_interface>

   {{- end }}
   </proxy>

    <!-- Optional. If set and not empty, modifies the behavior of the
         variable-expansion feature in this configuration file (see below). -->
    <env_prefix></env_prefix>

{{- end }}
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

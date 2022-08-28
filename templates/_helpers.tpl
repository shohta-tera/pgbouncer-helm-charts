{{- define "pgbouncer.labels.app" -}}
{{- printf "%s" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pgbouncer.labels.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "pgbouncer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pgbouncer.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pgbouncer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pgbouncer.labels" -}}
helm.sh/chart: {{ include "pgbouncer.chart" . }}
{{ include "pgbouncer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pgbouncer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pgbouncer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pgbouncer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pgbouncer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "pgbouncer.podNodeSelector" }}
{{- .nodeSelector | default .Values.pgbouncer.defaultNodeSelector | toYaml }}
{{- end }}

{{- define "pgbouncer.podAffinity" }}
{{- .affinity | default .Values.pgbouncer.defaultAffinity | toYaml }}
{{- end }}

{{- define "pgbouncer.podTolerations" }}
{{- .tolerations | default .Values.pgbouncer.defaultTolerations | toYaml }}
{{- end }}

{{- define "pgbouncer.podSecurityContext" }}
{{- .securityContext | default .Values.pgbouncer.defaultSecurityContext | toYaml }}
{{- end }}

{{- define "pgbouncer.pgbouncer.pgbouncer.ini" }}
[databases]
* = host={{ .Values.externalDatabase.host }} port={{ .Values.externalDatabase.port }}

[pgbouncer]
pool_mode = {{ .Values.pgbouncer.envVars.PGBOUNCER_POOL_MODE }}
max_client_conn = {{ .Values.pgbouncer.maxClientConnections }}
default_pool_size =  {{ .Values.pgbouncer.poolSize }}
ignore_startup_parameters = extra_float_digits

listen_port = 6432
listen_addr = *

auth_type = {{ .Values.pgbouncer.authType }}
auth_file = /opt/bitnami/pgbouncer/conf/userlist.txt

log_disconnections = {{ .Values.pgbouncer.logDisconnections }}
log_connections = {{ .Values.pgbouncer.logConnections }}

# locks will never be released when `pool_mode=transaction` (airflow initdb/upgradedb scripts create locks)
server_reset_query = SELECT pg_advisory_unlock_all()
server_reset_query_always = 1
{{- end }}

{{- define "pgbouncer.pgbouncer.userlist.txt" }}
"{{ .Values.auth.AIRFLOW_USERNAME }}" "{{ .Values.auth.AIRFLOW_PASSWORD }}"
{{- end }}

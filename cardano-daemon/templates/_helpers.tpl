{{/* vim: set filetype=mustache: */}}
{{/*

Expand the name of the chart.
*/}}
{{- define "cardano-daemon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cardano-daemon.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cardano-daemon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "cardano-daemon.labels" -}}
helm.sh/chart: {{ include "cardano-daemon.chart" . }}
{{ include "cardano-daemon.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "cardano-daemon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cardano-daemon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Net
*/}}
{{- define "cardano-daemon.net" -}}
{{- default .Values.net .Values.global.net -}}
{{- end -}}

{{/*
Snapshot
*/}}
{{- define "cardano-daemon.snapshot" -}}
{{- if eq (include "cardano-daemon.net" .) "stagenet" -}}
    {{ .Values.snapshot.stagenet }}
{{- else if eq (include "cardano-daemon.net" .) "mainnet" -}}
    {{ .Values.snapshot.mainnet }}
{{- end -}}
{{- end -}}


{{/*
n2c Port
*/}}
{{- define "cardano-daemon.n2c" -}}
{{- if eq (include "cardano-daemon.net" .) "mainnet" -}}
    {{ .Values.service.port.mainnet.n2c }}
{{- else if eq (include "cardano-daemon.net" .) "stagenet" -}}
    {{ .Values.service.port.stagenet.n2c }}
{{- else -}}
    {{ .Values.service.port.mainnet.n2c }}
{{- end -}}
{{- end -}}

{{/*
n2n Port
*/}}
{{- define "cardano-daemon.n2n" -}}
{{- if eq (include "cardano-daemon.net" .) "mainnet" -}}
    {{ .Values.service.port.mainnet.n2n }}
{{- else if eq (include "cardano-daemon.net" .) "stagenet" -}}
    {{ .Values.service.port.stagenet.n2n }}
{{- else -}}
    {{ .Values.service.port.mainnet.n2n }}
{{- end -}}
{{- end -}}
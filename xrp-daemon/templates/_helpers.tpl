{{/* vim: set filetype=mustache: */}}
{{/*

Expand the name of the chart.
*/}}
{{- define "xrp-daemon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xrp-daemon.fullname" -}}
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
{{- define "xrp-daemon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "xrp-daemon.labels" -}}
helm.sh/chart: {{ include "xrp-daemon.chart" . }}
{{ include "xrp-daemon.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "xrp-daemon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "xrp-daemon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Net
*/}}
{{- define "xrp-daemon.net" -}}
{{- default .Values.net .Values.global.net -}}
{{- end -}}

{{/*
RPC Port
*/}}
{{- define "xrp-daemon.rpc" -}}
{{- if eq (include "xrp-daemon.net" .) "mainnet" -}}
    {{ .Values.service.port.mainnet.rpc }}
{{- else if eq (include "xrp-daemon.net" .) "stagenet" -}}
    {{ .Values.service.port.stagenet.rpc }}
{{- else -}}
    {{ .Values.service.port.mainnet.rpc }}
{{- end -}}
{{- end -}}

{{/*
P2P Port
*/}}
{{- define "xrp-daemon.p2p" -}}
{{- if eq (include "xrp-daemon.net" .) "mainnet" -}}
    {{ .Values.service.port.mainnet.p2p }}
{{- else if eq (include "xrp-daemon.net" .) "stagenet" -}}
    {{ .Values.service.port.stagenet.p2p }}
{{- else -}}
    {{ .Values.service.port.mainnet.p2p }}
{{- end -}}
{{- end -}}

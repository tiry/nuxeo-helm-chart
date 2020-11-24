{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "nuxeo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nuxeo.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the list of nodes types depending on architecture.
*/}}
{{- define "nuxeo.nodeTypes" -}}
{{- if eq .Values.architecture "singleNode" -}}
    single
{{- end -}}
{{- if eq .Values.architecture "api-worker" -}}
    api,worker
{{- end -}}
{{- end -}}

{{/*
Return true if a cloud provider is enabled for binary storage.
*/}}
{{- define "nuxeo.cloudProvider.enabled" -}}
{{- if or .Values.googleCloudStorage.enabled .Values.amazonS3.enabled -}}
    {{- true -}}
{{- end -}}
{{- end -}}
{{/*
Template for the secret manifest, using a dictionary as scope:
- .: root context
- key: secret name suffix
- val: string data
*/}}
{{- define "nuxeo.secret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "nuxeo.fullname" .}}-{{ .key }}
  labels:
    app: {{ template "nuxeo.fullname" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
type: Opaque
stringData: {{ .val | nindent 2 }}
{{- end -}}
{{- define "nuxeo.secret2" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "nuxeo.fullname" .}}-{{ .key }}
  labels:
    app: {{ template "nuxeo.fullname" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
type: Opaque
{{- end -}}



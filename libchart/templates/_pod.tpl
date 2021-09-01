{{- define "service.pod" -}}
{{- if .Values.schedulerName }}
schedulerName: "{{ .Values.schedulerName }}"
{{- end }}
serviceAccountName: {{ include "service.serviceAccountName" . }}
{{- if .Values.securityContext }}
securityContext:
{{ toYaml .Values.securityContext | indent 2 }}
{{- end }}
{{- if .Values.priorityClassName }}
priorityClassName: {{ .Values.priorityClassName }}
{{- end }}
{{- if .Values.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
containers:
  - name: {{ .Chart.Name }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- if .Values.command }}
    command:
    {{- range .Values.command }}
      - {{ . }}
    {{- end }}
  {{- end}}
    volumeMounts:
      {{- range .Values.extraConfigmapMounts }}
      - name: {{ .name }}
        mountPath: {{ .mountPath }}
        subPath: {{ .subPath | default "" }}
        readOnly: {{ .readOnly }}
      {{- end }}
      {{- range .Values.extraSecretMounts }}
      - name: {{ .name }}
        mountPath: {{ .mountPath }}
        readOnly: {{ .readOnly }}
        subPath: {{ .subPath | default "" }}
      {{- end }}
    ports:
      - name: {{ .Values.podPort.name }}
        containerPort: {{ .Values.podPort.port }}
        protocol: TCP
    env:
      - name: ZDE_POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
    {{- range $key, $value := .Values.envValueFrom }}
      - name: {{ $key | quote }}
        valueFrom:
{{ toYaml $value | indent 10 }}
    {{- end }}
    {{- range $key, $value := .Values.env }}
      - name: "{{ $key }}"
        value: "{{ $value }}"
    {{- end }}
    {{- if .Values.envFromSecret }}
    envFrom:
      - secretRef:
          name: {{ tpl .Values.envFromSecret . }}
    {{- end }}
    {{- if .Values.envRenderSecret }}
    envFrom:
      - secretRef:
          name: {{ include "service.fullname" . }}-env
    {{- end }}
    livenessProbe:
{{ toYaml .Values.livenessProbe | indent 6 }}
    readinessProbe:
{{ toYaml .Values.readinessProbe | indent 6 }}
{{- if .Values.resources }}
    resources:
{{ toYaml .Values.resources | indent 6 }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}
volumes:
{{- range .Values.extraConfigmapMounts }}
  - name: {{ .name }}
    configMap:
      name: {{ .configMap }}
{{- end }}
{{- range .Values.extraSecretMounts }}
  - name: {{ .name }}
    secret:
      secretName: {{ .secretName }}
      defaultMode: {{ .defaultMode }}
{{- end }}
{{- end }}

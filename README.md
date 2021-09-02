# full-chart-helm

The idea is to have chart for common usage ``libchart``
Then three charts ``journey-api, journey-v2, pagebuilder`` inherits is .
Templates looks like 
```
{{- include "libchart.deployment" (list . "service.deployment") -}}
{{- define "service.deployment" -}}

{{- end -}}
```
And is something have to be added it can be added inlign. For example
```
{{- include "libchart.deployment" (list . "service.deployment") -}}
{{- define "service.deployment" -}}
spec:
  replicas: {{ .Values.newReplicas }}
{{- end -}}
```
But usually all configuration happens in services value files like ``https://github.com/almerico/common-full-chart-helm/blob/main/journey-v2/values.yaml``


And finally umbrella-chart can install all in once and in it's  Values file we can reassign values.

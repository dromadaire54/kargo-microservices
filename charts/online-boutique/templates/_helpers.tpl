{{/*
Effective values of the microservice selected by `name`: the chart defaults
(everything but `services`) overridden by `services.<name>`. Returned as YAML,
use it with `include ... | fromYaml`.
*/}}
{{- define "online-boutique.service" -}}
{{- $name := required "values: `name` is required (a key of `services`)" .Values.name -}}
{{- $override := get .Values.services $name | default dict -}}
{{- if not (hasKey .Values.services $name) -}}
{{- fail (printf "values: unknown microservice %q, add it under `services`" $name) -}}
{{- end -}}
{{- $defaults := omit .Values "services" | deepCopy -}}
{{- mergeOverwrite $defaults ($override | deepCopy) | toYaml -}}
{{- end }}

{{/* Selector labels, kept as `app: <name>` to match the historical selectors. */}}
{{- define "online-boutique.selectorLabels" -}}
app: {{ .Values.name }}
{{- end }}

{{- define "online-boutique.labels" -}}
{{ include "online-boutique.selectorLabels" . }}
app.kubernetes.io/part-of: online-boutique
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Container image: either a full reference (`image.ref`, e.g. redis:alpine) or
<image.repository>/<name>:<image.tags.<name>>, the tag being written by Kargo
in env/<stage>/values.yaml. Takes the merged service values.
*/}}
{{- define "online-boutique.image" -}}
{{- if .image.ref -}}
{{- .image.ref -}}
{{- else -}}
{{- printf "%s/%s:%s" .image.repository .name (required (printf "values: image.tags.%s is required" .name) (index .image.tags .name)) -}}
{{- end -}}
{{- end }}

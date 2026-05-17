# Manifests

Os manifests estao organizados em ordem de estudo e execucao.

## Ordem Sugerida

| Pasta | Recurso principal | Objetivo |
|---|---|---|
| `00-namespace` | `Namespace` | Isolar o laboratorio no namespace `deploy-strategies-lab` |
| `01-daemonset` | `DaemonSet` | Demonstrar um Pod por node com coleta de contexto do cluster |
| `02-job` | `Job` | Executar uma tarefa unica ate concluir com sucesso |
| `03-job-advanced` | `Job` paralelo | Explorar `completions`, `parallelism` e execucao batch |
| `04-cronjob` | `CronJob` | Agendar execucoes recorrentes para fins de laboratorio |
| `05-statefulset` | `StatefulSet` + `Service` | Mostrar identidade estavel, ordem e persistencia |
| `06-statefulset-volume-retention` | `StatefulSet` + `Service` | Demonstrar retencao de PVC em scale down e remocao |
| `07-headless-service` | `Headless Service` + `StatefulSet` | Validar DNS previsivel e descoberta direta entre Pods |

## Convencoes

- Todos os recursos usam o namespace `deploy-strategies-lab`
- Os exemplos privilegiam clareza e reproducao local
- Os exemplos stateful assumem `StorageClass` padrao com provisionamento dinamico

## Dica de Uso

- Para aplicar tudo em ordem, use `./scripts/apply-all.sh`
- Para validar o ambiente e os recursos, use `./scripts/setup.sh` e `./scripts/check.sh`
- Para revisar o comportamento de cada topico, combine os manifests com a leitura correspondente em `docs/`

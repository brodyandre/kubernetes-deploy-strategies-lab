# Docs

Documentacao complementar do laboratorio com foco em estudo guiado, validacao pratica e valor de portfolio.

## Guia de Leitura

| Arquivo | Foco |
|---|---|
| [01-introducao.md](01-introducao.md) | Visao geral do laboratorio, workloads e fluxo recomendado de estudo |
| [02-daemonset.md](02-daemonset.md) | Quando usar DaemonSet e como validar um Pod por node |
| [03-job.md](03-job.md) | Execucao de tarefas unicas ate o status `Completed` |
| [04-cronjob.md](04-cronjob.md) | Agendamento de tarefas recorrentes com CronJob |
| [05-statefulset.md](05-statefulset.md) | Identidade estavel, PVCs e diferencas entre Deployment e StatefulSet |
| [06-volume-retention.md](06-volume-retention.md) | Politicas de retencao de PVC ao escalar ou remover StatefulSets |
| [07-headless-service.md](07-headless-service.md) | DNS previsivel e descoberta direta entre Pods |
| [08-comandos-uteis.md](08-comandos-uteis.md) | Comandos `kubectl` para operacao e inspecao do laboratorio |
| [09-troubleshooting.md](09-troubleshooting.md) | Diagnostico de problemas comuns em cluster local |
| [kind-storageclass.md](kind-storageclass.md) | Observacoes especificas para persistencia em clusters `kind` |

## Objetivo

Esta pasta existe para transformar o laboratorio em material de consulta real. A ideia nao e apenas mostrar manifests, mas explicar:

- por que cada workload existe
- quando usar cada abordagem
- como validar se o comportamento esta correto
- como diagnosticar problemas comuns em clusters locais

## Sequencia Recomendada

1. Comece por [01-introducao.md](01-introducao.md).
2. Estude cada workload na mesma ordem da pasta `manifests/`.
3. Use [08-comandos-uteis.md](08-comandos-uteis.md) como apoio durante a execucao.
4. Consulte [09-troubleshooting.md](09-troubleshooting.md) quando algum recurso nao se comportar como esperado.

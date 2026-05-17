# Carousel Outline

## Slide 1 - Capa

**Estudando outras formas de deploy no Kubernetes**

DaemonSet, Job, CronJob, StatefulSet e Headless Service

## Slide 2 - Por que existem outras formas de deploy alem de Deployment?

Nem todo workload no Kubernetes deve ser tratado como uma aplicacao stateless.

Alguns cenarios pedem:

- um Pod por Node
- tarefas que terminam
- execucoes agendadas
- identidade estavel
- armazenamento persistente

## Slide 3 - DaemonSet

`DaemonSet` garante um Pod por Node.

Muito usado para:

- logs
- monitoramento
- agentes de seguranca

E uma peca importante de operacao de cluster.

## Slide 4 - Job e CronJob

`Job` executa uma tarefa ate terminar.

`CronJob` agenda execucoes recorrentes.

Esses recursos sao uteis para:

- processamento batch
- backups
- rotinas automatizadas
- pipelines operacionais

## Slide 5 - StatefulSet e volumes persistentes

`StatefulSet` existe para workloads com identidade estavel.

Ele faz sentido quando precisamos de:

- nomes previsiveis por Pod
- volume persistente por replica
- DNS estavel

Aqui, storage e rede passam a importar muito mais.

## Slide 6 - Aprendizados e chamada para o GitHub

Aprendizado principal:

entender Kubernetes de verdade exige ir alem do `Deployment`.

Transformei esse estudo em laboratorio pratico e documentado no GitHub:

`github.com/brodyandre/kubernetes-deploy-strategies-lab`

Se fizer sentido para voce, vamos trocar ideias sobre Kubernetes, DevOps e plataformas de dados.

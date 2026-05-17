# 01 - Introducao

## Visao Geral

Este laboratorio foi criado para estudar workloads importantes do Kubernetes alem do `Deployment`. Em muitos projetos iniciantes, quase tudo e empacotado como `Deployment`, mas isso nao resolve todos os cenarios.

No mundo real, um ambiente Kubernetes normalmente precisa de:

- processos que rodam em todos os nodes
- tarefas batch que terminam sozinhas
- tarefas agendadas
- aplicacoes com armazenamento persistente
- descoberta de servico orientada a identidade dos Pods

Por isso, este repositorio foca em `DaemonSet`, `Job`, `CronJob`, `StatefulSet`, retencao de volume e `Headless Service`.

## O que e um workload no Kubernetes

Um workload e a forma declarativa de dizer ao Kubernetes qual tipo de aplicacao ou processo voce quer executar.

Exemplos:

- `Deployment`: bom para aplicacoes stateless, como APIs e frontends
- `DaemonSet`: bom para um Pod por node
- `Job`: bom para tarefas que precisam terminar
- `CronJob`: bom para tarefas recorrentes
- `StatefulSet`: bom para aplicacoes com identidade estavel e dados persistentes

Cada workload existe porque o Kubernetes precisa tratar comportamentos diferentes de forma diferente.

## Por que estudar alem de Deployment

Saber apenas `Deployment` costuma cobrir o basico de aplicacoes web. Ja conhecer `DaemonSet`, `Job`, `CronJob` e `StatefulSet` demonstra uma visao mais completa de operacao de cluster.

Isso e relevante para DevOps, SRE e Platform Engineering porque mostra que voce entende:

- workloads stateless e stateful
- execucao batch
- persistencia
- rede interna entre Pods
- troubleshooting em recursos diferentes

## Estrutura do laboratorio

Os manifests foram separados por assunto em `manifests/`:

- `00-namespace`: cria o namespace do laboratorio
- `01-daemonset`: exemplo de Pod por node
- `02-job`: tarefa unica
- `03-job-advanced`: job com paralelismo e politicas adicionais
- `04-cronjob`: execucao agendada
- `05-statefulset`: workload stateful com PVC
- `06-statefulset-volume-retention`: retencao de PVC ao escalar ou deletar
- `07-headless-service`: descoberta direta dos Pods

Os documentos desta pasta acompanham essa ordem.

## Fluxo recomendado de estudo

1. Entenda o namespace e a organizacao do projeto.
2. Aplique um workload por vez.
3. Valide com `kubectl get`, `kubectl describe`, `kubectl logs` e `kubectl get events`.
4. Compare o comportamento de cada recurso.
5. Registre evidencias e aprendizados para portfolio.

## Comandos iniciais

Verificar o contexto atual:

```bash
kubectl config current-context
```

Verificar se o cluster esta acessivel:

```bash
kubectl get nodes
```

Criar o namespace do laboratorio:

```bash
kubectl apply -f manifests/00-namespace/
```

Validar o namespace:

```bash
kubectl get ns deploy-strategies-lab
```

Aplicar todo o laboratorio:

```bash
./scripts/apply-all.sh
```

## Como validar se o laboratorio esta funcionando

Uma validacao inicial simples pode ser feita com:

```bash
kubectl get all -n deploy-strategies-lab
```

Para inspecionar tambem recursos nao mostrados em `get all`:

```bash
kubectl get daemonset,job,cronjob,statefulset,pvc,svc -n deploy-strategies-lab
```

Se algum recurso estiver com problema, o caminho mais util geralmente e:

```bash
kubectl describe <tipo> <nome> -n deploy-strategies-lab
kubectl get events -n deploy-strategies-lab --sort-by=.lastTimestamp
```

## O que este laboratorio ensina na pratica

Ao final do estudo, o mais importante nao e decorar YAML. O valor real esta em entender:

- por que um workload foi escolhido
- que comportamento o controlador garante
- como validar o resultado no cluster
- como diagnosticar quando o comportamento esperado nao acontece

Esse tipo de leitura e observacao transforma manifest em conhecimento operacional.

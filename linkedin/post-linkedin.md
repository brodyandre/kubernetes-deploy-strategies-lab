# Post LinkedIn

Estudar Kubernetes vai muito alem de saber criar `Deployment`.

Nos ultimos dias, venho praticando outras formas de deploy e execucao no Kubernetes para entender melhor como cada workload resolve um problema especifico no mundo real.

No projeto `kubernetes-deploy-strategies-lab`, organizei exemplos praticos de:

- `DaemonSet`
- `Job`
- `CronJob`
- `StatefulSet`
- `Headless Service`

O objetivo foi sair da teoria e consolidar, na pratica, quando cada recurso faz sentido.

Por exemplo:

- `DaemonSet` ajuda quando precisamos rodar um Pod por Node, algo muito comum em observabilidade e agentes de infraestrutura
- `Job` e `CronJob` fazem sentido para rotinas batch, processamento sob demanda e tarefas recorrentes
- `StatefulSet` e `Headless Service` sao fundamentais quando identidade estavel, DNS previsivel e persistencia passam a importar

Esse tipo de estudo tem muito valor para quem atua ou quer atuar em DevOps, SRE e tambem em Engenharia de Dados, onde jobs batch, agendamentos, workloads stateful e automacao operacional aparecem com frequencia.

Mais do que escrever YAML, a proposta foi praticar de forma hands-on:

- criar manifests organizados
- validar comportamento com `kubectl`
- documentar cada componente
- transformar estudo tecnico em portfolio demonstravel

Publiquei tudo no GitHub para servir como laboratorio de consulta e evolucao:

🔗 https://github.com/brodyandre/kubernetes-deploy-strategies-lab

Se voce trabalha com Kubernetes, DevOps ou plataformas de dados, vou gostar de trocar ideias sobre como esses workloads aparecem no dia a dia.

#Kubernetes #DevOps #PlatformEngineering #SRE #CloudComputing #Engineering #Infraestrutura #Yaml #GitHubActions #DataEngineering

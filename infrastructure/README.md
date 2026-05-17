# Infrastructure

Ce dossier contient les manifests partages du cluster pour les dependances runtime.

- `configmap.yml`: configuration non sensible pour Postgres et RabbitMQ
- `sealed-secret.yml`: secrets chiffres (mot de passe Postgres, mot de passe RabbitMQ)
- `postgres.yml`: service DNS `postgres` + StatefulSet PostgreSQL
- `rabbitmq.yml`: service DNS `rabbitmq` + Deployment RabbitMQ

Contrat reseau expose aux services QuizUp (namespace `quizup-prod`):

- Postgres: `postgres.quizup-prod.svc.cluster.local:5432`
- RabbitMQ: `rabbitmq.quizup-prod.svc.cluster.local:5672`

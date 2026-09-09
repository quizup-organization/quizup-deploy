# AGENTS.md — quizup-deploy

> **DevOps** : déploiement Kubernetes via **ArgoCD** (pattern app-of-apps). Hors périmètre de
> l'architecture hexagonale Java.

---

## 1. Rôle

Déploiement des composants QuizUp sur Kubernetes :

- **ArgoCD** app-of-apps : une app ArgoCD qui gère toutes les autres (apps de chaque service).
- **Infrastructure** : Postgres, RabbitMQ, sealed-secrets, configmaps, kustomize.
- **Applications** : un dossier par service (frontend, game, gateway, identity, matchmaking,
  social, theme) avec les manifests k8s (deployment, service, ingress).

---

## 2. Structure

```
quizup-deploy/
├── argocd/            ← configuration ArgoCD (app-of-apps)
├── apps/              ← manifests par service
│   ├── game/
│   ├── gateway/
│   ├── identity/
│   ├── matchmaking/
│   ├── social/
│   └── theme/
├── infrastructure/    ← Postgres, RabbitMQ, sealed-secrets, configmap, kustomize
├── namespaces/        ← namespaces.yml
└── scripts/           ← scripts de déploiement / build
```

---

## 3. Services déployés

| Dossier            | Service              | Type         |
|--------------------|----------------------|--------------|
| `apps/gateway`     | `quizup-gateway`     | API Gateway  |
| `apps/identity`    | `quizup-identity`    | microservice |
| `apps/theme`       | `quizup-theme`       | microservice |
| `apps/social`      | `quizup-social`      | microservice |
| `apps/matchmaking` | `quizup-matchmaking` | microservice |
| `apps/game`        | `quizup-game`        | microservice |



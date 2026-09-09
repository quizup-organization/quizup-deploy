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
│   ├── frontend/
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

| Dossier | Service | Type |
|---|---|---|
| `apps/frontend` | `quizup-frontend` | web-application (nginx) |
| `apps/gateway` | `quizup-gateway` | API Gateway |
| `apps/identity` | `quizup-identity` | microservice |
| `apps/theme` | `quizup-theme` | microservice |
| `apps/social` | `quizup-social` | microservice |
| `apps/matchmaking` | `quizup-matchmaking` | microservice |
| `apps/game` | `quizup-game` | microservice |

> **Note** : pas de dossier pour `user-service`, `profile-service` ni `leaderboard-service` —
> cohérent avec le fait que ces services n'existent pas (voir `quizup-gateway/AGENTS.md` §3).

---

## 4. Contrats cassés / TODO

- **Aucun contrat cassé** — c'est un dépôt de déploiement.

---

## 5. Patterns de référence

Hors périmètre hexagonal. Voir `README.md` du repo pour les détails ArgoCD.

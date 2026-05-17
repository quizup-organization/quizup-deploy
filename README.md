# quizup-deploy

GitOps repository for Kubernetes manifests and ArgoCD configuration.

## Structure

- `namespaces/`: Kubernetes namespaces
- `infrastructure/`: shared infra manifests (DB, broker, etc.)
- `apps/`: microservice manifests (one folder per service)
- `argocd/`: ArgoCD applications and app-of-apps
- `.github/workflows/update-image.yml`: automated image tag updater

## Applications déployées

| App           | Image                                     | Path               |
|---------------|-------------------------------------------|--------------------|
| `identity`    | `ghcr.io/quizup-organization/identity`    | `apps/identity`    |
| `theme`       | `ghcr.io/quizup-organization/theme`       | `apps/theme`       |
| `game`        | `ghcr.io/quizup-organization/game`        | `apps/game`        |
| `matchmaking` | `ghcr.io/quizup-organization/matchmaking` | `apps/matchmaking` |
| `challenge`   | `ghcr.io/quizup-organization/challenge`   | `apps/challenge`   |
| `social`      | `ghcr.io/quizup-organization/social`      | `apps/social`      |
| `profile`     | `ghcr.io/quizup-organization/profile`     | `apps/profile`     |
| `gateway`     | `ghcr.io/quizup-organization/gateway`     | `apps/gateway`     |
| `frontend`    | `ghcr.io/quizup-organization/frontend`    | `apps/frontend`    |

## Flux GitOps

```
Service repo (push main)
    → semantic-release (tag vX.Y.Z)
    → Docker build & push ghcr.io/quizup-organization/{service}:{version}
    → repository_dispatch (type: deploy) → quizup-deploy
                                               ↓
                                    update-image.yml
                                        ↓
                              sed newTag in apps/{service}/kustomization.yml
                                        ↓
                                  git commit & push
                                        ↓
                                ArgoCD auto-sync (syncPolicy.automated)
                                        ↓
                                  Kubernetes rollout
```

## Workflow `update-image.yml`

Déclenché automatiquement par `repository_dispatch` de type `deploy` depuis les repos de services.

**Payload attendu** :

```json
{
  "service": "identity",
  "version": "1.2.0",
  "image": "ghcr.io/quizup-organization/identity"
}
```

Le workflow met à jour `apps/{service}/kustomization.yml` avec le nouveau `newTag`, commit, et push. ArgoCD détecte le
changement et déploie automatiquement via le `syncPolicy.automated` configuré dans `argocd/app-of-apps.yml`.

## Configuration runtime (profiles + secrets)

- Chaque service backend (`identity`, `game`, `profile`, `theme`, `social`, `matchmaking`, `gateway`) embarque :
  - un `ConfigMap` par service : `apps/<service>/configmap.yml`
  - un `SealedSecret` par service : `apps/<service>/sealed-secret.yml`
- Les `Deployment` activent `SPRING_PROFILES_ACTIVE=prod` et chargent `envFrom` depuis ces 2 ressources.
- En production Kubernetes, tous les services Spring tournent en `server.port=8080`.

### Generer les SealedSecrets

Les fichiers `sealed-secret.yml` sont generes via le script `scripts/seal-secrets.sh`.

```bash
export SEALED_SECRETS_CERT=/path/to/sealed-secrets-public-cert.pem

export IDENTITY_DB_USERNAME='...'
export IDENTITY_DB_PASSWORD='...'
export IDENTITY_RABBITMQ_USERNAME='...'
export IDENTITY_RABBITMQ_PASSWORD='...'
export IDENTITY_OAUTH2_GOOGLE_CLIENT_ID='...'
export IDENTITY_OAUTH2_GOOGLE_SECRET='...'
export IDENTITY_SERVER_CLIENT_SECRET='...'
export IDENTITY_ADMIN_CLIENT_SECRET='...'

export GAME_DB_USERNAME='...'
export GAME_DB_PASSWORD='...'
export GAME_RABBITMQ_USERNAME='...'
export GAME_RABBITMQ_PASSWORD='...'

export PROFILE_DB_USERNAME='...'
export PROFILE_DB_PASSWORD='...'
export PROFILE_RABBITMQ_USERNAME='...'
export PROFILE_RABBITMQ_PASSWORD='...'

export THEME_DB_USERNAME='...'
export THEME_DB_PASSWORD='...'
export THEME_RABBITMQ_USERNAME='...'
export THEME_RABBITMQ_PASSWORD='...'

export SOCIAL_DB_USERNAME='...'
export SOCIAL_DB_PASSWORD='...'
export SOCIAL_RABBITMQ_USERNAME='...'
export SOCIAL_RABBITMQ_PASSWORD='...'

export MATCHMAKING_DB_USERNAME='...'
export MATCHMAKING_DB_PASSWORD='...'
export MATCHMAKING_RABBITMQ_USERNAME='...'
export MATCHMAKING_RABBITMQ_PASSWORD='...'

export GATEWAY_UNUSED_SECRET='placeholder'
export INFRA_POSTGRES_PASSWORD='...'
export INFRA_RABBITMQ_PASSWORD='...'

./scripts/seal-secrets.sh
```


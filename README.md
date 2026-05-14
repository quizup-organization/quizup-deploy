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

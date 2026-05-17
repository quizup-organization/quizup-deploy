#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

: "${SEALED_SECRETS_CERT:?SEALED_SECRETS_CERT must point to the Sealed Secrets public certificate}"

seal_secret() {
  local service="$1"
  shift

  kubectl create secret generic "quizup-${service}-secret" \
    --namespace quizup-prod \
    "$@" \
    --dry-run=client \
    -o json \
  | kubeseal --cert "${SEALED_SECRETS_CERT}" --format=yaml \
  > "${ROOT_DIR}/apps/${service}/sealed-secret.yml"

  echo "sealed: apps/${service}/sealed-secret.yml"
}

seal_secret identity \
  --from-literal=QUIZUP_DB_USERNAME="${IDENTITY_DB_USERNAME:?missing}" \
  --from-literal=QUIZUP_DB_PASSWORD="${IDENTITY_DB_PASSWORD:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_USERNAME="${IDENTITY_RABBITMQ_USERNAME:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_PASSWORD="${IDENTITY_RABBITMQ_PASSWORD:?missing}" \
  --from-literal=QUIZUP_OAUTH2_GOOGLE_CLIENT_ID="${IDENTITY_OAUTH2_GOOGLE_CLIENT_ID:?missing}" \
  --from-literal=QUIZUP_OAUTH2_GOOGLE_SECRET="${IDENTITY_OAUTH2_GOOGLE_SECRET:?missing}" \
  --from-literal=QUIZUP_IDENTITY_SERVER_CLIENT_SECRET="${IDENTITY_SERVER_CLIENT_SECRET:?missing}" \
  --from-literal=QUIZUP_IDENTITY_ADMIN_CLIENT_SECRET="${IDENTITY_ADMIN_CLIENT_SECRET:?missing}"

seal_secret game \
  --from-literal=QUIZUP_DB_USERNAME="${GAME_DB_USERNAME:?missing}" \
  --from-literal=QUIZUP_DB_PASSWORD="${GAME_DB_PASSWORD:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_USERNAME="${GAME_RABBITMQ_USERNAME:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_PASSWORD="${GAME_RABBITMQ_PASSWORD:?missing}"

seal_secret profile \
  --from-literal=QUIZUP_DB_USERNAME="${PROFILE_DB_USERNAME:?missing}" \
  --from-literal=QUIZUP_DB_PASSWORD="${PROFILE_DB_PASSWORD:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_USERNAME="${PROFILE_RABBITMQ_USERNAME:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_PASSWORD="${PROFILE_RABBITMQ_PASSWORD:?missing}"

seal_secret theme \
  --from-literal=QUIZUP_DB_USERNAME="${THEME_DB_USERNAME:?missing}" \
  --from-literal=QUIZUP_DB_PASSWORD="${THEME_DB_PASSWORD:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_USERNAME="${THEME_RABBITMQ_USERNAME:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_PASSWORD="${THEME_RABBITMQ_PASSWORD:?missing}"

seal_secret social \
  --from-literal=QUIZUP_DB_USERNAME="${SOCIAL_DB_USERNAME:?missing}" \
  --from-literal=QUIZUP_DB_PASSWORD="${SOCIAL_DB_PASSWORD:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_USERNAME="${SOCIAL_RABBITMQ_USERNAME:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_PASSWORD="${SOCIAL_RABBITMQ_PASSWORD:?missing}"

seal_secret matchmaking \
  --from-literal=QUIZUP_DB_USERNAME="${MATCHMAKING_DB_USERNAME:?missing}" \
  --from-literal=QUIZUP_DB_PASSWORD="${MATCHMAKING_DB_PASSWORD:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_USERNAME="${MATCHMAKING_RABBITMQ_USERNAME:?missing}" \
  --from-literal=QUIZUP_RABBITMQ_PASSWORD="${MATCHMAKING_RABBITMQ_PASSWORD:?missing}"

seal_secret gateway \
  --from-literal=QUIZUP_UNUSED_SECRET="${GATEWAY_UNUSED_SECRET:?missing}"

kubectl create secret generic quizup-infra-secret \
  --namespace quizup-prod \
  --from-literal=POSTGRES_PASSWORD="${INFRA_POSTGRES_PASSWORD:?missing}" \
  --from-literal=RABBITMQ_DEFAULT_PASS="${INFRA_RABBITMQ_PASSWORD:?missing}" \
  --dry-run=client \
  -o json \
| kubeseal --cert "${SEALED_SECRETS_CERT}" --format=yaml \
> "${ROOT_DIR}/infrastructure/sealed-secret.yml"

echo "sealed: infrastructure/sealed-secret.yml"


SHELL := /bin/bash

########################################################################################
# Environment Checks
########################################################################################

CHECK_ENV:=$(shell ./scripts/check-environment.sh)
ifneq ($(CHECK_ENV),)
$(error Check environment dependencies.)
endif


########################################################################################
# Targets
########################################################################################

help: ## Help message
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

helm: ## Install Helm 3 dependency
	@./scripts/install-helm.sh

helm-plugins: ## Install Helm plugins
	@helm plugin install https://github.com/databus23/helm-diff

repos: ## Add Helm repositories for dependencies
	@echo "=> Installing Helm repos"
	@helm repo add grafana https://grafana.github.io/helm-charts
	@helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	@helm repo update
	@echo

tools: install-prometheus install-metrics ## Intall/Update Prometheus/Grafana, Loki, Metrics Server

pull: ## Git pull node-launcher repository
	@git clean -idf
	@git pull origin $(shell git rev-parse --abbrev-ref HEAD)

update-dependencies:
	@echo "=> Updating Helm chart dependencies"
	@helm dependencies update ./thornode-stack
	@echo

update-trust-state: ## Updates statesync trusted height/hash and Midgard blockstore hashes from Nine Realms
	@./scripts/update-trust-state.sh

mnemonic: ## Retrieve and display current mnemonic for backup from your THORNode
	@./scripts/mnemonic.sh

password: ## Retrieve and display current password for backup from your THORNode
	@./scripts/password.sh

pods: ## Get THORNode Kubernetes pods
	@./scripts/pods.sh

pre-install: update-dependencies ## Pre deploy steps for a THORNode (secret creation)
	@./scripts/pre-install.sh

install: update-dependencies ## Deploy a THORNode
	@./scripts/install.sh

recycle: update-dependencies ## Destroy and recreate a THORNode recycling existing daemons to avoid re-sync
	@./scripts/recycle.sh

update: pull update-dependencies ## Update a THORNode to latest version
	@./scripts/update.sh

status: ## Display current status of your THORNode
	@./scripts/status.sh

reset: ## Reset and resync a service from scratch on your THORNode. This command can take a while to sync back to 100%.
	@./scripts/reset.sh

hard-reset-thornode: ## Hard reset and resync thornode service from scratch on your THORNode, leaving no bak/* files.
	@./scripts/hard-reset-thornode.sh

backup: ## Backup specific files from either thornode of bifrost service of a THORNode.
	@./scripts/backup.sh

full-backup: ## Create volume snapshots and backups for both thornode and bifrost services.
	@./scripts/full-backup.sh

restore-backup: ## Restore backup specific files from either thornode of bifrost service of a THORNode.
	@./scripts/restore-backup.sh

snapshot: ## Snapshot a volume for a specific THORNode service.
	@./scripts/snapshot.sh

restore-snapshot: ## Restore a volume for a specific THORNode service from a snapshot.
	@./scripts/restore-snapshot.sh

wait-ready: ## Wait for all pods to be in Ready state
	@./scripts/wait-ready.sh

destroy: ## Uninstall current THORNode
	@./scripts/destroy.sh

export-state: ## Export chain state
	@./scripts/export-state.sh

hard-fork: ## Hard fork chain
	@./scripts/hard-fork.sh

shell: ## Open a shell for a selected THORNode service
	@./scripts/shell.sh

debug: ## Open a shell for THORNode service mounting volume to debug
	@./scripts/debug.sh

restore-external-snapshot: ## Restore THORNode from external snapshot.
	@./scripts/restore-external-snapshot.sh

rescan-yggdrasil-utxo: ## Rescan Yggdrasil address for UTXO chains
	@./scripts/rescan-yggdrasil-utxo.sh

rescan-asgard-utxo: ## Rescan Asgard address for UTXO chains
	@./scripts/rescan-asgard-utxo.sh

watch: ## Watch the THORNode pods in real time
	@./scripts/watch.sh

logs: ## Display logs for a selected THORNode service
	@./scripts/logs.sh

restart: ## Restart a selected THORNode service
	@./scripts/restart.sh

halt: ## Halt a selected THORNode service
	@./scripts/halt.sh

set-node-keys: ## Send a set-node-keys transaction to your THORNode
	@./scripts/set-node-keys.sh

set-version: ## Send a set-version transaction to your THORNode
	@./scripts/set-version.sh

set-ip-address: ## Send a set-ip-address transaction to your THORNode
	@./scripts/set-ip-address.sh

set-monitoring: ## Enable PagerDuty or Deadmans Snitch monitoring via Prometheus/Grafana re-deploy
	@./scripts/set-monitoring.sh

relay: ## Send a message that is relayed to a public Discord channel
	@./scripts/relay.sh

mimir: ## Send a mimir command to set a key/value
	@./scripts/mimir.sh

upgrade-vote: ## Send a vote command for an upgrade proposal
	@./scripts/upgrade-vote.sh

ban: ## Send a ban command with a node address
	@./scripts/ban.sh

pause: ## Send a pause-chain transaction to your THORNode
	@./scripts/pause.sh

resume: ## Send a resume-chain transaction to your THORNode
	@./scripts/resume.sh

observe-tx-ins: ## Manually observe missed inbound transactions.
	@./scripts/observe-tx-ins.sh

observe-tx-outs: ## Manually observe missed outbound transactions.
	@./scripts/observe-tx-outs.sh

destroy-tools: destroy-prometheus destroy-loki ## Uninstall Prometheus/Grafana, Loki

install-loki: repos ## Install/Update Loki logs management stack
	@./scripts/install-loki.sh

destroy-loki: ## Uninstall Loki logs management stack
	@./scripts/destroy-loki.sh

install-prometheus: repos ## Install/Update Prometheus/Grafana stack
	@./scripts/install-prometheus.sh

destroy-prometheus: ## Uninstall Prometheus/Grafana stack
	@./scripts/destroy-prometheus.sh

install-metrics: repos ## Install/Update Metrics Server
	@echo "=> Installing Metrics"
	@kubectl get svc -A | grep -q metrics-server || kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
	@echo

destroy-metrics: ## Uninstall Metrics Server
	@echo "=> Deleting Metrics"
	@kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
	@echo

install-provider: ## Install Thorchain provider
	@scripts/install-provider.sh

destroy-provider: ## Uninstall Thorchain provider
	@scripts/destroy-provider.sh

install-mirroring: ## Install repository mirroring cronjob
	@helm upgrade --install mirroring mirroring/ -n thornode --wait

grafana: ## Access Grafana UI through port-forward locally
	@echo User: admin
	@echo Password: thorchain
	@echo Open your browser at http://localhost:3000
	@kubectl -n prometheus-system port-forward service/prometheus-grafana 3000:80

prometheus: ## Access Prometheus UI through port-forward locally
	@echo Open your browser at http://localhost:9090
	@kubectl -n prometheus-system port-forward service/prometheus-kube-prometheus-prometheus 9090

alert-manager: ## Access Alert-Manager UI through port-forward locally
	@echo Open your browser at http://localhost:9093
	@kubectl -n prometheus-system port-forward service/prometheus-kube-prometheus-alertmanager 9093

lint: ## Run linters (development)
	./scripts/lint.sh

verify-ethereum: ## Verify Ethereum finalized slot state root
	@./scripts/verify-ethereum.sh

.PHONY: help helm repo pull tools install-loki install-prometheus install-metrics export-state hard-fork destroy-tools destroy-loki destroy-prometheus destroy-metrics prometheus grafana alert-manager mnemonic update-dependencies reset restart pods deploy update destroy status shell watch logs set-node-keys set-ip-address set-version upgrade-vote pause resume lint verify-ethereum

.EXPORT_ALL_VARIABLES:

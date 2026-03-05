# OTel Counter Demo — VNet Flow Events

A demo Azure Function App (.NET 10) that demonstrates OpenTelemetry **Counter** instrumentation for simulated VNet flow log events. Deployed to Azure via `azd` and Terraform.

## What This Demonstrates

- **OpenTelemetry Counter** (`Counter<long>`) — a monotonic, cumulative metric that only goes up
- **Dimensional tags** — each counter increment includes `flow.direction`, `flow.action`, and `flow.protocol` for rich slicing in queries
- **Azure Monitor integration** — metrics are exported to Application Insights via the Azure Monitor OpenTelemetry exporter
- **KQL aggregation** — sample queries show how to answer "how many events happened between t1 and t2?" using `customMetrics`

## How It Works

A timer-triggered Azure Function fires every 30 seconds. Each invocation simulates a batch of VNet flow events (5–100 per tag combination) and increments the `vnet.flow.events` counter with dimensional tags. The OpenTelemetry SDK aggregates these increments and exports them to Application Insights, where they appear in the `customMetrics` table.

## Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local)
- An Azure subscription

## Quick Start

### Deploy to Azure

```bash
azd up
```

This will:
1. Prompt for an environment name and Azure subscription
2. Provision infrastructure (Resource Group, Storage, Log Analytics, App Insights, Function App) via Terraform
3. Build and deploy the .NET 10 Function App

### Run Locally

```bash
cd src/OtelCounterDemo
func start
```

> **Note:** Local runs require Azurite or an Azure Storage connection string in `local.settings.json`. Metrics will only appear in App Insights if you add an `APPLICATIONINSIGHTS_CONNECTION_STRING` to `local.settings.json`.

## Viewing Metrics

1. Open the [Azure Portal](https://portal.azure.com)
2. Navigate to your Application Insights resource (`ai-<environment-name>`)
3. Go to **Logs** (under Monitoring)
4. Run the KQL queries from `kql/counter-queries.kql`

> **Tip:** Metrics may take 2–5 minutes to appear after the function starts running.

## Sample KQL Queries

See [`kql/counter-queries.kql`](kql/counter-queries.kql) for 7 ready-to-run queries:

| # | Query | Answers |
|---|-------|---------|
| 1 | Total in time range | "How many flow events between t1 and t2?" |
| 2 | 5-minute buckets | "What does volume look like over time?" |
| 3 | By direction | "Inbound vs outbound?" |
| 4 | By action | "Allowed vs denied?" |
| 5 | Denied over time | "When are denied flows spiking?" |
| 6 | By protocol | "TCP vs UDP distribution?" |
| 7 | Direction × Action | "How do dimensions cross-correlate?" |

## Cleanup

```bash
azd down
```

## Project Structure

```
otel-counter-demo/
├── azure.yaml              # azd project definition
├── infra/                   # Terraform infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── src/OtelCounterDemo/     # .NET 10 Function App
│   ├── Program.cs           # Host + OTel configuration
│   ├── FlowEventFunction.cs # Timer-triggered function
│   ├── FlowEventMetrics.cs  # Counter definition
│   └── host.json
├── kql/
│   └── counter-queries.kql  # Sample KQL queries
└── README.md
```

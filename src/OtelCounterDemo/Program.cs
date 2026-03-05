using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Azure.Functions.Worker.OpenTelemetry;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Azure.Monitor.OpenTelemetry.Exporter;
using OtelCounterDemo;

var builder = FunctionsApplication.CreateBuilder(args);

var otelBuilder = builder.Services.AddOpenTelemetry();
otelBuilder.UseAzureMonitorExporter();
otelBuilder.UseFunctionsWorkerDefaults();
otelBuilder.WithMetrics(metrics =>
{
    metrics.AddMeter(FlowEventMetrics.MeterName);
});

builder.Services.AddSingleton<FlowEventMetrics>();

builder.Build().Run();

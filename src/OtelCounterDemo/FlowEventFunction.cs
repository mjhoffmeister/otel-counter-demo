using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace OtelCounterDemo;

public class FlowEventFunction
{
    private readonly ILogger<FlowEventFunction> _logger;
    private readonly FlowEventMetrics _metrics;

    private static readonly string[] Directions = ["inbound", "outbound"];
    private static readonly string[] Actions = ["allow", "deny"];
    private static readonly string[] Protocols = ["TCP", "UDP"];

    public FlowEventFunction(ILogger<FlowEventFunction> logger, FlowEventMetrics metrics)
    {
        _logger = logger;
        _metrics = metrics;
    }

    [Function("SimulateFlowEvents")]
    public void Run([TimerTrigger("*/30 * * * * *")] TimerInfo timerInfo)
    {
        var random = Random.Shared;

        // Simulate multiple flow events with different tag combinations
        var totalEvents = 0L;
        foreach (var direction in Directions)
        {
            foreach (var action in Actions)
            {
                foreach (var protocol in Protocols)
                {
                    // Not every combination fires each tick — skip some randomly
                    if (random.NextDouble() < 0.3)
                        continue;

                    var count = (long)random.Next(5, 101);
                    _metrics.RecordFlowEvents(count, direction, action, protocol);
                    totalEvents += count;
                }
            }
        }

        _logger.LogInformation("Simulated {TotalEvents} VNet flow events at {Timestamp}",
            totalEvents, DateTime.UtcNow);
    }
}

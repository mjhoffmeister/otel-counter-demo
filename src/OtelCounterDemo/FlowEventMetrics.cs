using System.Diagnostics.Metrics;

namespace OtelCounterDemo;

public class FlowEventMetrics
{
    public const string MeterName = "OtelCounterDemo.FlowEvents";

    private readonly Counter<long> _flowEvents;

    public FlowEventMetrics(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create(MeterName);
        _flowEvents = meter.CreateCounter<long>("vnet.flow.events", "events", "Number of VNet flow log events");
    }

    public void RecordFlowEvents(long count, string direction, string action, string protocol)
    {
        _flowEvents.Add(count,
            new KeyValuePair<string, object?>("flow.direction", direction),
            new KeyValuePair<string, object?>("flow.action", action),
            new KeyValuePair<string, object?>("flow.protocol", protocol));
    }
}

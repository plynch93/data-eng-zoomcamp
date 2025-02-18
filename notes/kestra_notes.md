# Kestra Notes

##

## Comparision of different orchestration tools
Here's a comparison table for popular workflow orchestration tools like Kestra, Apache Airflow, Prefect, and Dagster:

| Feature                        | **Kestra**                          | **Apache Airflow**               | **Prefect**                         | **Dagster**                       |
|--------------------------------|--------------------------------------|-----------------------------------|--------------------------------------|------------------------------------|
| **Definition Type**            | YAML                                | Python                           | Python                              | Python                            |
| **Architecture**               | Distributed (Kafka, Elasticsearch) | Centralized (Scheduler & Workers)| Centralized or Distributed         | Centralized or Distributed       |
| **Use Case Focus**             | General workflows, event-driven     | Data pipelines, batch processing | Data workflows, task orchestration | Data pipelines, data assets      |
| **Fault Tolerance**            | Built-in retries and error handling | Manual setup with XComs, retries | Native retries, task states         | Strong error handling, retries   |
| **Scalability**                | High (distributed architecture)     | Moderate (Celery, Kubernetes)    | High (cloud-native, scalable)       | High (designed for modern data)  |
| **Observability**              | Web UI, real-time logs              | Web UI, but basic visualization  | Detailed UI, logs, states           | Advanced UI, lineage tracking    |
| **Event-Driven**               | Yes                                 | Limited                          | Yes                                 | Partial (via sensors)            |
| **Task Dependencies**          | Declarative                         | Explicit (via Python)            | Explicit (via Python)               | Explicit (via Python)            |
| **Ease of Use**                | Simple YAML configuration           | Requires Python expertise        | Python-first but user-friendly      | Python-first, more learning curve|
| **Integration**                | Cloud, APIs, message queues         | Broad (via providers)            | Cloud-native, SaaS, and more        | Cloud, SaaS, data assets         |
| **Community & Ecosystem**      | Growing, newer tool                 | Mature, large community          | Growing rapidly, strong ecosystem   | Growing, focus on data systems   |
| **Open-Source**                | Yes                                 | Yes                              | Yes                                 | Yes                              |
| **Cloud-Native Support**       | Partial                             | Limited                          | Strong (Prefect Cloud available)    | Moderate                         |
| **Setup Complexity**           | Moderate (requires Kafka/Elastic)   | High (requires worker setup)     | Low (especially with Prefect Cloud)| Moderate                         |
| **Best For**                   | Event-driven workflows, automation  | Batch ETL, custom data pipelines | Simple to complex workflows         | Data-centric workflows           |

### Highlights:
- **Kestra**: Great for event-driven workflows and scalable distributed systems with modern YAML configuration.
- **Apache Airflow**: Best for traditional ETL workflows and mature ecosystems but requires Python expertise.
- **Prefect**: Ideal for developers seeking cloud-native orchestration with simplicity and strong SaaS integrations.
- **Dagster**: Focuses on data pipelines and lineage, excellent for teams managing data assets.

## Install with docker-compose
This will install and launch postgres alongside kestra

Download docker-compose file
```bash
curl -o docker-compose.yml \
https://raw.githubusercontent.com/kestra-io/kestra/develop/docker-compose.yml
```

Launch kestra
```bash
docker-compose up -d
```

## Install with docker
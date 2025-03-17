This file contains the workings and answers for `Module 6 - Streaming`.
Questions can be found [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2025/06-streaming/homework.md).

## Setup

### Question 1: Redpanda version
Check the output of the command rpk help inside the container. The name of the container is redpanda-1

```bash
docker exec redpanda-1 rpk --version
```

**Answer**
rpk version v24.2.18 (rev f9a22d4430)

### Question 2: Creating a topic
Create a topic with name `green-trips` 

What's the output of the command for creating a topic? Include the entire output in your answer.

Output of `rpk topic --help`: 
```bash
Create, delete, produce to and consume from Redpanda topics

Usage:
  rpk topic [flags]
  rpk topic [command]

Available Commands:
  add-partitions   Add partitions to existing topics
  alter-config     Set, delete, add, and remove key/value configs for a topic
  consume          Consume records from topics
  create           Create topics
  delete           Delete topics
  describe         Describe topics
  describe-storage Describe the topic storage status
  list             List topics, optionally listing specific topics
  produce          Produce records to a topic
  trim-prefix      Trim records from topics

Flags:
  -h, --help   Help for topic

Global Flags:
      --config string            Redpanda or rpk config file; default search paths are
                                 "/var/lib/redpanda/.config/rpk/rpk.yaml", $PWD/redpanda.yaml,
                                 and /etc/redpanda/redpanda.yaml
  -X, --config-opt stringArray   Override rpk configuration settings; '-X help' for detail or
                                 '-X list' for terser detail
      --profile string           rpk profile to use
  -v, --verbose                  Enable verbose logging

Use "rpk topic [command] --help" for more information about a command.
```

**Answer**
```bash
rpk topic create green-trips
```
Output:
```
TOPIC        STATUS
green-trips  OK
```

### Question 3. Connecting to the Kafka server

Launch a notebook
```bash
jupyter-notebook --no-browser --port=8888
```

```python
import json

from kafka import KafkaProducer

def json_serializer(data):
    return json.dumps(data).encode('utf-8')

server = 'localhost:9092'

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=json_serializer
)

producer.bootstrap_connected()
```

What's the output
of the last command?

**Answer**
True

## Question 4: Sending the Trip Data
Read the taxi data and publish to the `green-trips` topic.

How much time did it take to send the entire dataset and flush?
**Answer**
`49.22 seconds`

## Question 5: Build a Sessionization Window

Which pickup and drop off locations have the longest unbroken streak of taxi trips?

**Answer**
Pick-up: East Harlem North
Drop-off: East Harlem South

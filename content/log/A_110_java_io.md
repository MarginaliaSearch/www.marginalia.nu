---
title: The sorry state of Java deserialization
date: 2024-09-22
tags:
  - programming
---

I've been on a bit of a frustration-driven quest to solve a problem I frequently encounter 
working on the search engine, that is, reading data from disk.

You'd think this would be a pretty basic thing, but doing this in a way that is half-way performant is surprisingly hard and requires avoiding basically all the high level tools at your disposal.  

There's a common sentiment that modern hardware is fast, so this may not matter, but we aren't speaking a 30% performance hit, the the question is how many orders of magnitude you're willing to forego. 

Indeed for dozens of megabytes of data this may still not matter *too* much, but when dealing with hundreds of gigabytes, it starts to chafe.

Let's consider a simplified version of the 1 billion rows challenge.  This is a very 
accurate representation of the sort of tasks you encounter doing search engine work, and 
simple enough to follow along.

As a reminder, the task is to read 1 billion temperature measurements, one assigned to a city, and then aggregate that with min/max/avg.  The tests are run multiple times and we only care about the best run-time.  This means that the data generally is read from RAM, but we'll be happy to see disk-like performance.

Unlike the original challenge, *we'll not consider CSV ingestion*, but let the contenders 
use whatever on-disk representations and loading mechanisms are available.

The benchmark will cover

* Parquet
* Protobuf
* JDBC
* Java's stream and NIO APIs

Scroll to the end if you just want the numbers.

**Smartphone enjoyers will want to switch to horizontal mode for this article due to code samples that barely fit on desktop**
## Reference numbers

Let's also consider DuckDB as a sort of reference benchmark, as I will always shill for this fantastic tool.   If we are orders of magnitude slower than DuckDB, something is off.  We'll store the numbers as fixed width integers and cities as varchars. 

```sql
create table measurements(
   city varchar, 
   temperature int
)
```

Aggregating 1 billion rows in DuckDB from RAM takes about 2.6s, and storing it on disk uses 3.0 GB.  

DuckDB also reads parquet files, and doing that increases the numbers to 4.5s, 3.8GB for Snappy and 5.5s, 3.0GB for Zstd.  The intuition I want to provide here is that this is an opearation that could take seconds, and the data could sensibly fit in a few GB.  

A decent hard drive will read sequential data at about 500 MB/s (as is the one we're using for this test), so we'll also add some reference times for 2GB and 10 GB assuming such a disk.  Though the data is likely cached in RAM, we'll still be happy if we approach these low-ball theoretical speeds. 

Let's look at our reference times before testing.

| Impl                       | Runtime | Size On Disk |
| -------------------------- | ------- | ------------ |
| DuckDB                     | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*            | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB   | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*           | 20.0s   | 10 GB        |

----

## DataInputStream + BufferedInputStream 

Using InputStreams is a fairly idiomatic Java IO choice, even though this API is showing its age and is known not be the fastest option.

```java
try (var citiesDis = new DataInputStream(
                         new BufferedInputStream(Files.newInputStream(citiesFile)));
     var temperaturesDis = new DataInputStream(
                         new BufferedInputStream(Files.newInputStream(temperaturesFile)))) 
{

    while (true) {
        int temperature = temperaturesDis.readShort();
        String city = citiesDis.readUTF();
        observers.computeIfAbsent(city, 
                         k -> new ResultObserver())
                      .observe(temperature / 100.);
    }
}
catch (EOFException ex) {} // ignore
```

| Impl                                                          | Runtime | Size On Disk |
|---------------------------------------------------------------|---------|--------------|
| DuckDB                                                        | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*                                               | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB                                    | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB                                      | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*                                              | 20.0s   | 10 GB        |
| **DIS+BIS**                                                   | 300s    | 10 GB        |

## Streaming the data over JDBC

A DBMS is often a popular choice for data storage, and they are indeed very good if your data is mutable.  In this case it's not, and the JDBC tax is steep.  The Enterprise choice would of course be to put an an EntityManager on top of this, but I'm taking pity on the benchmark and foregoing that step.  

This is querying DuckDB, but e.g. sqlite gives similar performance and a proper DBMS isn't better.  A big part of the problem isn't with the databases, but the cost of moving the data from the database to Java.

```java
try (var queryStmt = conn.createStatement();
     var rs = queryStmt.executeQuery(
         "select city, temperature from measurements"))
{
    queryStmt.setFetchSize(1000);
    while (rs.next()) {
        observerMap.computeIfAbsent(rs.getString(1), 
                       k -> new ResultsObserver())
                   .observe(rs.getInt(2) / 100.);
    }
}
```

| Impl                                                          | Runtime | Size On Disk |
|---------------------------------------------------------------|---------|--------------|
| DuckDB                                                        | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*                                               | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB                                    | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB                                      | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*                                              | 20.0s   | 10 GB        |
| DIS+BIS                                                       | 300s    | 10 GB        |
| **Stream all 1B rows over JDBC**                              | 620s	  | 3.0 GB       |

## Protobuf

Protobuf is Google's dog in the fight.  It's probably more widely known as a wire format,
but can be used to store data on disk as well.  It's main benefit is the evolvable schema.

```protobuf
message OneBrcProtoRecord {
  string city = 1;
  int32 temperature = 2;
}
```

The suggested way of deserializing protobuf messages to disk is to use an input stream, 
and the parseDelimitedFrom-method.  This is easy, but not very fast. 

```java
try (var is = new BufferedInputStream(
                    Files.newInputStream(tempFile))) {
    for (int i = 0; i < records; i++) {
        Onebrc.OneBrcProtoRecord record = 
               Onebrc.OneBrcProtoRecord.parseDelimitedFrom(is);
        stats.computeIfAbsent(record.getCity(), 
                  k -> new ResultsObserver())
             .observe(record.getTemperature());
    }
}
```

**Note**: The <a href="https://protobuf.dev/getting-started/javatutorial/#reading-a-message">protobuf tutorial</a> foregoes the step of adding the BufferedInputStream when performing this task.  I won't include it in the high score table but the runtime when you do that is in excess of half an hour.

| Impl                                                          | Runtime | Size On Disk |
|---------------------------------------------------------------|---------|--------------|
| DuckDB                                                        | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*                                               | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB                                    | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB                                      | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*                                              | 20.0s   | 10 GB        |
| DIS+BIS                                                       | 300s    | 10 GB        |
| **Protobuf + BIS**                                            | 580s    | 7.5 GB       |
| Stream all 1B rows over JDBC                                  | 620s	  | 3.0 GB       |

Let's instead use Java NIO to read the protobuf data.  This is considerably more finicky,
but also a fair bit faster.  I'll admit it's possible I'm not doing this the optimal way, the 
documentation for this API is a bit thin.

```java
ByteBuffer buffer = ByteBuffer.allocate(4096); // 4K block size to match the disk

try (var fc = (FileChannel) Files.newByteChannel(tempFile, StandardOpenOption.READ)) {

    for (int i = 0; i < records; i++) {

        int size;
        if (!buffer.hasRemaining()) {
            buffer.clear();
            fc.read(buffer);
            buffer.flip();
        }
        size = buffer.get();

        if (buffer.remaining() < size) {
            buffer.compact();
            fc.read(buffer);
            buffer.flip();
        }

        var cis = CodedInputStream.newInstance(
                     buffer.slice(buffer.position(), size));
        var record = Onebrc.OneBrcProtoRecord.parseFrom(cis);
        buffer.position(buffer.position() + size);

        stats.computeIfAbsent(record.getCity(), k -> new ResultsObserver())
             .observe(record.getTemperature());
    }

```

| Impl                                                          | Runtime | Size On Disk |
|---------------------------------------------------------------|---------|--------------|
| DuckDB                                                        | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*                                               | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB                                    | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB                                      | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*                                              | 20.0s   | 10 GB        |
| **Protobuf + NIO**                                            | 91s     | 12.3 GB      |
| DIS+BIS                                                       | 300s    | 10 GB        |
| Protobuf + BIS                                                | 580s    | 12.3 GB      |
| Stream all 1B rows over JDBC                                  | 620s	  | 3.0 GB       |

## Parquet in Java with parquet-floor shim

Reading parquet files in Java outside of the Hadoop ecosystem is a serious headache. 

There's a somewhat hacky shim available called *parquet-floor* that lets you access Hadoop's parquet implementation outside of Hadoop.  This may have a performance impact.  

Hold onto your hat, there's some boilerplate

```java
try (var stream = ParquetReader.streamContent(tempFile.toFile(),
        HydratorSupplier.constantly(new OneBRCParquetHydrator()))) 
{
    stream.collect(Collectors.groupingBy(r -> r.city, 
                   Collectors.summarizingDouble(r -> r.temperature / 100.)))
            .forEach(...);
}

public static class OneBRCParquetRecord {
    public String city;
    public int temperature;

    public OneBRCParquetRecord() {}
    public OneBRCParquetRecord(String city, int temperature) {
        this.city = city;
        this.temperature = temperature;
    }

    public static MessageType schema = new MessageType(
            OneBRCParquetRecord.class.getSimpleName(),
            Types.required(BINARY).as(stringType()).named("city"),
            Types.required(INT32).named("temperature")
    );


    public void dehydrate(ValueWriter valueWriter) {
        valueWriter.write("city", city);
        valueWriter.write("temperature", temperature);
    }

    public OneBRCParquetRecord add(String heading, Object value) {
        if ("city".equals(heading)) {
            city = (String) value;
        } else if ("temperature".equals(heading)) {
            temperature = (Integer) value;
        } else {
            throw new UnsupportedOperationException("Unknown heading '" + heading + "'");
        }

        return this;
    }
}

static class OneBRCParquetHydrator implements Hydrator<OneBRCParquetRecord, OneBRCParquetRecord> {

    @Override
    public OneBRCParquetRecord start() {
        return new OneBRCParquetRecord();
    }

    @Override
    public OneBRCParquetRecord add(OneBRCParquetRecord target, String heading, Object value) {
        return target.add(heading, value);
    }

    @Override
    public OneBRCParquetRecord finish(OneBRCParquetRecord target) {
        return target;
    }

}

```

| Impl                                                          | Runtime | Size On Disk |
|---------------------------------------------------------------|---------|--------------|
| DuckDB                                                        | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*                                               | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB                                    | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB                                      | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*                                              | 20.0s   | 10 GB        |
| Protobuf + NIO                                                | 91s     | 12.3 GB      |
| **Parquet in Java**                                           | 134s    | 2.4 GB       |
| DIS+BIS                                                       | 300s    | 10 GB        |
| Protobuf + BIS                                                | 580s    | 12.3 GB      |
| Stream all 1B rows over JDBC                                  | 620s	  | 3.0 GB       |

Stockholm syndrome may have you thinking this is not *that* bad, but keep in mind we're 
operating at 2% the speed of the reference timestamp for ~2 GB of data.

## ObjectInputStream

Another contender from the dark ages of Java.  I don't think anyone is using this anymore...?

```java
try (var ois = new ObjectInputStream(new BufferedInputStream(Files.newInputStream(data)))) {
    for (;;) {
        if (!(ois.readObject() instanceof JavaSerializableMeasurement jsm))
           continue;
		observerMap.computeIfAbsent(jsm.city, 
						k -> new ResultsObserver())
				   .observe(jsm.temperature / 100.);
	
    }
}
catch (EOFException e) {}

// ...

record JavaSerializableMeasurement(
  String city, 
  int temperature
) implements Serializable {}
```

| Impl                                                          | Runtime | Size On Disk |
|---------------------------------------------------------------|---------|--------------|
| DuckDB                                                        | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*                                               | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB                                    | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB                                      | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*                                              | 20.0s   | 10 GB        |
| Protobuf + NIO                                                | 91s     | 12.3 GB      |
| Parquet in Java                                               | 134s    | 2.4 GB       |
| **OIS**                                                       | 260s    | 14 GB        |
| DIS+BIS                                                       | 300s    | 10 GB        |
| Protobuf + BIS                                                | 580s    | 12.3 GB      |
| Stream all 1B rows over JDBC                                  | 620s	  | 3.0 GB       |

## Custom solutions

Alright, this is kind of ridiculous.  Let's try to improve the numbers by implementing something ad-hoc. 

First attempt is to just serialize the data ourselves to a file channel using a 4K buffer.  The format will be

```
1 byte: city length
N bytes: city name
2 bytes: temperature
```

```java
var buffer = ByteBuffer.allocate(4096);
try (var fc = 
	 (FileChannel) Files.newByteChannel(tempFile, 
                        StandardOpenOption.READ)) 
{

    buffer.flip();

    for (int i = 0; i < records; i++) {

        if (buffer.remaining() < 32) {
            buffer.compact();
            fc.read(buffer);
            buffer.flip();
        }

        int len = buffer.get();
        byte[] cityBytes = new byte[len];
        buffer.get(cityBytes);
        String city = new String(cityBytes);
        int temperature = buffer.getShort();

        stats.computeIfAbsent(city, k -> new ResultsObserver())
             .observe(temperature / 100.);
    }
```

| Impl                                                          | Runtime | Size On Disk |
|---------------------------------------------------------------|---------|--------------|
| DuckDB                                                        | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*                                               | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB                                    | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB                                      | 5.5s    | 3.0 GB       |
| *Disk I/O 10 GB*                                              | 20.0s   | 10 GB        |
| **Custom Protocol**                                           | 56s     | 9.5GB        |
| Protobuf + NIO                                                | 91s     | 12.3 GB      |
| Parquet in Java                                               | 134s    | 2.4 GB       |
| OIS                                                           | 260s    | 14 GB        |
| DIS+BIS                                                       | 300s    | 10 GB        |
| Protobuf + BIS                                                | 580s    | 12.3 GB      |
| Stream all 1B rows over JDBC                                  | 620s	  | 3.0 GB       |

We can do much better though.  The first attempt has two problems:

* We're allocating arrays every time we read an item
* We're parsing those bytes into Java UTF-8 Strings (which is slow)

Removing the string parsing shaves 15 seconds off the time, down to 40, 
but it's not enough, it's possible to entirely get rid of the allocations!

What if we put the city names in a separate newline-separated file, 
and just store their index in that file as a fixed-width ordinal?  

This is in one way cheating a bit since we're reading less data, but on the other hand I'll argue it's using your head when storing the data, and something a sane storage format should do. 

```java
List<String> cities = Files.readAllLines(citiesPath);

// using an array over a map saves about 6-7 seconds runtime
// via better locality
ResultsObserver[] stats = new ResultsObserver[cities.size()];
Arrays.setAll(stats, i -> new ResultsObserver());

try (var fc = (FileChannel) Files.newByteChannel(tempFile, StandardOpenOption.READ)) {

    for (int i = 0; i < records; i++) {

        if (buffer.remaining() < 3) {
            buffer.compact();
            fc.read(buffer);
            buffer.flip();
        }

        int cityOrd = buffer.get();
        int temperature = buffer.getShort();
        stats[cityOrd].observe(temperature / 100.);
```


| Impl                         | Runtime | Size On Disk |
| ---------------------------- | ------- | ------------ |
| DuckDB                       | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*              | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB   | 4.5s    | 5.5 GB       |
| Parquet (Zstd) in DuckDB     | 5.5s    | 3.0 GB       |
| **Custom Encoding 2**        | 6.7s    | 2.8GB        |
| *Disk I/O 10 GB*             | 20.0s   | 10 GB        |
| Custom Encoding              | 56s     | 9.5GB        |
| Protobuf + NIO               | 91s     | 12.3 GB      |
| Parquet in Java              | 134s    | 2.4 GB       |
| OIS                          | 260s    | 14 GB        |
| DIS+BIS                      | 300s    | 10 GB        |
| Protobuf + BIS               | 580s    | 12.3 GB      |
| Stream all 1B rows over JDBC | 620s    | 3.0 GB       |

We can squeeze some additional performance out of this by memory mapping the data, as mmap will give us some free readahead.  We'll also split it up into two different files to avoid unaligned short access. 


```java
// ...

try (var arena = Arena.ofConfined();
     var fcCities = (FileChannel) Files.newByteChannel(tempFile1, StandardOpenOption.READ);
     var fcMeasurements = (FileChannel) Files.newByteChannel(tempFile2, StandardOpenOption.READ)
) {
    var citiesSegment = 
              fcCities.map(FileChannel.MapMode.READ_ONLY, 
                           0, fcCities.size(), arena);
    var measurementsSegment = 
              fcMeasurements.map(FileChannel.MapMode.READ_ONLY, 
                                 0, fcMeasurements.size(), arena);


    for (int i = 0; i < records; i++) {
        int cityOrd 
            = citiesSegment.getAtIndex(ValueLayout.JAVA_BYTE, i);
        int temperature 
            = measurementsSegment.getAtIndex(ValueLayout.JAVA_SHORT, i);
            
        stats[cityOrd].observe(temperature / 100.);
    }
```

| Impl                         | Runtime | Size On Disk |
| ---------------------------- | ------- | ------------ |
| DuckDB                       | 2.6s    | 3.0 GB       |
| *Disk I/O 2 GB*              | 4.0s    | 2.0 GB       |
| Parquet (Snappy) in DuckDB   | 4.5s    | 5.5 GB       |
| **Custom Encoding 2 + mmap** | 5.1s    | 2.8 GB       |
| Parquet (Zstd) in DuckDB     | 5.5s    | 3.0 GB       |
| Custom Encoding 2            | 6.7s    | 2.8 GB       |
| *Disk I/O 10 GB*             | 20.0s   | 10 GB        |
| Custom Encoding              | 56s     | 9.5GB        |
| Protobuf + NIO               | 91s     | 12.3 GB      |
| Parquet in Java              | 134s    | 2.4 GB       |
| OIS                          | 260s    | 14 GB        |
| DIS+BIS                      | 300s    | 10 GB        |
| Protobuf + BIS               | 580s    | 12.3 GB      |
| Stream all 1B rows over JDBC | 620s    | 3.0 GB       |

---

I admit I don't understand these results.  There's clearly nothing in the runtime itself that prevents these types of speeds.  The supposedly good solutions are an order of magnitude slower than they should be.  It's relatively trivial to build something that's faster, so why isn't the code fast?  

Disk I/O is a bottleneck on a good day.  We don't need to make it 10 times slower. 

---

Per popular request, a repo is up with most of these benchmarks: [https://github.com/vlofgren/Serialization1BRCBenchmark/](https://github.com/vlofgren/Serialization1BRCBenchmark/).  This blogpost sat as a nearly finished draft for almost a month during which I messed with the framework I created to run these benchmarks, so it's not the exact same code, but the results are similar enough.

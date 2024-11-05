---
title: Notes on binary soup
date: 2024-11-05
tags:
  - programming
  - search-engine
---
I recently put together a small library called [Slop](https://github.com/MarginaliaSearch/SlopData), for intermediate on-disk data representation for the search engine, replacing a few ad-hoc formats I had in place before.  

This post isn't so much an attempt to convince anyone else to use this library, as it makes trade-offs catering to a fairly niche use case, but to explore some of its design ideas, as it all came together very nicely, in the hopes that other libraries can draw ideas from it.

The entire library is written on a stringent abstraction budget, with the design goal that you should be able to as quickly as practically possible find the relevant implementation details of any given code, from the calling code.   

This is somewhat  flying in the face of common programming advice promoting decoupling and implementation hiding via interfaces and abstractions, but has turned out very well.  This is arguably both *because* and *why*  the library is very small.

## Schema as code

Ad hoc binary formats are kind of a pain to maintain, and have atrocious portability; meanwhile, many off the shelf ways of serializing data seem to revel in making the format as complex as possible.  

Many formats solve the reader-writer synchronization problem by either storing a schema in a different location from the code, sometimes in the binary itself.   This adds friction whenever you want to read or write to the format, having three places in the code base that are relevant, the reader, the writer, and the schema; and typically also adds a fair amount of overhead to serialization and deserialization, as the schema is not available at compile time.

I opted instead to put the schema information in the code itself, as code.   Let's describe some demographics data to show what I mean:

```
class DemographicsTable {
  public static StringColumn cityColumn 
            = new StringColumn("city");  
  public static IntColumn populationColumn 
            = new IntColumn("population");  
  public static DoubleColumn avgAgeColumn 
            = new DoubleColumn("avgAge");
}
```

## Descriptive filenames

Putting the schema as code doesn't solve the portability problem on its own, what does is how file names are assigned from this schema description.  

Each column maps to one or more files on disk, and each file has a deterministic name that describes its contents, function, type, compression, etc.  

```
avgAge.0.dat.fp64le.bin  
city.0.dat-len.varint.bin  
city.0.dat.s8[].bin
population.0.dat.s32le.bin
```

The storage format is designed to be trivially reverse engineered from the file-names themselves, in fact the hope is that anyone finding these files will be able to reverse-engineer an entire library for reading and producing them in short order, just from `ls` alone.

This idea above anything else associated with this data format has worked incredibly well.  The file name is incredibly under-used for describing the contents of a file, especially in programmatic contexts.

Having the data in a a structured and human-understandable directory structure like this makes it easy to use other tools to deal with the data.  It's possible to copy particular columns with command line tools, and put together something that reads only those columns.  

## Low indirection code

As we are on an abstraction budget, the schema doesn't get registered anywhere, instead each column can be *opened* for reading, or *created* for writing from the schema code itself; the schema description is referencing the very classes that are responsible for reading and writing.   

This is very much a design choice.  If, in an IDE, you jump to StringColumn, you'll end up  [at the implementation](https://github.com/MarginaliaSearch/SlopData/blob/master/src/main/java/nu/marginalia/slop/column/string/StringColumn.java).   It's wrapping [ByteArrayColumn](https://github.com/MarginaliaSearch/SlopData/blob/master/src/main/java/nu/marginalia/slop/column/array/ByteArrayColumn.java), which is equally transparent.  The only indirection in the column I/O code is via the StorageReader and StorageWriter classes,  but this is again a very [shallow hierarchy](https://github.com/MarginaliaSearch/SlopData/tree/master/src/main/java/nu/marginalia/slop/storage) that permits different storage mediums. 

Since each column type is fully self-describing and there's no central registry that instantiates the columns, it's easy to extend the library with new column types as needed.

The same isn't possible for storage types, this was a trade-off between adding even more flexibility and making the code yet more boilerplaty.  As such the [storage selection mechanism](https://github.com/MarginaliaSearch/SlopData/blob/master/src/main/java/nu/marginalia/slop/storage/Storage.java) is hard coded into the library.

### Example

An idiomatic example of a table storing demographics data with basic read and write capabilities:

```java
public record Demographics(
		String city, 
		int population, 
		double avgAge) 
{  
  static StringColumn cityColumn = 
            new StringColumn("city", 
			        StandardCharsets.ASCII, 
                    StorageType.GZIP);  
  static IntColumn populationColumn = 
            new IntColumn("population");  
  static DoubleColumn avgAgeColumn = 
            new DoubleColumn("avgAge");  
  
  public static class Writer extends SlopTable {  
    StringColumn.Writer cityWriter;  
    IntColumn.Writer popWriter;  
    DoubleColumn.Writer ageWriter;  
  
    public Writer(Path dir) throws IOException {  
       super(dir);  
  
       cityWriter = cityColumn.create(this);  
       popWriter = populationColumn.create(this);  
       ageWriter = avgAgeColumn.create(this);  
    }  
  
    public void put(Demographics demo) throws IOException {  
      cityWriter.put(demo.city());  
      popWriter.put(demo.population());  
      ageWriter.put(demo.avgAge());  
    }  
  
    public void close() throws IOException {  
      cityWriter.close();  
      popWriter.close();  
      ageWriter.close();  
    }  
  }  
  
  public static class Reader extends SlopTable {
    StringColumn.Reader cityReader;  
    IntColumn.Reader popReader;  
    DoubleColumn.Reader ageReader;  
  
    public Reader(Path dir) throws IOException {  
      super(dir);  
  
      cityReader = cityColumn.open(this);  
      popReader = populationColumn.open(this);  
      ageReader = avgAgeColumn.open(this);  
   }  
  
    public boolean hasRemaining() throws IOException {  
      return cityReader.hasRemaining();  
    }  
  
    public Demographics next() throws IOException {  
       return new Demographics(  
          cityReader.get(),  
          popReader.get(),  
          ageReader.get()
        );  
    }
    
    public void close() throws IOException {  
      cityReader.close();  
      popReader.close();  
      ageReader.close();  
    }  
  }  
}
```

 The resulting code is a bit on the boiler-platy side, but as a trade-off the Lego sensibilities in the library also permits the implementation of ad-hoc projections and predicate pushdowns.  

The `SlopTable` class seen above manages basic consistency checks for the alignment of the readers and writers, to give some *basic* data sanity guard rails, but overall the library is written with a very "C++" attitude toward foot-guns.  

The low abstraction programming style also has the benefit that it's extremely fast, as particularly for primitive column types, the entire I/O workflow can be written to perform zero allocations and zero copies, and reads can be performed directly from memory mapped files.    

This is not because Slop is a complex or *advanced* storage format, but because it's not. 

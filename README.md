# s3copy
Postgres extension to copy to/from s3

## Installation
* Make sure boto3 is installed using the default Python 3 installed on your computer.
* Clone the repository `s3copy`:
* make install inside s3copy respository
* login to your psql 
```
psql> CREATE EXTENSION plpythonu;
psql> CREATE EXTENSION s3copy;
```

## using s3copy 

Copies from postgres to s3
```postgresql
psql> select  s3copy.import_to_s3('select * from table_name where col = "xyz"', 'file_name', 's3://<bucket>/path/to/file_name');
);
```

Copies to postgres table from s3
```postgresql
psql> select  s3copy.import_from_s3('table_name', 's3://<bucket>/path/to/file_name');
);
```
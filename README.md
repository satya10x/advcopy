# advcopy
Postgres extension to copy to/from s3

## Installation
* Make sure boto3 is installed using the default Python 3 installed on your computer.
* Clone the repository `advcopy`:
* make install inside advcopy respository
* login to your psql 
```
psql> CREATE EXTENSION plpythonu;
psql> CREATE EXTENSION advcopy;
```

## using advcopy 

Copies from postgres to s3
```postgresql
psql> select  advcopy.import_to_s3('select * from table_name where col = "xyz"', 'file_name', 's3://<bucket>/path/to/file_name');
);
```

Copies to postgres table from s3
```postgresql
psql> select  advcopy.import_from_s3('table_name', 's3://<bucket>/path/to/file_name');
);
```

Copies to postgres table to ip/localhost
```postgresql
psql> select  advcopy.import_to_s3('select * from table_name where col = "xyz"', 'file_name', 'ip', 'folder');
);

psql> select  advcopy.import_to_s3('select * from table_name where col = "xyz"', 'file_name', 'localhost', 'folder');
);
```
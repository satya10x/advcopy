CREATE SCHEMA IF NOT EXISTS s3copy;

CREATE OR REPLACE FUNCTION advcopy.import_from_s3 (
   table_name text,
   endpoint_url text
) RETURNS int
LANGUAGE plpython3u
AS $$
    def cache_import(module_name):
        module_cache = SD.get('__modules__', {})
        if module_name in module_cache:
            return module_cache[module_name]
        else:
            import importlib
            _module = importlib.import_module(module_name)
            if not module_cache:
                SD['__modules__'] = module_cache
            module_cache[module_name] = _module
            return _module

    boto3 = cache_import('boto3')
    urlparse = cache_import('urllib.parse')

    plan = plpy.prepare('select current_setting($1, true)::int', ['TEXT'])

    s3_client = boto3.client('s3')

    parsed_s3_url = urlparse.urlparse(endpoint_url)
    bucket = parsed_s3_url.netloc
    file_path = parsed_s3_url.path.lstrip('/')

    response = s3_client.download_file(bucket, file_path, '/tmp/s3_data.csv')
    res = plpy.execute("COPY {table_name}  FROM {file_name} ;".format(
                table_name=table_name,
                file_name=plpy.quote_literal('/tmp/s3_data.csv')
            )
        )
    return res.nrows()
$$;

CREATE OR REPLACE FUNCTION advcopy.import_to_s3 (
   query text,
   file_name text,
   endpoint_url text
) RETURNS int
LANGUAGE plpython3u
AS $$
    def cache_import(module_name):
        module_cache = SD.get('__modules__', {})
        if module_name in module_cache:
            return module_cache[module_name]
        else:
            import importlib
            _module = importlib.import_module(module_name)
            if not module_cache:
                SD['__modules__'] = module_cache
            module_cache[module_name] = _module
            return _module

    boto3 = cache_import('boto3')
    subprocess = cache_import('urllib.parse')

    plan = plpy.prepare('select current_setting($1, true)::int', ['TEXT'])

    s3_client = boto3.client('s3')

    parsed_s3_url = urlparse.urlparse(endpoint_url)
    bucket = parsed_s3_url.netloc
    file_path = parsed_s3_url.path.lstrip('/')

    res = plpy.execute("copy {query}  to {file_name} ;".format(
                query=str(query).replace('"',"'"),
                file_name=plpy.quote_literal('/tmp/{file_name}'.format(file_name=file_name))
            )
        )
    response = s3_client.upload_file('/tmp/{file_name}'.format(file_name=file_name), bucket, file_path)
    return res.nrows()
$$;
CREATE OR REPLACE FUNCTION advcopy.export_to_ip (
   query text,
   file_name text,
   ip text,
   folder text
) RETURNS int
LANGUAGE plpython3u
AS $$
    def cache_import(module_name):
        module_cache = SD.get('__modules__', {})
        if module_name in module_cache:
            return module_cache[module_name]
        else:
            import importlib
            _module = importlib.import_module(module_name)
            if not module_cache:
                SD['__modules__'] = module_cache
            module_cache[module_name] = _module
            return _module

    subprocess = cache_import('subprocess')

    if ip in ["local", "localhost"]:
        ip = subprocess.Popen('who | cut -d"(" -f2 |cut -d")" -f1',
            shell=True, stdout=subprocess.PIPE).stdout.read().rstrip()

    res = plpy.execute("copy {query}  to {file_name} ;".format(
                query=str(query).replace('"',"'"),
                file_name=plpy.quote_literal('/tmp/{file_name}'.format(file_name=file_name))
            )
        )
    cmd = "scp /tmp/{file_name} {ip}:/{folder}".format(
        file_name=file_name,
        ip=ip,
        folder=folder)
    subprocall(cmd.split(" "))
$$;
#!/usr/bin/env python
# coding: utf-8

import argparse
import os
import pandas as pd
from sqlalchemy import create_engine
from time import time

from data_mapping import *

def main(params):
    user = params.user
    password = params.password
    host = params.host 
    port = params.port 
    db = params.db
    table_name = params.table_name
    url = params.url
    csv_name = os.path.basename(url)

    if os.path.isfile(csv_name):
        print('Found file locally no need to fetch')
    else:
        print('Fetching file with wget')
        os.system(f"wget {url}")
    
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100_000, compression='infer')

    df = next(df_iter)

    ## Ensure column names do not contain spaces or uppercase letters
    df.columns = df.columns.str.strip().str.lower()

    ## Apply additional processing based on the file name
    df = process_file(csv_name, df)

    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    df.to_sql(name=table_name, con=engine, if_exists='append')

    while True:
        try:
            t_start = time()
            df = next(df_iter)

            ## ensure column names do not contain spaces or uppercase letters
            df.columns = df.columns.str.strip().str.lower()

            df = process_file(csv_name, df)

            df.to_sql(name=table_name, con=engine, if_exists='append')

            t_end = time()

            print('inserted another chunk, took %.3f second' % (t_end - t_start))
        except StopIteration:
            print(f'finished reading {csv_name}')
            break

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest data to Postgres.')

    # User, password, host, port database name, table name, url of the csv
    parser.add_argument('--user', help='user name for postgres')
    parser.add_argument('--password', help='password for postgres')
    parser.add_argument('--host', help='host name for postgres')
    parser.add_argument('--port', help='port for postgres')
    parser.add_argument('--db', help='database name for postgres')
    parser.add_argument('--table_name', help='table name for postgres')
    parser.add_argument('--url', help='url of the csv file')

    args = parser.parse_args()

    main(args)

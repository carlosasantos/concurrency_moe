import asyncio
import concurrent.futures
import requests
import urllib.request
import json
import os
import ssl
import time

def make_request(request_id):
    print(f'request {request_id} has been made at t={time.perf_counter()-tm1:0.4f} seconds')

    data = {
        "request": request_id
    }

    body = str.encode(json.dumps(data))
    
    with open('test/cred.json', 'r') as f:
        cred = json.load(f)

    url = cred.get('scoring_uri')
    api_key = cred.get('scoring_key')

    if not api_key:
        raise Exception("A key should be provided to invoke the endpoint")

    headers = {'Content-Type':'application/json', 'Authorization':('Bearer '+ api_key), 'azureml-model-deployment': 'deployment-test-concurrency' }

    req = urllib.request.Request(url, body, headers)

    response = urllib.request.urlopen(req)

    result = response.read()
    print(result)

global tm1
tm1 = time.perf_counter()

with concurrent.futures.ThreadPoolExecutor() as executor:

    n_concurrent_requests = 3

    futures = []

    for request_id in range(1, n_concurrent_requests+1):
        print(f'request_id: {request_id}')
        futures.append(executor.submit(make_request, request_id=request_id))

    for future in concurrent.futures.as_completed(futures):
        print(future.result())

tm2 = time.perf_counter()
print(f'Total time elapsed: {tm2-tm1:0.2f} seconds')








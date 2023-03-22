import time
import json


def init():
    pass

def run(data):
    """
    Expected input:
    {
        "request": request_id
    }

    """
    time_start = time.time()

    data = json.loads(data)

    request = data.get('request')

    time.sleep(15)

    time_end = time.time()

    return f'request {request} complete. Elapsed time: {time_end - time_start:0.4f} seconds'
 
# Azure ML - Managed Online Endpoints
## Concurrency Test

The purpose of the code in this repository is to set up a Managed Online Endpoint deployment in Azure Machine Learning to test it's ability to perform multiple concurrent requests. To enable concurrent requests within one compute instance, the field "max_concurrent_requests_per_instance" is increased, as per [Azure ML documentation](https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-deployment-managed-online#requestsettings)

In this example/test, the entry script is configured to sleep for 15 seconds, providing a precise way to monitor the execution time of 1 or multiple requests to the endpoint. Please go through the 2 stages below to test the concurrency of multiple requests and learn about the code implementation.

<br>

## <u>**Stage A - Deployment**</u>

**Please use a bash terminal to execute this stage, and make sure you are logged into the correct tenant and subscription as your workspace**

<br>

1. **Run deploy.sh**

    **<u>Instructions:</u>** Run this file in a ***bash terminal***, following the following steps:
    1. Execute the file
    ```sh
    ./deploy.sh
    ```
    2. Provide the Workspace and Resource Group Names:
    ```sh
    Please provide the information below
    workspace-name: 
    resource-group: 
    ```
    **<u>Description:</u>** This bash script will sequentially execute the following steps:
    - Generate a ***random endpoint name*** - this is important, given that endpoint names need to be unique within the resource location
    - Create a new endpoint with the ***generated endpoint name***, and following the configuration defined in *endpoint.yml*, within the provided workspace and resource group
    - Create a new deployment within the newly created endpoint. This deployment is configured in *deployment.yml*, and three relevant parameters to highlight are:
        - **scoring_script**: *code/score.py* - Even though no machine learning model is deployed, this entry script "sleeps" for 15 seconds to emulate a model inference in a time controlled way.
        - **max_concurrent_requests_per_instance**: 3 - Increasing maximum concurrency to 3 allows us to assess if we can make 3 parallel requests to the endpoint. If concurrency is working, we would expect 3 requests to take around 15 seconds to execute, but if it's not working, it should take around 45 seconds.
        - **environment_variables:**  
        &emsp;**WORKER_COUNT**: 3 - This field increases the number of workers, and enables the max_concurrent_requests_per_instance to work as expected.
    - Show the deployment details, to validate that **max_concurrent_requests_per_instance** has been defined as expected.
    - Retrieve the endpoint URL (***scoring_uri***)
    - Retrieve the API Key (***scoring_key***)
    - Upload the URL and Key into a json file to be consumed later (***test/cred.json***)

<br>

## <u>**Stage B - Testing**</u>

**Please make sure you have a python interpreter in your terminal environment**

<br>

2. **Run test.sh**

    **<u>Instructions:</u>** Run this file in a ***bash terminal***, following the following steps:
    1. Execute the file
    ```sh
    ./test.sh
    ```
    2. Review the results directly within the terminal window.

    **<u>Description:</u>** This bash script will execute the ***test/test.py python*** script. 

    The purpose of this script is to make **3 concurrent requests** to the deployed API, and measure the execution time of each request, as well as the total execution time of the 3 parallel requests. ***URL and API Key*** are consumed directly from the **test/cred.json file** created during the deployment stage.

    Given that for each request, the endpoint **sleeps for 15 seconds**, and then returns the execution time (which should be slightly more than 15 seconds), we can monitor de behaviour of the deployment.

    **Expectation** - Given that we configured our deployment to accept a maximum concurrency of 3, we expect 3 concurrent requests to have an execution of time of around 15 seconds (as they should happen in parallel)


    **Example:** The following output corresponds to the seen behaviour, showing a total execution time of 45 seconds.

    ```sh
    request_id: 1
    request 1 has been made at t=0.0011 seconds
    request_id: 2
    request 2 has been made at t=0.0016 seconds
    request_id: 3
    request 3 has been made at t=0.0026 seconds
    b'"request 1 complete. Elapsed time: 15.0130 seconds"'
    None
    b'"request 2 complete. Elapsed time: 15.0110 seconds"'
    None
    b'"request 3 complete. Elapsed time: 15.0152 seconds"'
    None
    Total time elapsed: 15.14 seconds
    ```
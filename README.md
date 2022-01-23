# Repo for Docker image, designed to deploy an Image Resize App

## Deployment
* Runs a Docker Image, build on top of the latest stable Hasicorp Terraform image (1.0.11 at commit time). See [here](https://hub.docker.com/r/hashicorp/terraform/tags) 
* Terraform to deploy following resource (List is not exhaustive).
    * 1 or more Lambdas
    * API Gateway
    * CloudFront
    * Route 53

## Network Topology
![This](https://github.com/JamesCampbellIDBS/image-sizing-app/blob/master/Network_Topology.png?raw=true)

## Executing
The pipeline stage can be executed locally, with Docker:

```bash
$ docker build -t image-sizing .
$ docker run -e 'DEPLOYMENT_NAME=euw1' \
             -e 'DEPLOYMENT_VAR_FILE=dev-euw1.tfvars' \
             -e 'DEPLOYMENT_TYPE=dev' \
             image-sizing
```

## Result
Terraform will output the final image resizer URL. E.g. https://"image-resizer-dev-euw1.aircall.io"
When completed, there will be a Web URL, which can be reached, with a 

# TODO!!
* Not quite finished the setup that will provide an endpoint to get the resized image. Likely due to me needing to figure out CloudFront & API Gateway a little more!
* Testing: the deployment end to end. Not able to test in AWS, as I don't have an account
* Testing: Add a simple smoke test to the deployment script, which hits the API, with an image, and validates the response
* Authentication: Figure out how to set up authentication with the app
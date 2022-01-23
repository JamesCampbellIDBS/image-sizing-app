# Dockerfile for synthetic-check pipeline stage
FROM hub.docker.com/hashicorp/terraform:1.1.4

LABEL maintainer="SRE"

# Might need some of these for pre/post Terraform scripting
RUN apk add --no-cache --update bash git python3 python3-dev py-pip openssh jq
RUN pip3 install --no-cache-dir boto3 awscli botocore

WORKDIR /opt/

ENV DEPLOYMENT_NAME="test"

COPY scripts/ .
RUN chmod +x /opt/deploy.sh

ENTRYPOINT ["./opt/deploy.sh"]

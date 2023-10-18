FROM amazonlinux:2023

COPY hello.sh /tmp/hello.sh

RUN dnf update -y && \
    dnf install -y tar unzip jq less awscli && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# https://github.com/awslabs/amazon-s3-tar-tool#amazon-s3-tar-tool
RUN curl -LJO https://github.com/awslabs/amazon-s3-tar-tool/releases/download/v1.0.14/s3tar-linux-arm64.zip
RUN unzip -d /tmp s3tar-linux-arm64.zip && \
    rm -f s3tar-linux-arm64.zip && \
    mv /tmp/s3tar-linux-arm64 /tmp/s3tar    

RUN chmod +x /tmp/*
RUN mv /tmp/* /bin/

ENTRYPOINT [ "/bin/bash", "-c" ]

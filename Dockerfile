# Force x86_64 architecture (even on ARM hosts)
FROM --platform=linux/amd64 centos:7 AS build

# Update CentOS 7 repositories to use vault with explicit paths
RUN sed -i \
    -e 's|^mirrorlist=|#mirrorlist=|' \
    -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=http://vault.centos.org/centos|' \
    -e 's|/$releasever/|/7.9.2009/|' \
    /etc/yum.repos.d/CentOS-*.repo

WORKDIR /app
RUN yum install -y unzip curl

# Download and extract Baysor (x86_64 binary)
RUN curl -O -L https://github.com/kharchenkolab/Baysor/releases/download/v0.7.1/baysor-x86_x64-linux-v0.7.1_build.zip
RUN unzip baysor-x86_x64-linux-v0.7.1_build.zip
RUN mv bin unzip && mv unzip/baysor/* . && rm -rf unzip *.zip

# Test Baysor (adjust paths/flags as needed)
COPY test.csv .
RUN mkdir test && \
    /app/bin/baysor run \
        -x x_location \
        -y y_location \
        -z z_location \
        -g feature_name \
        -m 30 \
        -o test/ \
        -p --prior-segmentation-confidence 0.5 \
        test.csv :cell_id && \
    rm -rf test*

# Final stage
FROM --platform=linux/amd64 centos:7

# Update repositories in the final image too
RUN sed -i \
    -e 's|^mirrorlist=|#mirrorlist=|' \
    -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=http://vault.centos.org/centos|' \
    -e 's|/$releasever/|/7.9.2009/|' \
    /etc/yum.repos.d/CentOS-*.repo

WORKDIR /app
COPY --from=build /app /app
ENV PATH="${PATH}:/app/bin"

ENTRYPOINT ["/app/bin/baysor"]
CMD ["--help"]
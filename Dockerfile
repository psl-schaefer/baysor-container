FROM centos:7 AS build
WORKDIR /app
RUN yum install -y unzip 
RUN curl -O -L https://github.com/kharchenkolab/Baysor/releases/download/v0.7.1/baysor-x86_x64-linux-v0.7.1_build.zip
RUN unzip baysor-x86_x64-linux-v0.7.1_build.zip 
RUN mv bin unzip 
RUN mv unzip/baysor/* . 
RUN rm -rf unzip 
RUN rm baysor-x86_x64-linux-v0.7.1_build.zip
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
        test.csv \
        :cell_id && \
    rm -rf test*
ENTRYPOINT ["/app/bin/baysor"]
CMD ["--help"]


FROM centos:7
WORKDIR /app
COPY --from=build /app /app
ENV PATH="${PATH}:/app/bin"
ENTRYPOINT ["/app/bin/baysor"]
CMD ["--help"]
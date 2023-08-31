# Docker and Singularity images for Baysor

Baysor GitHub: https://github.com/kharchenkolab/Baysor

On creating a release, Github actions workflow create
1. a docker image and upload it to docker.io
2. a singularity/apptainer image (sif) and publish that as a release.

This image can be used with docker or singularity. For example:

      # Use the images from docker.io
      docker run maximilianheeg/baysor:v0.6.2 run --help  
      singularity run docker://maximilianheeg/baysor:v0.6.2 preview --help

      # Or a locally downloaded sif file
      singularity run baysor.sif run --help

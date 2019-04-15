FROM registry.yourdomain.com/jenkins-base-image:latest
# Base image contains basic setup, certificates, custom yum repositories etc.
# It should probably be based on 
# https://access.redhat.com/containers/?tab=overview#/registry.access.redhat.com/openshift3/jenkins-2-rhel7

LABEL description="Jenkins worker image for XYZ"
LABEL summary="Jenkins worker image for XYZ"

USER root

RUN yum update -y && yum install -y \
    python-pep8 \
    pyflakes \
    python-pytest \
    python-cachetools \
    python2-mock \
    python-requests \
    python-requests-kerberos \
    && yum clean all

# needed for some cases with RHEL 7
RUN pip install --upgrade pip setuptools

RUN pip install kafka-logging-handler

USER 10000

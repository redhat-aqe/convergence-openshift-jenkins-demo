# Loosely based on the following images:
# https://access.redhat.com/containers/?tab=overview#/registry.access.redhat.com/openshift3/jenkins-2-rhel7
# https://github.com/jenkinsci/docker-jnlp-slave/blob/master/Dockerfile
# https://github.com/jenkinsci/docker-slave/blob/master/Dockerfile
FROM registry.access.redhat.com/rhel7


# Labels from from here https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL description="Barebones jenkins worker for use with the kubernetes plugin." \
      summary="Provides the latest RHEL 7 release with minimal jenkins slave configuration." \
      maintainer="sochotni@redhat.com" \
      vendor="PnT DevOps Automation - Red Hat, Inc." \
      distribution-scope="public" \

ARG USER=jenkins
ARG UID=10000
ARG HOME_DIR=/var/lib/jenkins
ARG WORKER_VERSION=3.25

# Add custom yum repos as needed
# ADD repos.dir /etc/yum.repos.d/

RUN yum clean all && \
    yum install -y java-1.8.0-openjdk-headless nss_wrapper gettext git && \
    yum update -y && \
    yum clean all

# Install custom internal CA if needed
WORKDIR /etc/pki/ca-trust/source/anchors/
RUN curl -skO https://internal.ca.url && \
    update-ca-trust

# Setup the user for non-arbitrary UIDs with OpenShift
# https://docs.openshift.org/latest/creating_images/guidelines.html#openshift-origin-specific-guidelines
RUN useradd -d ${HOME_DIR} -u ${UID} -g 0 -m -s /bin/bash ${USER} && \
    chmod -R g+rwx ${HOME_DIR}

# Make /etc/passwd writable for root group
# so we can add dynamic user to the system in entrypoint script
RUN chmod g+rw /etc/passwd

# Retrieve jenkins worker JAR
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar \
    https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${WORKER_VERSION}/remoting-${WORKER_VERSION}.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/slave.jar

# Entry point script to run jenkins worker client
ADD scripts/jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod 755 /usr/local/bin/jenkins-slave

# For OpenShift we MUST use the UID of the user and not the name.
USER ${UID}
WORKDIR ${HOME_DIR}

# Provide a default HOME location and set some default git user details
# Set LANG to UTF-8 to support it in stdout/stderr
ENV HOME=${HOME_DIR} \
    LANG=en_US.UTF-8

ENTRYPOINT ["jenkins-slave"]

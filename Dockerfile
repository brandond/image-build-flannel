ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.14.2-amd64

FROM ${UBI_IMAGE} as ubi

FROM ${GO_IMAGE} as builder
ARG TAG="" 
RUN apt update     && \ 
    apt upgrade -y && \ 
    apt install -y ca-certificates git

RUN git clone --depth=1 https://github.com/coreos/flannel.git /go/src/github.com/coreos/flannel
RUN cd /go/src/github.com/coreos/flannel && \
    git fetch --all --tags --prune       && \
    git checkout tags/${TAG} -b ${TAG}   && \
    make dist/flanneld

FROM ubi
RUN microdnf update -y                                           && \
    microdnf install -y yum                                      && \
    yum install -y ca-certificates strongswan iptables net-tools && \
    rm -rf /var/cache/yum                                        && \
    mkdir -p /opt/bin

COPY --from=builder /go/src/github.com/coreos/flannel/dist/flanneld /opt/bin


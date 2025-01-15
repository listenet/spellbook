# syntax=docker/dockerfile:1

# Use imutable image tags rather than mutable tags (like ubuntu:22.04)
FROM registry.cn-beijing.aliyuncs.com/spellbook/ubuntu:22.04

# Some tools like yamllint need this
# Pip needs this as well at the moment to install ansible
# (and potentially other packages)
# See: https://github.com/pypa/pip/issues/10219
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /spellbook

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update -q \
    && apt-get install -yq --no-install-recommends \
    curl \
    python3 \
    python3-pip \
    sshpass \
    vim \
    rsync \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/log/*

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    --mount=type=cache,sharing=locked,id=pipcache,mode=0777,target=/root/.cache/pip \
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-compile --no-cache-dir -r requirements.txt \
    && find /usr -type d -name '*__pycache__' -prune -exec rm -rf {} \;

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN --mount=type=bind,source=inventories/sample/group_vars/k8s.yml,target=inventories/sample/group_vars/k8s.yml \
    KUBE_VERSION=$(sed -n 's/^kube_version: //p' inventories/sample/group_vars/k8s.yml) \
    OS_ARCHITECTURE=$(dpkg --print-architecture) \
    && curl -L "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${OS_ARCHITECTURE}/kubectl" -o /usr/local/bin/kubectl \
    && echo "$(curl -L "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${OS_ARCHITECTURE}/kubectl.sha256")" /usr/local/bin/kubectl | sha256sum --check \
    && chmod a+x /usr/local/bin/kubectl

COPY *.yml ./
COPY *.cfg ./
COPY roles ./roles
COPY contrib ./contrib
COPY inventories ./inventories
COPY library ./library
COPY extra_playbooks ./extra_playbooks
COPY playbooks ./playbooks
COPY plugins ./plugins

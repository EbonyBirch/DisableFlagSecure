FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_HOME=/opt/android-sdk \
    PATH=/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates git openjdk-21-jdk-headless unzip wget \
    && rm -rf /var/lib/apt/lists/*

# Android command-line tools current as of 2026-10-04.
ARG CMDLINE_TOOLS_REV=15859902
ARG CMDLINE_TOOLS_SHA256=4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583

RUN wget -q \
      "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_REV}_latest.zip" \
      -O /tmp/cmdtools.zip \
    && echo "${CMDLINE_TOOLS_SHA256}  /tmp/cmdtools.zip" | sha256sum -c - \
    && mkdir -p /tmp/cmdtools /opt/android-sdk/cmdline-tools/latest \
    && unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools \
    && mv /tmp/cmdtools/cmdline-tools/* /opt/android-sdk/cmdline-tools/latest/ \
    && rm -rf /tmp/cmdtools /tmp/cmdtools.zip

RUN yes | sdkmanager --licenses >/dev/null || true

# Current upstream main uses compileSdk 37.1 and build-tools 36.1.0.
RUN sdkmanager \
      "platforms;android-37.1" \
      "build-tools;36.1.0" \
      "platform-tools"

WORKDIR /work

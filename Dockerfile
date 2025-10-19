FROM python:3.11.13
WORKDIR /home/pandas

# https://docs.docker.com/reference/dockerfile/#automatic-platform-args-in-the-global-scope
ARG TARGETPLATFORM

RUN apt-get update && \
    apt-get --no-install-recommends -y upgrade && \
    apt-get --no-install-recommends -y install \
    build-essential \
    bash-completion \
    # hdf5 needed for pytables installation
    libhdf5-dev \
    # libgles2-mesa needed for pytest-qt
    libgles2-mesa-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy the repository into /app so agent-wrapper can chown and run tests
COPY . /app

# Install development requirements AFTER repo is present, so editable/local refs work
RUN case "$TARGETPLATFORM" in \
    linux/arm*) \
        # Drop PyQt5 for ARM GH#61037
        sed -i "/^pyqt5/Id" /app/requirements-dev.txt \
        ;; \
    esac && \
    python -m pip install --no-cache-dir -r /app/requirements-dev.txt

# Configure git safe directory to current workdir
RUN git config --global --add safe.directory /home/pandas

ENV SHELL="/bin/bash"
CMD ["/bin/bash"]

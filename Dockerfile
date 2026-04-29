FROM ros:jazzy-ros-base

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    python3-pip \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-vcstool \
    python3-argcomplete \
    sudo \
    nano \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true && rosdep update

RUN echo "source /opt/ros/jazzy/setup.bash" >> /etc/bash.bashrc

WORKDIR /workspace
CMD ["/bin/bash"]
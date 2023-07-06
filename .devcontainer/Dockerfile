FROM mcr.microsoft.com/devcontainers/base:bullseye

USER root

# Create CI User (Debian/Ubuntu)
RUN groupadd -r -g 1001 user && \
    useradd -r -u 1001 -g 1001 -m -c "user account" -d /home/user -s /bin/bash user

ENV USERNAME=user

# Add sudo support for non-root user
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME
ENV EXISTING_NON_ROOT_USER="${USERNAME}"


USER user
WORKDIR /home/user

# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user

# Create the user
# ARG USERNAME=user-name-goes-here
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID
# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
#     && apt-get update \
#     && apt-get install -y sudo \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME
# USER $USERNAME

# Change the user
# ARG USERNAME=user-name-goes-here
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID

# RUN groupmod --gid $USER_GID $USERNAME \
#     && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
#     && chown -R $USER_UID:$USER_GID /home/$USERNAME

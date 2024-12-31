# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set environment variables to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages: sudo, git, curl, and necessary utilities
RUN apt-get update && \
  apt-get install -y sudo curl && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user and add them to the sudo group
ARG USERNAME=developer
ARG UID=2000
ARG GID=2000
RUN if ! getent group $GID; then groupadd --gid $GID $USERNAME; fi && \
  if ! id -u $UID > /dev/null 2>&1; then \
  useradd --uid $UID --gid $GID --create-home --shell /bin/bash $USERNAME; \
  else \
  echo "User with UID $UID already exists. Skipping user creation."; \
  fi && \
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
  chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Print a message for verification
CMD ["bash"]

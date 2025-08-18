FROM ubuntu:noble

RUN apt update -y

RUN apt install curl -y

# The next 4 lines install Nix inside Docker. See the Determinate Systems installer's documentation
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

# Adds Nix to the path, as described by the Determinate Systems installer's documentation
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
ENV user=root

# Set up rstats-on-nix cache
# Thanks to the rstats-on-nix cache, precompiled binary packages will
# be downloaded instead of being compiled from source
RUN mkdir -p /root/.config/nix && \
    echo "substituters = https://cache.nixos.org https://rstats-on-nix.cachix.org" > /root/.config/nix/nix.conf && \
    echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= rstats-on-nix.cachix.org-1:vdiiVgocg6WeJrODIqdprZRUrhi1JzhBnXv7aWI6+F0=" >> /root/.config/nix/nix.conf

WORKDIR /rix_uv

# Copy default.nix
COPY default.nix .

COPY requirements.txt .

# We now build the environment
RUN nix-build

# Finally, we run `nix-shell`
RUN nix-shell
CMD nix-shell

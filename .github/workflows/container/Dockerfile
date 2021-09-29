# This container will be used to build ungoogled-chromium-archlinux within.
# It contains all build dependencies, as such providing full control over them regardless of
# host environment.

# There are 3 directories that can be mounted in the container to influence its behavior:

# - /mnt/input: If containing a "progress.tar.zst" archive, with the corresponding sha256 checksum in "progress.tar.zst.sum",
#               that contains a src directory with build process, said src directory will be used to continue the build.
# - /mnt/output: Contains the built package file after a successfull full build
# - /mnt/progress: Contains the current build progress in form of a "progress.tar.zst" archive with a corresponding sha256
#                  checksum, "progress.tar.zst.sum", after a successfull partial or full build

# Partial builds are limited by a timeout which can be set by passing the TIMEOUT enironment variable to the container.

FROM archlinux

# Install basic dependencies needed by the following commands
RUN pacman -Syu --needed --noconfirm base-devel

# Create a normal user to be used by makepkg
RUN useradd --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY PKGBUILD /home/build

RUN sudo -u build bash -c "cd && makepkg --nobuild --noextract --syncdeps --noconfirm"

COPY .github/workflows/container/run.sh /home/build/run.sh

# Expect archive with files required for building created by makepkg --allsource
COPY *.src.tar.gz /home/build/
RUN chown -R build /home/build
RUN tar xf /home/build/*.src.tar.gz -C /home/build --strip 1 && rm /home/build/*.src.tar.gz

RUN echo $(date +"%s") > /etc/buildtime

RUN ls -lah /home/build

USER build

ENTRYPOINT [ "/bin/bash", "/home/build/run.sh" ]
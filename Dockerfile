FROM archlinux


RUN pacman --noconfirm -Sy qrencode \
                           zbar \
                           imagemagick \
                           git \
                           ttf-roboto \
                           fontconfig \
                           diffutils

ENV FONT=Roboto-Regular \
    OUTPUT_DIR=/target/ \
    INPUT_DIR=/target/

RUN mkdir /paperify
COPY . /paperify
WORKDIR /paperify

ENTRYPOINT ["/paperify/paperify.sh"]


FROM alpine

LABEL maintainer Martin Middleton <memiddleton@gmail.com>

RUN apk --update add git less openssh \
    git-daemon git-gitweb lighttpd perl-cgi && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

RUN adduser -D git

RUN mkdir /srv/git && chown git:git /srv

USER git

COPY --chown=git:git create-repo /home/git/
COPY --chown=git:git gitconfig /home/git/.gitconfig

RUN chmod 700 /home/git/create-repo

VOLUME /git /srv/git

WORKDIR /home/git

EXPOSE 9418
EXPOSE 1234

ENTRYPOINT ["git"]
CMD ["hub"]

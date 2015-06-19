FROM alpine:edge

WORKDIR /usr/src/app
COPY . /usr/src/app

RUN apk --update add git ruby ruby-dev ruby-bundler build-base && \
    bundle install -j 4 && \
    apk del build-base && rm -fr /usr/share/ri

EXPOSE 8080
CMD ["/usr/src/app/bin/codeclimate-rubymotion"]

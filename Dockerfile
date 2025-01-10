FROM ghcr.io/webconnex/go-build:1.22 as install-go

ARG app_name
ARG build_path
ARG build_tags
ARG gh_token

ENV GO111MODULE=on

ENV D=/go/src/github.com/webconnex/go-authnet-test
ENV APPNAME=go-authnet-test
ENV BUILDPATH=$build_path
ENV BUILDTAGS=$build_tags

ADD . $D
WORKDIR $D

RUN git config --global url."https://${gh_token}@github.com/".insteadOf ssh://git@github.com:
RUN git config --global url."https://${gh_token}@github.com/".insteadOf https://github.com/

RUN go mod vendor

# Build binary
FROM install-go as build-go
ARG build_tags
ARG app_name
ARG build_path
ENV APPNAME=$app_name
ENV BUILDPATH=$build_path
ENV BUILDTAGS=$build_tags

RUN echo "Building with tags: ${BUILDTAGS}"
RUN go build -mod=vendor -o bin/$APPNAME -tags "${BUILDTAGS}" $BUILDPATH && cp bin/$APPNAME /tmp/

# Final Image
FROM alpine as production
ARG build_tags
ARG app_name
ARG build_path
ENV APPNAME=$app_name
ENV BUILDPATH=$build_path
ENV BUILDTAGS=$build_tags

# RUN apk --no-cache add tzdata ca-certificates openssl
# RUN update-ca-certificates
ENV ZONEINFO=/zoneinfo.zip
COPY --from=build-go /tmp/$APPNAME /app/
COPY --from=build-go /usr/local/go/lib/time/zoneinfo.zip /zoneinfo.zip

# Run as unprivileged user instead of root.
# Only required in the last container stage.
RUN adduser --uid 10000 -D app-user
USER 10000

CMD /app/$APPNAME

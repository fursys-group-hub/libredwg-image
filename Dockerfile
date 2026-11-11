# LibreDWG를 한 번만 컴파일해 결과물(/usr/local/bin, /usr/local/lib 등)만 담는 이미지.
# 앱에서는 다음 두 줄로 가져다 쓴다:
#   COPY --from=ghcr.io/fursys-group-hub/libredwg:0.14-trixie /usr/local/ /usr/local/
#   RUN ldconfig
#
# 앱 베이스(python:3.12-slim, Debian 13 trixie)와 같은 glibc에서 빌드한다.
FROM python:3.12-slim-trixie AS build

ARG LIBREDWG_VERSION=0.14

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential pkg-config curl ca-certificates xz-utils \
    && curl -fsSL -o /tmp/libredwg.tar.xz \
        "https://github.com/LibreDWG/libredwg/releases/download/${LIBREDWG_VERSION}/libredwg-${LIBREDWG_VERSION}.tar.xz" \
    && tar -xf /tmp/libredwg.tar.xz -C /tmp \
    && cd /tmp/libredwg-${LIBREDWG_VERSION} \
    && ./configure --disable-bindings --disable-docs --disable-static \
    && make -j"$(nproc)" \
    && make install-strip DESTDIR=/out \
    && rm -f /out/usr/local/lib/*.la \
    && test -x /out/usr/local/bin/dwg2dxf

# 컴파일 결과만 담은 최소 이미지 (실행용이 아니라 COPY --from 용)
FROM scratch
LABEL org.opencontainers.image.source="https://github.com/fursys-group-hub/libredwg-image" \
      org.opencontainers.image.description="LibreDWG 0.14 prebuilt for Debian trixie (amd64/arm64), files under /usr/local" \
      org.opencontainers.image.licenses="GPL-3.0-or-later"
COPY --from=build /out/ /

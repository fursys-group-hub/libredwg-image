# libredwg-image
ARM 아키텍처 상 LibreDWG 컴파일을 위한 이미지 repo입니다.

LibreDWG 0.14를 미리 컴파일해 `ghcr.io/fursys-group-hub/libredwg:0.14-trixie`로 올려 둡니다.
앱 빌드 때마다 LibreDWG를 컴파일하지 않고, 이 이미지에서 결과물만 복사해 씁니다.

- 지원 아키텍처: `linux/arm64`, `linux/amd64`
- 빌드 환경: `python:3.12-slim-trixie` (Debian 13)
- 들어 있는 파일: `/usr/local/bin/dwg2dxf` 등 LibreDWG 도구, `/usr/local/lib/libredwg.so*`, 헤더

## 앱에서 쓰는 법

앱 Dockerfile에서 기존 LibreDWG 컴파일 `RUN` 블록(`build-essential` 설치 ~ `make install`)을 지우고,
`FROM` 바로 아래에 두 줄을 넣습니다.

```dockerfile
FROM python:3.12-slim
COPY --from=ghcr.io/fursys-group-hub/libredwg:0.14-trixie /usr/local/ /usr/local/
RUN ldconfig

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

파일 위치(`/usr/local/bin/dwg2dxf`)가 기존과 같아서 파이썬 코드는 수정할 필요가 없습니다.
앱 베이스 이미지는 Debian 13(trixie) 이상이어야 합니다.

## 확인

```bash
docker exec <컨테이너> dwg2dxf --version
docker exec <컨테이너> sh -c 'ldd /usr/local/bin/dwg2dxf | grep "not found"'   # 출력이 없어야 정상
```

## 버전 올리기

`Dockerfile`의 `LIBREDWG_VERSION`과 `.github/workflows/build.yml`의 태그를 함께 바꿔 main에 push하면
GitHub Actions가 다시 빌드합니다. arm64는 에뮬레이션으로 빌드해서 30분 이상 걸릴 수 있습니다.
수동 실행: Actions → build-libredwg → Run workflow.

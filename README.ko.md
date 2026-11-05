<p align="center"><img src="AppIcon/nokori-icon.svg" width="144" height="144" alt="Nokori 흰색 유리와 팝 스타일 태양, 고정된 빨간 호 로고" /></p>

# Nokori

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

중앙의 태양 반려동물과 원형·액체 유리 패널을 제공하는 macOS AI 사용량 모니터입니다.

> **다운로드 검증이 중단되었습니다.** 테스트 Mac에서 XProtect 규칙을 읽지 못해 텍스트만 들어 있는 대조 ZIP도 차단됩니다. 새 패키지 두 종류 모두 배포 전 검증을 완료하지 못했습니다. [진행 상황](Downloads/README.md).

아래 시험판에는 흰색 유리 팝 스타일 아이콘이 포함되어 있습니다. **빨간 호는 고정된 브랜드 디자인이며 실시간 사용량이 아닙니다**. [아이콘 및 생성 방법](Docs/branding.md).

> [qunqin24의 Pulse](https://github.com/qunqin24/Pulse)를 기반으로 한 독립 버전이며 원저작자의 보증을 뜻하지 않습니다. 독립 버전의 이름은 **Nokori(이전 이름 Pulse Pet)**로 정했습니다.

## 달라진 점

새로 설정할 때는 **Liquid pet**이 기본입니다. 이미 저장한 패널 스타일은 유지됩니다. `67923c1` 시험판에는 이 기본값과 모든 계정의 분산 배치, 날씨 클릭 새로 고침, 드래그를 놓을 때 모든 계정이 의도치 않게 새로 고쳐지는 문제의 수정이 포함됩니다.

**알려진 제한:** 계정 77개를 활성화하면 기존 사이드바가 화면을 벗어나 보이지 않을 수 있습니다. 계정이 많을 때는 Liquid pet 또는 원형 Pet orb를 사용하세요. [검증 범위 및 제한](Downloads/README.md).

Liquid pet은 활성화된 모든 계정의 아이콘과 사용량 링을 물방울 안에 펼쳐 표시하며 페이지를 나누지 않습니다. 계정이 많으면 아이콘이 작아지고, 포인터를 올리면 이름과 사용량 상세 카드를 볼 수 있습니다. 펫은 중앙에 유지됩니다. 원형 Pet orb는 기존 페이지 전환을 유지합니다.

- **Pet orb:** 기존 원형을 유지하며 접히거나 펼쳐져도 반려동물은 중앙에 있습니다.
- **Liquid pet:** 살짝 퍼진 불규칙한 모양입니다. 드래그하면 뒤로 늘어나고 놓으면 가라앉습니다. 표면장력과 점성의 시각적 근사이며 유체 시뮬레이션이 아닙니다. 동작 줄이기 설정에서는 늘어남과 반동이 비활성화됩니다.
- **Classic rail:** 기존 화면 가장자리 패널도 선택할 수 있습니다.
- 포인터를 가까이 대면 계정 링이 펼쳐지고, 링 위에 놓으면 기존 상세 카드가 나타납니다. 패널과 카드를 벗어나면 접힙니다.
- 움직이는 Little sun이 기본입니다. 고양이·여우·토끼, 투명 PNG와 크기 조절도 지원합니다.
- 선택 기능인 [날씨 펫](Docs/weather-pet.md)으로 구름, 비, 천둥, 눈, 안개와 달을 표시할 수 있습니다. 고정 그림은 오프라인에서도 사용합니다. 현지 날씨를 활성화하면 위치 권한을 직접 허용하거나 도시를 선택할 수 있으며, 위치를 거부해도 도시 검색을 이용할 수 있습니다. Open-Meteo 무료 서비스는 비상업적 용도로만 사용할 수 있습니다.
- 제공업체 사용량, 계정, 기록, 메뉴 막대, 알림과 연동을 유지합니다. [전체 기능](Docs/features.md) · [지원 서비스](Docs/supported-services.md).
- 경고 기준 75%, 80%, 90%, 95%를 유지하고 **1~100%**를 직접 입력할 수도 있습니다.

## 설치 및 설정

**[시험판 DMG 다운로드 — Apple Silicon＋Intel](Downloads/README.md)** · [SHA-256 및 검증 범위](Downloads/README.md). 파일은 이 저장소에서 직접 배포하며 정식 안정판이나 태그가 있는 GitHub Release가 아닙니다. 최초 위치 권한 요청과 실제 위치 확인은 아직 검증하지 못했습니다. 원본 Pulse 배포 파일에는 이 버전의 기능이 없습니다.

1. DMG를 열고 **Nokori.app**을 응용 프로그램으로 옮기세요. 기존 **Pulse.app**은 교체하지 마세요.
2. 설정, 앱 데이터, 로그인 항목, URL 스킴은 분리되며 원본 설정을 이전하지 않습니다. 원본 자동 업데이트는 비활성화되어 있습니다.
3. 실행 후 모니터링할 서비스를 선택하세요. 메뉴 막대에 상주하며 패널을 오른쪽 클릭해도 설정을 열 수 있습니다.
4. 시험판은 임시 서명만 있으며 **Apple 공증을 받지 않았습니다**. Apple에서 확인할 수 없다는 경고가 나오면 휴지통으로 이동하지 말고 **Done(완료)**을 선택하세요. 출처를 신뢰할 때만 시스템 설정 → 개인정보 보호 및 보안 → 확인 없이 열기를 사용하세요. 악성 소프트웨어가 탐지되었거나 컴퓨터를 손상한다는 경고라면 중단하세요. [최초 실행 안내](Downloads/README.md).

macOS 14 이상, 완전한 Liquid Glass 표시에는 macOS 26 이상이 필요합니다. Universal 패키지는 Apple Silicon과 Intel을 대상으로 하지만 이 버전의 패널은 Intel 실제 기기와 구형 macOS에서 검증하지 않았습니다.

두 앱이 같은 서비스 계정, CLI 로그인 또는 키체인을 사용할 수 있습니다. 앱 데이터가 분리되어도 서비스 할당량은 별개로 늘어나지 않습니다. Claude Code의 공유 status line 연동은 한 앱에서만 활성화하세요.

- **설정 → 모양 → 패널 스타일:** Pet orb / Liquid pet / Classic rail.
- **설정 → 일반 → 인터페이스 언어:** 영어, 번체·간체 중국어, 일본어, 한국어, 러시아어 또는 시스템 설정. 위쪽 링크는 README 언어만 바꿉니다.
- **설정 → 알림:** 사전 설정이나 직접 입력한 백분율을 적용하고 macOS 알림을 허용하세요. 알림은 실제로 읽은 값에 따르며 연속 실시간 감시가 아닙니다.

> **Pulse Pet에서 업그레이드:** 기존 앱을 종료하고 Nokori를 설치한 뒤 이전 Pulse Pet 앱 본체만 제거하세요. 데이터와 설정 식별자는 유지되므로 데이터를 삭제하지 마세요. 같은 앱의 이전 이름과 새 이름을 동시에 실행하지 마세요. 원본 Pulse와 Nokori는 함께 실행할 수 있습니다. [브랜드 및 호환성](Docs/branding.md).

## 날씨 데이터 출처와 비용

자동 날씨는 **Open-Meteo**를 사용하며 **Apple 날씨 앱을 읽거나 WeatherKit을 사용하지 않습니다**. 기본적으로 꺼져 있습니다. 기능을 켜고 플로팅 패널을 표시하면 약 30분마다 갱신합니다. 실시간 동기화는 아닙니다. 무료 API에는 키가 필요 없지만 **비상업적 용도로만 사용**할 수 있고 요청량 제한이 있으며 서비스 가용성은 보장되지 않습니다. 위치 권한은 현재 위치를 확인하는 권한일 뿐 날씨 앱의 데이터 접근 권한은 아닙니다. 현재 WeatherKit 개발자 계정의 공유 할당량은 사용하지 않습니다. [출처·비용·개인정보 상세 안내(영어)](Docs/weather-pet.md#data-source-and-cost).

## 소스에서 빌드

전체 Xcode, macOS 26 이상 SDK, Swift tools 6.0 이상, Python 3가 필요합니다. 미리 보기를 삭제하거나 Command Line Tools만 사용하지 마세요.

```bash
git clone https://github.com/wenyen-hsu/Pulse.git Nokori
cd Nokori
swift build
TZ=UTC swift test
./Scripts/check-localization.sh
./Scripts/bundle.sh --zip
./Scripts/dmg.sh
```

결과물은 `build.noindex/Nokori.app`, `Nokori-<version>.zip`, `Nokori-<version>.dmg`입니다. 로컬 패키징은 공개 릴리스를 만들지 않습니다. [도구 안내](Docs/build-from-source.md) · [패키징](Docs/releasing.md).

## 개인정보·기여·라이선스

Pulse 백엔드나 계정은 없습니다. 활성화한 서비스에만 사용량을 요청하며 자격 증명과 로컬 기록은 Mac에 보관합니다. [서비스 접근 방식](Docs/providers/README.md)을 확인하세요. 토큰, 쿠키, 키체인 또는 가리지 않은 로그를 공개하지 마세요.

이 버전의 문제는 [이 저장소의 Issues](https://github.com/wenyen-hsu/Pulse/issues)에 macOS, 아키텍처, 패널 스타일, 재현 방법을 적어 제출하세요. 원저작자에게 독립 버전의 지원을 요구하지 마세요. [기여](CONTRIBUTING.md) · [보안 제보](SECURITY.md) · [문서 목록](Docs/README.md).

**qunqin24와 Pulse 기여자에게 감사드립니다.** [Apache 2.0](LICENSE), [NOTICE](NOTICE), [타사 고지](THIRD_PARTY_NOTICES.md)를 유지하며 설치 화면과 정보 화면에도 감사를 표시합니다. 수정과 재배포는 필요한 고지·라이선스·변경 표시 및 타사 조건을 지켜야 합니다. 상표권이나 원저작자의 보증은 부여되지 않습니다. 이름과 로고 선택이 상표 확인 완료를 뜻하지는 않습니다.

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

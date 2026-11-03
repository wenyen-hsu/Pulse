# Pulse Pet

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

중앙의 태양 반려동물과 원형·액체 유리 패널을 제공하는 macOS AI 사용량 모니터입니다.

> [qunqin24의 Pulse](https://github.com/qunqin24/Pulse)를 기반으로 한 독립 버전이며 원저작자의 보증을 뜻하지 않습니다. 현재 앱 이름은 **Pulse Pet**입니다. 새 이름과 로고는 검토 중입니다.

## 달라진 점

- **Pet orb:** 기존 원형을 유지하며 접히거나 펼쳐져도 반려동물은 중앙에 있습니다.
- **Liquid pet:** 살짝 퍼진 불규칙한 모양입니다. 드래그하면 뒤로 늘어나고 놓으면 가라앉습니다. 표면장력과 점성의 시각적 근사이며 유체 시뮬레이션이 아닙니다. 동작 줄이기 설정에서는 늘어남과 반동이 비활성화됩니다.
- **Classic rail:** 기존 화면 가장자리 패널도 선택할 수 있습니다.
- 포인터를 가까이 대면 계정 링이 펼쳐지고, 링 위에 놓으면 기존 상세 카드가 나타납니다. 패널과 카드를 벗어나면 접힙니다.
- 움직이는 Little sun이 기본입니다. 고양이·여우·토끼, 투명 PNG와 크기 조절도 지원합니다.
- 제공업체 사용량, 계정, 기록, 메뉴 막대, 알림과 연동을 유지합니다. [전체 기능](Docs/features.md) · [지원 서비스](Docs/supported-services.md).
- 경고 기준 75%, 80%, 90%, 95%를 유지하고 **1~100%**를 직접 입력할 수도 있습니다.

## 설치 및 설정

관리자가 제공하거나 [이 저장소의 Releases](https://github.com/wenyen-hsu/Pulse/releases)에 있는 **Pulse Pet** 시험판을 사용하세요. 배포 파일이 없으면 소스에서 빌드하세요. 원본 Pulse 배포 파일에는 이 버전의 기능이 없습니다.

1. DMG를 열고 **Pulse Pet.app**을 응용 프로그램으로 옮기세요. 기존 **Pulse.app**은 교체하지 마세요.
2. 설정, 앱 데이터, 로그인 항목, URL 스킴은 분리되며 원본 설정을 이전하지 않습니다. 원본 자동 업데이트는 비활성화되어 있습니다.
3. 실행 후 모니터링할 서비스를 선택하세요. 메뉴 막대에 상주하며 패널을 오른쪽 클릭해도 설정을 열 수 있습니다.
4. 시험판은 임시 서명만 있으며 **Apple 공증을 받지 않았습니다**. 신뢰하는 파일에만 시스템 설정 → 개인정보 보호 및 보안 → 확인 없이 열기를 사용하세요.

macOS 14 이상, 완전한 Liquid Glass 표시에는 macOS 26 이상이 필요합니다. Universal 패키지는 Apple Silicon과 Intel을 대상으로 하지만 이 버전의 패널은 Intel 실제 기기와 구형 macOS에서 검증하지 않았습니다.

두 앱이 같은 서비스 계정, CLI 로그인 또는 키체인을 사용할 수 있습니다. 앱 데이터가 분리되어도 서비스 할당량은 별개로 늘어나지 않습니다. Claude Code의 공유 status line 연동은 한 앱에서만 활성화하세요.

- **설정 → 모양 → 패널 스타일:** Pet orb / Liquid pet / Classic rail.
- **설정 → 일반 → 인터페이스 언어:** 영어, 번체·간체 중국어, 일본어, 한국어, 러시아어 또는 시스템 설정. 위쪽 링크는 README 언어만 바꿉니다.
- **설정 → 알림:** 사전 설정이나 직접 입력한 백분율을 적용하고 macOS 알림을 허용하세요. 알림은 실제로 읽은 값에 따르며 연속 실시간 감시가 아닙니다.

## 소스에서 빌드

전체 Xcode, macOS 26 이상 SDK, Swift tools 6.0 이상, Python 3가 필요합니다. 미리 보기를 삭제하거나 Command Line Tools만 사용하지 마세요.

```bash
git clone https://github.com/wenyen-hsu/Pulse.git PulsePet
cd PulsePet
swift build
TZ=UTC swift test
./Scripts/check-localization.sh
./Scripts/bundle.sh --zip
./Scripts/dmg.sh
```

결과물은 `build.noindex/Pulse Pet.app`, `PulsePet-<version>.zip`, `PulsePet-<version>.dmg`입니다. 로컬 패키징은 공개 릴리스를 만들지 않습니다. [도구 안내](Docs/build-from-source.md) · [패키징](Docs/releasing.md).

## 개인정보·기여·라이선스

Pulse 백엔드나 계정은 없습니다. 활성화한 서비스에만 사용량을 요청하며 자격 증명과 로컬 기록은 Mac에 보관합니다. [서비스 접근 방식](Docs/providers/README.md)을 확인하세요. 토큰, 쿠키, 키체인 또는 가리지 않은 로그를 공개하지 마세요.

이 버전의 문제는 [이 저장소의 Issues](https://github.com/wenyen-hsu/Pulse/issues)에 macOS, 아키텍처, 패널 스타일, 재현 방법을 적어 제출하세요. 원저작자에게 독립 버전의 지원을 요구하지 마세요. [기여](CONTRIBUTING.md) · [보안 제보](SECURITY.md) · [문서 목록](Docs/README.md).

**qunqin24와 Pulse 기여자에게 감사드립니다.** [Apache 2.0](LICENSE), [NOTICE](NOTICE), [타사 고지](THIRD_PARTY_NOTICES.md)를 유지하며 설치 화면과 정보 화면에도 감사를 표시합니다. 수정과 재배포는 필요한 고지·라이선스·변경 표시 및 타사 조건을 지켜야 합니다. 상표권이나 원저작자의 보증은 부여되지 않습니다. 새 이름과 로고는 별도 확인이 필요합니다.

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

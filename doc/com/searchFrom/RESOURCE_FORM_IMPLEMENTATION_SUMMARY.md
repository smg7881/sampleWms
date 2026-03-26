# ResourceForm Implementation Summary

## 개요

`resource_form_prd.md`를 기준으로 `resource_form`의 1차 구현을 실제 코드로 반영했다. 이번 작업의 목적은 PRD를 설명 문서로만 남기는 것이 아니라, 현재 `simpleWms` 저장소에서 바로 확인 가능한 샘플 화면과 공용 form layer를 만드는 것이다.

구현 기준 기술은 아래와 같다.

- ViewComponent
- Stimulus
- DaisyUI v5 스타일 규칙
- Propshaft 기반 CSS 로딩
- Importmap 기반 JavaScript 로딩

샘플 경로는 `/samples/resource-form` 이다.

---

## 구현 범위

이번 작업에서 구현한 범위는 아래와 같다.

1. `resource_form`용 helper, component, sample controller 추가
2. `Ui::ResourceFormComponent` 어댑터 추가
3. 공용 `Ui::FormFields::RendererComponent`를 `mode: :model`까지 확장
4. `search_form`과 `resource_form`이 shared field partial을 공용 사용하도록 정리
5. `number`, `textarea`, `checkbox`, `radio`, `popup` partial 추가
6. `resource_form_controller.js` 추가
7. popup 검색용 `search_popup_controller.js` 추가
8. 거래처기본정보 탭 기반 샘플 화면 추가
9. DaisyUI CDN 의존을 제거하고 local vendor stylesheet로 전환
10. `resource_form` 샘플 렌더링/submit 테스트 추가

---

## 생성 및 수정 파일

### 라우트

- `config/routes.rb`
  - `get "samples/resource-form" => "resource_form_samples#show"` 추가
  - `patch "samples/resource-form" => "resource_form_samples#update"` 추가

### 모델

- `app/models/sample_client_profile.rb`
  - 샘플용 ActiveModel form object

### helper

- `app/helpers/resource_form_helper.rb`

### ViewComponent

- `app/components/resource_form/component.rb`
- `app/components/resource_form/component.html.erb`
- `app/components/resource_form/header_component.rb`
- `app/components/resource_form/header_component.html.erb`
- `app/components/resource_form/actions_component.rb`
- `app/components/resource_form/actions_component.html.erb`
- `app/components/ui/resource_form_component.rb`
- `app/components/ui/resource_form_component.html.erb`
- `app/components/resource_form_samples/page_component.rb`
- `app/components/resource_form_samples/page_component.html.erb`

### controller / view

- `app/controllers/resource_form_samples_controller.rb`
- `app/views/resource_form_samples/show.html.erb`

### 공용 field renderer / partial

- `app/components/ui/form_fields/renderer_component.rb`
- `app/views/shared/form_fields/_input.html.erb`
- `app/views/shared/form_fields/_select.html.erb`
- `app/views/shared/form_fields/_date_picker.html.erb`
- `app/views/shared/form_fields/_switch.html.erb`
- `app/views/shared/form_fields/_number.html.erb`
- `app/views/shared/form_fields/_textarea.html.erb`
- `app/views/shared/form_fields/_checkbox.html.erb`
- `app/views/shared/form_fields/_radio.html.erb`
- `app/views/shared/form_fields/_popup.html.erb`

### Stimulus

- `app/javascript/controllers/resource_form_controller.js`
- `app/javascript/controllers/search_popup_controller.js`
- `app/javascript/controllers/index.js`

### 스타일 / 레이아웃

- `app/assets/stylesheets/application.css`
  - resource form sample, form shell, popup modal 스타일 추가
- `app/assets/stylesheets/vendor/daisyui.css`
  - 현재 앱에서 사용하는 DaisyUI class 호환 레이어 추가
- `app/views/layouts/application.html.erb`
  - DaisyUI CDN 제거
  - `stylesheet_link_tag "vendor/daisyui", "application"` 로 변경

### 테스트

- `test/controllers/resource_form_samples_controller_test.rb`

---

## 화면 구성

샘플 화면은 참조 이미지의 거래처관리 화면에서 `거래처기본정보` 탭을 기준으로 구성했다.

### 1. 상단 목록 패널

- 거래처 목록 테이블
- 첫 행 선택 상태 강조
- 다크 업무형 테이블 밀도 반영

### 2. 하단 detail 패널

- 선택 거래처 표시
- 탭 버튼 표시
  - `거래처기본정보`
  - `거래처추가정보`
  - `거래처담당자`
  - `거래처작업장`
- 실제 구현은 `거래처기본정보` 탭 중심

### 3. ResourceForm 영역

- `ResourceForm::Component`가 shell 역할 수행
- `Ui::ResourceFormComponent`는 기존 호출 패턴 호환용 어댑터 역할
- 거래처기본정보 탭 입력 항목을 form field로 분리

포함 field:

- `input`
  - 거래처코드
  - 거래처명
  - 사업자번호
  - 대표거래처
  - 대표영업사원명
  - 주소
  - 상세주소
- `select`
  - 거래처구분그룹
  - 거래처구분
  - 거래처종류
  - 국가
  - 사용여부
- `date_picker`
  - 적용시작일
  - 적용종료일
- `popup`
  - 관리법인
  - 상위거래처
  - 우편번호

---

## 공용 renderer 확장 내용

### `Ui::FormFields::RendererComponent`

기존 renderer는 `search_form`의 `mode: :search`만 처리하고 있었다. 이번 작업에서 아래를 추가했다.

- `mode: :model` 지원
- model param key 기반 `name` / `id` 생성
- model value 복원
- inline error message 지원
- `popup`용 code/display field 분리
- dependency data 생성
- shared partial을 `search_form` / `resource_form` 양쪽에서 공용 사용

즉, 구조는 그대로 유지하면서 바인딩 방식만 form mode에 따라 달라지도록 확장한 것이다.

---

## Stimulus 동작

### `resource_form_controller.js`

담당 동작:

- submit 시 `checkValidity()` 검증
- invalid field 하이라이트
- reset 처리
- dependency select 초기화/재계산
- submit loading 상태 반영

### `search_popup_controller.js`

담당 동작:

- popup modal open / close
- 검색어 입력에 따른 filter
- 샘플 목록 렌더링
- 선택 시 code/display input 값 주입

---

## popup field 구현 방식

이번 구현에서 `popup` field는 실제 업무용 search modal의 축소판으로 구현했다.

- field 내부에 readonly display input + code input + search button 배치
- search button 클릭 시 `<dialog>` 기반 modal 오픈
- 샘플 option 목록에서 항목 선택 가능
- 선택한 값이 display/code field에 동시에 반영

현재 popup은 샘플 데이터 기반이며, 실제 서버 검색이나 Turbo modal 연동까지는 아직 하지 않았다.

---

## DaisyUI / Propshaft 정리

PRD 요구사항에 맞춰 DaisyUI CDN 링크를 제거했다.

현재 적용 방식:

- `app/assets/stylesheets/vendor/daisyui.css` 추가
- 레이아웃에서 local asset 로드

```erb
<%= stylesheet_link_tag "vendor/daisyui", "application", "data-turbo-track": "reload" %>
```

주의:

- 이 파일은 DaisyUI 전체 원본 번들이 아니라 현재 앱에서 사용하는 class만 옮긴 compatibility layer 이다.
- 오프라인/제한된 환경에서 PRD 방향에 맞추기 위해 먼저 로컬 asset 구조를 확보한 상태다.

---

## 테스트 결과

아래 테스트를 실행해 통과를 확인했다.

```bash
bin/rails test test/controllers/search_form_samples_controller_test.rb test/controllers/resource_form_samples_controller_test.rb
```

검증 내용:

- 기존 `search_form` 샘플 회귀 없음
- `resource_form` 샘플 화면 정상 렌더링
- 거래처기본정보 탭의 입력 field 렌더링 확인
- PATCH submit 후 값 복원 확인

---

## 현재 한계와 남은 작업

이번 구현은 PRD의 핵심 골격을 실제 화면으로 옮긴 1차 버전이다. 아직 남아 있는 항목은 아래와 같다.

1. popup field를 실제 검색 API / Turbo modal과 연결
2. `form_data`, `target_controller`, 외부 modal save button 연계까지 더 깊게 검증
3. `photo`, `multi_file`, `rich_textarea` 같은 확장 field 지원
4. component / helper / renderer 단위 테스트 추가
5. DaisyUI vendor asset을 공식 전체 CSS로 교체할지 판단

---

## 결론

이번 작업으로 `resource_form_prd.md`의 방향이 실제 코드로 이어졌다.

- ViewComponent 기반 화면 분리
- `search_form`과 `resource_form`의 shared field layer 공용화
- 거래처기본정보 탭 기준 입력 화면 구현
- popup 검색 UI 도입
- DaisyUI local asset + Propshaft 구조 전환

현재 `/samples/resource-form` 화면은 이후 실제 CRUD 화면으로 확장할 수 있는 기준 구현으로 사용할 수 있다.

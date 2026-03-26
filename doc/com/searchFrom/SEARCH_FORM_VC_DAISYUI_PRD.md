# SearchForm PRD — ViewComponent + Stimulus + DaisyUI v5 + Propshaft + Importmap

## 1. 목적

`SEARCH_FORM`을 Rails 8.1 환경에서 `ViewComponent + Stimulus + DaisyUI v5 + Propshaft + Importmap` 조합으로 재설계한다. 기존 문서의 핵심 요구사항인 선언형 필드 정의, Turbo/Stimulus 기반 상호작용, 검색 조건 복원은 유지하되, 렌더링 구조는 partial 중심에서 **ViewComponent 중심**으로 전환한다.

이번 PRD의 핵심은 `search_form`만 만드는 것이 아니다. `resource_form`과 **동일한 field schema와 field renderer를 공용화**하여, 검색 폼과 CRUD 폼이 같은 필드 자산을 공유하도록 만드는 것이 1차 목표다.

## 2. 기존 문서 분석 요약

- `SEARCH_FORM_PRD.md`와 `SEARCH_FORM_IMPLEMENTATION.md`는 `helper + partial + stimulus` 구조를 전제로 작성되었다.
- `resource_form_prd.md`는 `input`, `number`, `select`, `date_picker`, `textarea`, `checkbox`, `radio`, `switch`를 선언형으로 생성하는 CRUD 폼을 정의한다.
- 두 문서 모두 필드 정의 배열 기반, i18n 우선순위, 반응형 span, Stimulus 최소 개입이라는 공통 원칙을 가진다.
- 차이는 바인딩 방식이다.
  - `search_form`: `params[:q]` 기반 GET 검색
  - `resource_form`: `form_with model:` 기반 POST/PATCH 저장

결론적으로 화면 컨테이너는 분리하되, 필드 정의와 필드 렌더러는 분리하면 안 된다.

## 3. 기술 원칙

1. 화면 분리는 ViewComponent로 처리한다.
2. 필드 렌더링은 `search_form`과 `resource_form`이 공통으로 사용한다.
3. DaisyUI v5 클래스만 사용하고, 별도 JS UI 프레임워크는 도입하지 않는다.
4. JS는 Importmap + Stimulus만 사용한다.
5. CSS는 Propshaft 자산으로 관리한다. Node/Tailwind 빌드 파이프라인은 추가하지 않는다.

## 4. 아키텍처 방향

### 4.1 최상위 컴포넌트

```text
SearchForm::Component
ResourceForm::Component
Ui::FormFields::RendererComponent
Ui::FormFields::ActionsComponent
Ui::FormFields::LayoutComponent
```

- `SearchForm::Component`
  - 검색 URL, `params[:q]`, collapse 상태, GET 제출, reset 동작 담당
- `ResourceForm::Component`
  - `form_with model:`, submit/cancel, 서버 에러 출력 담당
- `Ui::FormFields::*`
  - 두 폼이 공용으로 쓰는 필드 정의 해석기와 렌더러

### 4.2 helper의 역할 축소

기존 `search_form_tag`, `resource_form_tag` API는 유지하되, 내부 구현은 `render Component.new(...)`만 호출하는 얇은 래퍼로 바꾼다.

```ruby
def search_form_tag(**options)
  render SearchForm::Component.new(**options)
end

def resource_form_tag(**options)
  render ResourceForm::Component.new(**options)
end
```

## 5. 공용 Field Schema

두 폼은 아래 schema를 공유한다.

```ruby
{
  field: "status",
  type: "select",
  label: "상태",
  label_key: "forms.status",
  placeholder: "선택하세요",
  placeholder_key: "forms.placeholders.status",
  required: false,
  disabled: false,
  span: "24 s:12 m:8",
  help: "검색 조건을 선택하세요",
  options: [{ label: "전체", value: "" }, { label: "활성", value: "active" }],
  include_blank: false,
  autocomplete: "off",
  inputmode: "text",
  min: nil,
  max: nil
}
```

### 5.1 공용 타입

- 공용: `input`, `number`, `select`, `date_picker`, `textarea`, `checkbox`, `radio`, `switch`
- 검색 전용 확장: `date_range`, `popup`

`search_form`은 공용 타입 일부만 사용하고, `resource_form`은 공용 타입 대부분을 사용한다. 즉, 필드 시스템은 하나이고 각 폼이 subset을 선택하는 구조다.

## 6. 공용 렌더링 전략

### 6.1 ViewComponent + shared partial 혼합 구조

화면 분리는 ViewComponent로 하고, 필드 마크업은 공용 partial로 관리한다. 이 구조가 사용자 요구사항과 재사용성 모두를 만족한다.

```text
app/components/search_form/component.rb
app/components/search_form/component.html.erb
app/components/resource_form/component.rb
app/components/resource_form/component.html.erb
app/components/ui/form_fields/renderer_component.rb
app/components/ui/form_fields/renderer_component.html.erb
app/views/shared/form_fields/_input.html.erb
app/views/shared/form_fields/_number.html.erb
app/views/shared/form_fields/_select.html.erb
app/views/shared/form_fields/_date_picker.html.erb
app/views/shared/form_fields/_date_range.html.erb
app/views/shared/form_fields/_textarea.html.erb
app/views/shared/form_fields/_checkbox.html.erb
app/views/shared/form_fields/_radio.html.erb
app/views/shared/form_fields/_switch.html.erb
app/views/shared/form_fields/_popup.html.erb
```

`Ui::FormFields::RendererComponent`는 `context`를 받아 같은 partial을 다른 방식으로 바인딩한다.

- `context.mode == :search`
  - `name="q[field]"`
  - 값은 `params[:q]`
- `context.mode == :model`
  - `form.text_field`, `form.select` 등 `form builder` 사용
  - 값과 에러는 model에서 가져옴

## 7. DaisyUI v5 적용 기준

### 7.1 필드별 DaisyUI 클래스

- `_input.html.erb`
  - `fieldset`, `label`, `input input-bordered w-full`
- `_number.html.erb`
  - `fieldset`, `label`, `input input-bordered w-full`
- `_select.html.erb`
  - `fieldset`, `label`, `select select-bordered w-full`
- `_date_picker.html.erb`
  - `fieldset`, `label`, `input input-bordered w-full`
- `_date_range.html.erb`
  - `fieldset`, `label`, `input input-bordered`, `join`
- `_textarea.html.erb`
  - `fieldset`, `label`, `textarea textarea-bordered w-full`
- `_checkbox.html.erb`
  - `label cursor-pointer`, `checkbox`
- `_radio.html.erb`
  - `label cursor-pointer`, `radio`
- `_switch.html.erb`
  - `label cursor-pointer`, `toggle`
- `_popup.html.erb`
  - `input input-bordered`, `btn btn-outline`

### 7.2 date picker 처리

DaisyUI v5에는 전용 date picker JS 컴포넌트가 없으므로, `date_picker`는 네이티브 `<input type="date">` 또는 `<input type="datetime-local">`에 DaisyUI `input` 클래스를 적용한다. 필요 시 이후 phase에서 Stimulus 기반 래퍼를 추가한다.

### 7.3 액션 버튼

- 검색: `btn btn-primary`
- 초기화: `btn btn-outline`
- 저장: `btn btn-primary`
- 취소: `btn btn-ghost`
- 펼치기/접기: `btn btn-ghost btn-sm`

## 8. Stimulus 역할

### 8.1 `search_form_controller.js`

- 검색 제출 전 `checkValidity()` 수행
- reset 시 `form.reset()` + `Turbo.visit(baseUrl)`
- collapse/expand 토글
- `getComputedStyle(gridColumnEnd)` 기반 visible field 계산
- querystring 기반 상태 복원 보조

### 8.2 `form_dependencies_controller.js`

- `resource_form`와 `search_form` 공용
- 부모 select 값에 따라 자식 select 옵션 필터링
- `data-all-options` JSON 사용

### 8.3 `popup_field_controller.js`

- 검색 전용
- 팝업 열기/선택/hidden code input 동기화

## 9. Propshaft + Importmap 방침

### 9.1 CSS

현재 레이아웃은 DaisyUI CDN을 직접 로드하고 있다. 이번 구현에서는 DaisyUI v5 CSS를 Propshaft 자산으로 고정한다.

```text
app/assets/stylesheets/vendor/daisyui.css
app/assets/stylesheets/forms.css
```

레이아웃에서는 CDN `<link>` 대신 `stylesheet_link_tag "vendor/daisyui", "app"` 또는 Propshaft에서 제공하는 asset path를 사용한다. 목표는 배포 환경에서 외부 CDN 의존 없이 동일한 UI를 보장하는 것이다.

### 9.2 JavaScript

Importmap은 현재 구조를 유지한다.

```ruby
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

추가되는 컨트롤러:

- `search_form_controller.js`
- `form_dependencies_controller.js`
- `popup_field_controller.js`

## 10. 파일 구조

```text
app/components/search_form/component.rb
app/components/search_form/component.html.erb
app/components/search_form/actions_component.rb
app/components/search_form/actions_component.html.erb
app/components/resource_form/component.rb
app/components/resource_form/component.html.erb
app/components/ui/form_fields/renderer_component.rb
app/components/ui/form_fields/layout_component.rb
app/helpers/search_form_helper.rb
app/helpers/resource_form_helper.rb
app/javascript/controllers/search_form_controller.js
app/javascript/controllers/form_dependencies_controller.js
app/javascript/controllers/popup_field_controller.js
app/views/shared/form_fields/_input.html.erb
app/views/shared/form_fields/_number.html.erb
app/views/shared/form_fields/_select.html.erb
app/views/shared/form_fields/_date_picker.html.erb
app/views/shared/form_fields/_date_range.html.erb
app/views/shared/form_fields/_textarea.html.erb
app/views/shared/form_fields/_checkbox.html.erb
app/views/shared/form_fields/_radio.html.erb
app/views/shared/form_fields/_switch.html.erb
app/views/shared/form_fields/_popup.html.erb
app/assets/stylesheets/vendor/daisyui.css
app/assets/stylesheets/forms.css
lib/ui/form_fields/definition.rb
lib/ui/form_fields/normalizer.rb
test/components/search_form/component_test.rb
test/components/ui/form_fields/renderer_component_test.rb
test/helpers/search_form_helper_test.rb
test/helpers/resource_form_helper_test.rb
```

## 11. 구현 원칙

### 11.1 SearchForm 전용 정책

- GET 기반 검색
- 파라미터 네임스페이스는 `q[...]`
- `date_range`, `popup`, collapse 지원
- AG Grid/Turbo Frame과 자연스럽게 연동

### 11.2 ResourceForm 전용 정책

- `form_with model:` 유지
- 서버 검증 에러 출력
- 저장/취소 버튼 제공
- 추후 동일 field renderer를 이용해 create/edit 화면 확대

### 11.3 공용 정책

- `label > label_key > humanize`
- `placeholder > placeholder_key > nil`
- safe field name 검증: `/\A[a-zA-Z0-9_]+\z/`
- type normalize: `date-picker` → `date_picker`
- 접근성: `<label for>`, `aria-invalid`, `aria-describedby`, `aria-expanded`

## 12. 단계별 구현

### Phase 1

- `SearchForm::Component`
- `Ui::FormFields::RendererComponent`
- `_input`, `_select`, `_date_picker`, `_date_range`
- `search_form_controller.js`
- DaisyUI CSS Propshaft 전환

### Phase 2

- `ResourceForm::Component`
- `_number`, `_textarea`, `_checkbox`, `_radio`, `_switch`
- `form_dependencies_controller.js`
- 공용 validation/help/error rendering

### Phase 3

- `_popup.html.erb`
- `popup_field_controller.js`
- AG Grid/Turbo modal 연계

## 13. 완료 기준

- `search_form`과 `resource_form`이 같은 field definition 구조를 사용한다.
- `_input.html.erb`, `_select.html.erb`, `_date_picker.html.erb`를 포함한 모든 field partial이 DaisyUI v5 클래스를 사용한다.
- 화면 컨테이너는 ViewComponent로 분리되어 있다.
- DaisyUI 자산은 Propshaft 경로에서 로드된다.
- JS는 Importmap + Stimulus만 사용한다.
- 검색 폼 reset, collapse, query 복원이 동작한다.
- resource_form의 저장 화면에서도 공용 field renderer가 정상 동작한다.

## 14. 결론

기존 SearchForm 문서는 helper와 partial 재사용에 초점이 맞춰져 있었고, ResourceForm 문서는 CRUD 확장성에 초점이 맞춰져 있었다. 이번 설계는 둘을 합쳐서 **화면은 ViewComponent로 분리하고, 필드는 shared form field layer로 공용화**하는 방향이다. 이 구조를 채택하면 검색 화면과 입력 화면이 서로 다른 제품이 아니라, 같은 폼 플랫폼 위의 두 가지 모드가 된다.


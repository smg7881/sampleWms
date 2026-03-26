# ResourceForm PRD

## 1. 문서 목적

이 문서는 `resource_form`을 `ViewComponent + Stimulus + DaisyUI v5 + Propshaft + Importmap` 조합으로 재설계하기 위한 기준 문서다. 목표는 CRUD 입력 화면을 새로 하나 더 만드는 것이 아니라, 현재 저장소에 이미 구현되어 있는 `search_form`의 공용 field platform 위에 `resource_form`을 올리는 것이다.

즉 이번 설계의 핵심은 아래 두 가지다.

1. `ResourceForm`의 화면 shell을 ViewComponent로 분리한다.
2. field 정의, field renderer, field partial, 일부 Stimulus 보조 로직은 `SEARCH_FORM`과 공용으로 사용한다.

---

## 2. 분석 결과

### 2.1 기존 `resource_form_prd.md`에서 유지할 것

- 선언형 `fields` 배열 기반 API
- `form_with model:` 기반 저장 폼
- `input`, `number`, `select`, `date_picker`, `textarea`, `checkbox`, `radio`, `switch` 지원
- `label`, `placeholder`, `help`, `required`, `span`, `options` 같은 field metadata 유지
- 서버 에러와 클라이언트 유효성 검사를 함께 다룸

### 2.2 `SEARCH_FORM_SAMPLE_IMPLEMENTATION_SUMMARY.md`에서 가져와야 할 것

- 화면 shell은 ViewComponent로 분리
- field 마크업은 `shared/form_fields` partial로 공용화
- `Ui::FormFields::RendererComponent`가 field type에 맞는 partial 렌더링
- DaisyUI v5 class를 field markup의 기본 규칙으로 사용
- Stimulus는 최소한의 상호작용만 담당

### 2.3 바꿔야 할 것

기존 문서의 `app/views/shared/resource_form/fields/*` 구조는 더 이상 목표 구조와 맞지 않는다. `resource_form` 전용 field partial을 따로 만들지 않고, `search_form`과 동일한 `app/views/shared/form_fields/*`를 사용해야 한다.

즉 구조는 다음처럼 정리한다.

- `SearchForm::Component`
  - 검색 shell 전용
- `ResourceForm::Component`
  - 저장 shell 전용
- `Ui::FormFields::*`
  - 두 form이 함께 쓰는 공용 field layer

---

## 3. 제품 목표

### 3.1 1차 목표

- `resource_form`을 ViewComponent 기반으로 재구성한다.
- `_input.html.erb`, `_select.html.erb`, `_date_picker.html.erb`를 포함한 모든 field partial은 DaisyUI v5 UI 컴포넌트 규칙을 사용한다.
- `fields` schema는 `SEARCH_FORM`과 동일한 구조를 사용한다.
- DaisyUI는 CDN이 아니라 Propshaft 자산으로 관리한다.
- JavaScript는 Importmap + Stimulus만 사용한다.

### 3.2 2차 목표

- 이후 CRUD 화면들이 `resource_form_tag` 한 줄로 표준 입력 화면을 생성할 수 있게 한다.
- `search_form`과 `resource_form`을 서로 다른 구현체가 아니라 같은 form platform의 두 가지 mode로 정리한다.

---

## 4. 목표 아키텍처

### 4.1 최상위 구조

```text
SearchForm::Component
ResourceForm::Component
ResourceForm::HeaderComponent
ResourceForm::ActionsComponent
Ui::FormFields::RendererComponent
Ui::FormFields::LayoutComponent
Ui::FormFields::ErrorSummaryComponent
```

### 4.2 역할 분리

- `ResourceForm::Component`
  - `form_with model:` wrapper
  - grid layout
  - error summary 연결
  - 공용 renderer 호출
- `ResourceForm::HeaderComponent`
  - 제목, 설명, badge, 보조 액션 영역
- `ResourceForm::ActionsComponent`
  - 저장, 취소, 추가 버튼 렌더링
- `Ui::FormFields::RendererComponent`
  - 공용 field schema 정규화
  - type별 partial 선택
  - `search`/`model` mode에 따라 값 바인딩 분기
- `Ui::FormFields::LayoutComponent`
  - 24 column grid, span class/style 계산
- `Ui::FormFields::ErrorSummaryComponent`
  - `model.errors` 요약 출력

### 4.3 helper의 역할

helper는 유지하되 얇은 진입점만 제공한다.

```ruby
def resource_form_tag(**options)
  render ResourceForm::Component.new(**options)
end
```

실제 렌더링 책임은 ViewComponent와 공용 field renderer로 이동한다.

### 4.4 기존 `Ui::ResourceFormComponent`와의 호환 정책

외부 참조 구현은 `Ui::ResourceFormComponent.new(model:, fields:, url:, method:, cols:, show_buttons:, submit_label:, cancel_url:, form_data:, form_html:, target_controller:, **html_options)` 시그니처를 사용한다. `simpleWms` 구현도 이 API를 최대한 유지해야 한다.

이 요구사항은 단순한 이름 호환이 아니라, 기존 CRUD modal/page 컴포넌트를 큰 수정 없이 이식하기 위한 계약이다. 따라서 다음 정책을 PRD에 추가한다.

- `resource_form_tag`는 최종 DSL 진입점으로 유지한다.
- 필요하면 `Ui::ResourceFormComponent`를 얇은 어댑터로 남겨 `ResourceForm::Component`를 내부 호출한다.
- wrapper `data-controller`는 사용자 지정 controller를 보존하면서 `resource-form`을 append한다.
- `form_data`, `form_html`, `target_controller`, `show_buttons` 옵션은 1차 구현 범위에 포함한다.

---

## 5. `SEARCH_FORM`과 공용으로 쓰는 Field Schema

### 5.1 공용 schema

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
  readonly: false,
  span: "24 s:12 m:8",
  help: "입력 또는 선택 조건 설명",
  options: [{ label: "사용", value: "Y" }, { label: "미사용", value: "N" }],
  include_blank: false,
  autocomplete: "off",
  inputmode: "text",
  pattern: nil,
  minlength: nil,
  maxlength: nil,
  min: nil,
  max: nil,
  step: nil,
  rows: nil,
  date_type: nil,
  depends_on: nil,
  depends_filter: nil,
  popup_type: nil,
  code_field: nil,
  action_button: nil
}
```

### 5.2 공용 타입 정책

- 공용 core field
  - `input`
  - `number`
  - `select`
  - `date_picker`
  - `textarea`
  - `checkbox`
  - `radio`
  - `switch`
- 확장 field
  - `popup`
  - `date_range`

`resource_form`은 core field를 기본 사용하고, 업무 요건이 있으면 `popup`까지 확장한다. `date_range`는 주로 `search_form`에서 사용하지만 schema는 공용으로 유지한다.

### 5.3 정규화 규칙

- safe field name: `/\A[a-zA-Z0-9_]+\z/`
- type normalize: `date-picker` -> `date_picker`
- option normalize
  - Hash: `{ label:, value: }`
  - Array: `[label, value]`
  - String: `label == value`
- label 우선순위: `label > label_key > humanize`
- placeholder 우선순위: `placeholder > placeholder_key > nil`

### 5.4 운영 호환을 위한 확장 field key

외부 구현 분석 결과, 실제 CRUD 화면은 기본 key만으로는 부족하다. 최소한 아래 key들은 schema에서 예약하거나 1차 구현에 포함해야 한다.

- 렌더링/배치
  - `value`, `target`, `rowspan`, `colspan`, `row_span`, `col_span`
- 입력 제어
  - `input_type`, `accept`, `multiple`, `searchable`, `multi`, `icon`, `tom_select`
- popup 제어
  - `popup_type`, `code_field`, `hide_display`, `display_width`, `code_width`, `button_width`
- 파일 업로드 확장
  - `max_files`, `max_size_mb`, `existing_target`, `selected_target`, `disable_file_attachments`

이 중 `value`, `target`, `input_type`, `popup_type`, `code_field`, `searchable`, `multi`, `tom_select`는 외부 구현 의존도가 높으므로 우선 반영 대상으로 본다.

### 5.5 whitelist 및 검증 정책

외부 구현은 허용되지 않은 key를 제거하고, 잘못된 field name/type에는 즉시 예외를 발생시킨다. 이 정책은 `simpleWms` PRD에도 추가한다.

- field 정의는 whitelist 기반으로 sanitize한다.
- 지원하지 않는 key는 무시하되 개발 로그에 경고를 남긴다.
- 잘못된 field name은 `ArgumentError`를 발생시킨다.
- 지원하지 않는 type은 `ArgumentError`를 발생시킨다.
- `popup` 타입은 `popup_type`, `code_field`가 필수다.

---

## 6. 공용 렌더링 전략

### 6.1 핵심 원칙

화면은 ViewComponent로 분리하고, field 최종 마크업은 shared partial로 유지한다. 이 방식이 사용자 요구사항과 현재 저장소 구조를 모두 만족한다.

### 6.2 파일 구조

```text
app/components/search_form/component.rb
app/components/search_form/component.html.erb
app/components/ui/resource_form_component.rb
app/components/ui/resource_form_component.html.erb
app/components/resource_form/component.rb
app/components/resource_form/component.html.erb
app/components/resource_form/header_component.rb
app/components/resource_form/header_component.html.erb
app/components/resource_form/actions_component.rb
app/components/resource_form/actions_component.html.erb
app/components/ui/form_fields/renderer_component.rb
app/components/ui/form_fields/renderer_component.html.erb
app/components/ui/form_fields/layout_component.rb
app/components/ui/form_fields/error_summary_component.rb
app/helpers/search_form_helper.rb
app/helpers/resource_form_helper.rb
test/components/ui/resource_form_component_test.rb
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
app/javascript/controllers/resource_form_controller.js
app/javascript/controllers/form_dependencies_controller.js
app/assets/stylesheets/vendor/daisyui.css
app/assets/stylesheets/forms.css
lib/ui/form_fields/definition.rb
lib/ui/form_fields/normalizer.rb
```

### 6.3 mode 분기 방식

`Ui::FormFields::RendererComponent`는 같은 partial을 `mode`에 따라 다르게 바인딩한다.

- `mode: :search`
  - `name="q[field]"`
  - 값은 `params[:q]`
- `mode: :model`
  - `form.text_field`, `form.select`, `form.check_box` 등 builder 사용
  - 값과 에러는 `model` 기준

이 구조를 사용하면 `SEARCH_FORM`과 `RESOURCE_FORM`은 shell만 다르고 field layer는 완전히 공용화할 수 있다.

---

## 7. DaisyUI v5 Field UI 기준

### 7.1 공통 원칙

- 모든 field는 DaisyUI `fieldset` 패턴을 기본으로 사용한다.
- label은 `label`, `label-text`, `label-text-alt` 조합으로 구성한다.
- custom CSS는 grid, spacing, error state, width 보정 정도만 담당한다.
- field별 UI는 DaisyUI class를 우선 사용하고, business-specific styling은 최소화한다.

### 7.2 partial별 DaisyUI 규칙

| Partial | DaisyUI 규칙 |
|--------|---------------|
| `_input.html.erb` | `fieldset`, `label`, `input input-bordered w-full` |
| `_number.html.erb` | `fieldset`, `label`, `input input-bordered w-full` |
| `_select.html.erb` | `fieldset`, `label`, `select select-bordered w-full` |
| `_date_picker.html.erb` | `fieldset`, `label`, `input input-bordered w-full` |
| `_date_range.html.erb` | `fieldset`, `label`, `join`, `input input-bordered join-item` |
| `_textarea.html.erb` | `fieldset`, `label`, `textarea textarea-bordered w-full` |
| `_checkbox.html.erb` | `label cursor-pointer`, `checkbox checkbox-primary` |
| `_radio.html.erb` | `label cursor-pointer`, `radio radio-primary` |
| `_switch.html.erb` | `label cursor-pointer`, `toggle toggle-primary` |
| `_popup.html.erb` | `join`, `input input-bordered`, `btn btn-outline` |

### 7.3 field 예시 마크업

#### `_input.html.erb`

```erb
<div class="<%= wrapper_class %>" style="<%= wrapper_style %>">
  <fieldset class="fieldset w-full">
    <label class="label" for="<%= field_id %>">
      <span class="label-text"><%= label_text %></span>
    </label>

    <%= builder_text_field %>

    <% if help_text.present? %>
      <p class="label"><span class="label-text-alt"><%= help_text %></span></p>
    <% end %>

    <% if error_text.present? %>
      <p class="label"><span class="label-text-alt text-error"><%= error_text %></span></p>
    <% end %>
  </fieldset>
</div>
```

#### `_select.html.erb`

```erb
<select class="select select-bordered w-full">
  <% normalized_options.each do |option| %>
    <option value="<%= option[:value] %>"><%= option[:label] %></option>
  <% end %>
</select>
```

#### `_date_picker.html.erb`

```erb
<input
  type="<%= field[:date_type] == 'datetime' ? 'datetime-local' : 'date' %>"
  class="input input-bordered w-full">
```

### 7.4 date picker 정책

DaisyUI v5는 별도 date picker widget을 제공하지 않으므로, `date_picker`는 native input 기반으로 구현한다.

- 기본: `<input type="date">`
- datetime 사용 시: `<input type="datetime-local">`
- range는 `date_range` partial에서 `from/to` 두 field로 구성

---

## 8. ResourceForm Component 설계

### 8.1 책임

- `form_with model:` wrapper 렌더링
- title, description, action 영역 분리
- `model.errors` 요약 출력
- 공용 field renderer 호출
- submit/cancel 버튼 렌더링
- inline error, help text, required mark 출력

### 8.2 입력 API

```ruby
resource_form_tag(
  model: @order,
  fields: [
    { field: "order_no", type: "input", label: "오더번호", required: true, span: "24 s:12 m:8" },
    { field: "status", type: "select", label: "상태", options: status_options, include_blank: true },
    { field: "ship_on", type: "date_picker", label: "출고일" },
    { field: "memo", type: "textarea", label: "메모", rows: 4, span: "24" },
    { field: "active", type: "switch", label: "사용 여부" }
  ],
  url: order_path(@order),
  method: :patch,
  cols: 3,
  title: "출고 오더 수정",
  description: "기본 정보와 운영 속성을 수정합니다.",
  submit_label: "저장",
  cancel_url: orders_path
)
```

### 8.3 화면 분리 원칙

- `ResourceForm::HeaderComponent`
  - 제목, 설명, 상태 badge
- `ResourceForm::Component`
  - form wrapper, grid, error summary
- `ResourceForm::ActionsComponent`
  - 저장, 취소, 보조 액션 버튼

이렇게 나누면 CRUD 페이지에서 header와 action 영역을 재구성하기 쉽다.

### 8.4 modal/page embedding 정책

외부 구현은 modal 안에서 `show_buttons: false`로 렌더링하고, modal shell의 외부 저장 버튼이 `form_html[:id]`를 통해 제출을 위임하는 패턴을 사용한다. 이 패턴은 실제 CRUD 화면 이식에 중요하므로 PRD에 포함한다.

- `show_buttons: false`를 공식 지원한다.
- `form_data`는 기본 `submit->resource-form#submit`에 merge 방식으로 결합한다.
- `form_html`은 `id`, `autocomplete`, `novalidate` 같은 form 속성을 외부에서 주입할 수 있어야 한다.
- `target_controller`는 field partial이 외부 Stimulus target/action과 연결될 때 사용한다.
- 저장 버튼이 form 외부에 있어도 정상 제출 가능한 구조를 허용한다.

---

## 9. Validation 및 에러 처리

### 9.1 클라이언트 측

`resource_form_controller.js`는 아래만 담당한다.

- submit 시 `checkValidity()` 수행
- invalid 시 `reportValidity()` 호출
- submit 중 버튼 disable 및 loading state 표시
- optional autosave 또는 dirty state는 이번 범위에서 제외

### 9.2 서버 측

- `model.errors`를 상단 summary로 출력
- 각 field 아래 inline error 출력
- invalid field에는 `input-error`, `select-error`, `textarea-error`, `toggle-error`에 준하는 상태 class를 추가
- `aria-invalid`, `aria-describedby`를 적용

### 9.3 공용 dependency 처리

`form_dependencies_controller.js`는 `search_form`과 `resource_form`이 공용으로 사용한다.

- 부모 select 값 변경 감지
- 자식 select option 필터링
- `data-all-options` JSON 기반 렌더링

추가로 wrapper에는 dependency 맵을 직렬화한 `data-resource-form-dependencies-value`를 부여해, 초기 렌더 직후에도 의존 select를 즉시 재구성할 수 있어야 한다.

### 9.4 ResourceForm controller public bridge

외부 구현에는 다른 Stimulus controller나 grid 유틸이 form 값을 읽고 쓰기 위한 public bridge가 존재한다. `simpleWms`도 통합 확장을 위해 아래 인터페이스를 설계에 포함한다.

- controller public method
  - `getResourceFieldValue(name)`
  - `setResourceFieldValue(name, value)`
- bridge helper 예시
  - `getResourceFormValue(...)`
  - `setResourceFormValue(...)`
  - `getResourceFieldElement(...)`

이 브리지는 radio, checkbox, multi-select, Tom Select 같은 복합 field도 동일한 방식으로 제어할 수 있어야 한다.

---

## 10. Propshaft + Importmap 정책

### 10.1 DaisyUI CSS

현재 레이아웃은 DaisyUI CDN을 직접 읽고 있다. `resource_form` 구현 시점에는 이를 Propshaft 자산으로 전환해야 한다.

```text
app/assets/stylesheets/vendor/daisyui.css
app/assets/stylesheets/forms.css
```

레이아웃 예시:

```erb
<%= stylesheet_link_tag "vendor/daisyui", "app", "data-turbo-track": "reload" %>
```

### 10.2 Stimulus 등록

Importmap 구조는 유지한다.

```ruby
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

추가 컨트롤러:

- `resource_form_controller.js`
- `form_dependencies_controller.js`

---

## 11. 반응형 및 레이아웃 기준

### 11.1 grid 정책

- 24 column grid 사용
- `span` 문자열은 `search_form`과 동일한 규칙으로 해석
- 예시
  - `24`
  - `24 s:12`
  - `24 s:12 m:8`
  - `24 s:12 m:6`

### 11.2 width 정책

- field 기본 width는 `w-full`
- 필요한 경우 `control_width`, `control_min_width`, `control_max_width` 지원
- 실제 배치는 wrapper span이 담당하고 control은 full width를 기본값으로 사용

### 11.3 접근성

- 모든 field는 `label for` 연결
- required field는 시각적 표시와 HTML 속성 둘 다 부여
- error summary는 폼 상단에 위치
- checkbox/radio/switch는 충분한 클릭 영역을 가진 label wrapper 사용

---

## 12. 구현 단계

### Phase 1. 공용 field layer 정비

- `Ui::FormFields::RendererComponent`를 `mode: :model`까지 확장
- `lib/ui/form_fields/definition.rb`, `normalizer.rb` 추가
- 공용 partial에 model binding 분기 추가

### Phase 2. ResourceForm shell 구현

- `ResourceForm::Component`
- `ResourceForm::HeaderComponent`
- `ResourceForm::ActionsComponent`
- `Ui::FormFields::ErrorSummaryComponent`

### Phase 3. DaisyUI/Propshaft 정비

- DaisyUI CSS를 vendor asset으로 이동
- `forms.css`에서 grid, spacing, error state 보강
- 기존 CDN 의존 제거

### Phase 4. Stimulus 및 테스트

- `resource_form_controller.js`
- `form_dependencies_controller.js`
- component/helper 테스트 추가
- model validation 연계 테스트 추가
- sanitize/예외 처리/component 계약 테스트 추가

### Phase 5. 확장 field 호환성

- `popup` 고도화
- `photo`, `multi_file`, `rich_textarea` 지원 여부 확정
- Tom Select 연동 필요 시 adapter 계층 추가
- grid/modal controller와의 bridge 연동 검증

---

## 13. 완료 기준

- `resource_form` 화면 shell이 ViewComponent로 분리되어 있다.
- `_input.html.erb`, `_select.html.erb`, `_date_picker.html.erb`를 포함한 모든 field partial이 DaisyUI v5 UI 규칙을 사용한다.
- `fields` schema가 `SEARCH_FORM`과 동일하다.
- `resource_form`이 `app/views/shared/form_fields/*`를 사용하고, 별도 `shared/resource_form/fields/*`를 만들지 않는다.
- `Ui::ResourceFormComponent` 또는 동등한 adapter가 기존 호출 시그니처를 수용한다.
- `form_data`, `form_html`, `target_controller`, `show_buttons: false`가 정상 동작한다.
- invalid field/type/popup 필수값 누락에 대한 검증이 동작한다.
- dependency 맵이 `data-resource-form-dependencies-value`로 전달되고 초기 렌더 시 반영된다.
- DaisyUI CSS가 Propshaft 자산으로 로드된다.
- JavaScript는 Importmap + Stimulus만 사용한다.
- 서버 에러와 inline error가 정상 출력된다.
- controller bridge가 field 값 read/write 확장 포인트를 제공한다.
- 공용 field renderer가 `search_form`과 `resource_form` 모두에서 동작한다.

---

## 14. 최종 결론

이번 `resource_form` PRD의 핵심은 CRUD 폼을 새로 분리 구현하는 것이 아니다. 현재 저장소에 이미 자리 잡은 `search_form`의 공용 field renderer 구조를 확장해서, `ResourceForm`은 ViewComponent 기반 shell만 별도로 두고 field layer는 그대로 공유하는 것이 맞다.

이 구조를 채택하면 사용자 요구사항인 ViewComponent 기반 화면 분리, DaisyUI v5 기반 field UI, Propshaft + Importmap 유지, `SEARCH_FORM`과의 field 공용화를 한 번에 만족할 수 있다.



# SearchForm PRD

## 1. 문서 목적

이 문서는 `SEARCH_FORM`을 `ViewComponent + Stimulus + DaisyUI v5 + Propshaft + Importmap` 조합으로 재설계하기 위한 기준 문서다. 기존 `SEARCH_FORM_PRD.md`, `SEARCH_FORM_IMPLEMENTATION.md`, `resource_form_prd.md`를 분석한 결과, 검색 폼과 CRUD 폼은 서로 다른 구현체가 아니라 **같은 field platform 위의 두 가지 mode**로 보는 것이 맞다.

따라서 이번 구현의 목표는 다음 두 가지다.

1. `search_form` 화면을 ViewComponent 기반으로 다시 설계한다.
2. `resource_form`과 `search_form`이 **동일한 field schema, 동일한 field renderer, 동일한 Stimulus 보조 로직**을 공유하도록 만든다.

---

## 2. 기존 문서 분석 결과

### 2.1 유지할 것

- 필드 정의 배열 기반 선언형 API
- `label > label_key > humanize` 우선순위
- `placeholder > placeholder_key > nil` 우선순위
- 반응형 span 문자열 (`24 s:12 m:8`)
- Stimulus는 최소 역할만 담당
- 검색 폼 reset, query 복원, collapse/expand 지원

### 2.2 바꿀 것

- 기존 `helper + partial` 중심 구조를 `ViewComponent + shared field renderer` 구조로 전환
- DaisyUI v5를 CDN 의존이 아닌 Propshaft 자산으로 관리
- `search_form`과 `resource_form`이 field partial을 따로 갖지 않고 공용 layer를 사용

### 2.3 핵심 판단

`search_form`은 GET 기반 검색 폼이고, `resource_form`은 `form_with model:` 기반 저장 폼이다. 바인딩 방식은 다르지만 필드 렌더링 요구는 대부분 같다. 따라서 화면 shell만 분리하고 field rendering layer는 합쳐야 한다.

---

## 3. 목표 아키텍처

### 3.1 최상위 구조

```text
SearchForm::Component
ResourceForm::Component
Ui::FormFields::RendererComponent
Ui::FormFields::ActionsComponent
Ui::FormFields::LayoutComponent
```

- `SearchForm::Component`
  - GET 검색 폼 shell
  - `params[:q]` 복원
  - reset/collapse/turbo-frame 연동
- `ResourceForm::Component`
  - `form_with model:` shell
  - submit/cancel/error summary
- `Ui::FormFields::*`
  - 두 form이 함께 쓰는 공용 field 계층

### 3.2 helper의 역할

기존 helper는 유지하지만 구현은 얇게 만든다.

```ruby
def search_form_tag(**options)
  render SearchForm::Component.new(**options)
end

def resource_form_tag(**options)
  render ResourceForm::Component.new(**options)
end
```

helper는 DSL 진입점만 제공하고, 실제 렌더링 책임은 ViewComponent로 이동한다.

---

## 4. 공용 Field Schema

두 form은 아래 schema를 공통으로 사용한다.

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
  help: "검색 조건을 선택하세요",
  options: [{ label: "전체", value: "" }, { label: "활성", value: "active" }],
  include_blank: false,
  autocomplete: "off",
  inputmode: "text",
  pattern: nil,
  minlength: nil,
  maxlength: nil,
  min: nil,
  max: nil,
  rows: nil,
  date_type: nil,
  depends_on: nil,
  depends_filter: nil,
  popup_type: nil,
  code_field: nil
}
```

### 4.1 공용 타입

- 공용 필드
  - `input`
  - `number`
  - `select`
  - `date_picker`
  - `textarea`
  - `checkbox`
  - `radio`
  - `switch`
- 검색 전용 확장 필드
  - `date_range`
  - `popup`

`search_form`은 공용 타입 중 필요한 것만 선택하고, `resource_form`은 CRUD 입력용 타입을 선택한다.

### 4.2 정규화 규칙

- safe field name: `/\A[a-zA-Z0-9_]+\z/`
- type normalize: `date-picker` → `date_picker`
- options normalize
  - Hash: `{ label:, value: }`
  - Array: `[label, value]`
  - String: `value == label`

---

## 5. 공용 렌더링 구조

### 5.1 파일 구조

```text
app/components/search_form/component.rb
app/components/search_form/component.html.erb
app/components/search_form/actions_component.rb
app/components/search_form/actions_component.html.erb
app/components/resource_form/component.rb
app/components/resource_form/component.html.erb
app/components/ui/form_fields/renderer_component.rb
app/components/ui/form_fields/renderer_component.html.erb
app/components/ui/form_fields/layout_component.rb
app/components/ui/form_fields/actions_component.rb
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
lib/ui/form_fields/definition.rb
lib/ui/form_fields/normalizer.rb
```

### 5.2 왜 shared partial을 유지하는가

사용자 요구사항에서 `_input.html.erb`, `_select.html.erb`, `_date_picker.html.erb` 같은 field 단위 템플릿을 명시했다. 따라서 화면 shell은 ViewComponent로 분리하되, field 마크업은 `shared/form_fields` partial로 유지하는 것이 가장 적합하다.

즉 구조는 다음과 같다.

- ViewComponent
  - 화면 단위 분리
  - grid/action/error summary/turbo binding 관리
- shared field partial
  - 모든 field UI의 최종 마크업 담당
  - DaisyUI v5 class 적용 지점

### 5.3 RendererComponent의 역할

`Ui::FormFields::RendererComponent`는 `context`를 받아 같은 partial을 다른 방식으로 바인딩한다.

- `mode: :search`
  - `name="q[field]"`
  - 값은 `params[:q]`
- `mode: :model`
  - `form.text_field`, `form.select`, `form.check_box` 등 builder 사용
  - 에러는 model.errors 사용

이 방식으로 field partial은 공용이지만 바인딩은 상황에 맞게 다르게 동작한다.

---

## 6. DaisyUI v5 적용 기준

### 6.1 기본 원칙

- field wrapper는 DaisyUI `fieldset`을 기본으로 사용한다.
- label은 `label`과 `label-text` 조합을 사용한다.
- 입력 control은 DaisyUI class만 사용한다.
- project custom CSS는 spacing, grid, error state 보완에만 사용한다.

### 6.2 field별 class 규칙

| Partial | DaisyUI 규칙 |
|--------|---------------|
| `_input.html.erb` | `fieldset`, `label`, `input input-bordered w-full` |
| `_number.html.erb` | `fieldset`, `label`, `input input-bordered w-full` |
| `_select.html.erb` | `fieldset`, `label`, `select select-bordered w-full` |
| `_date_picker.html.erb` | `fieldset`, `label`, `input input-bordered w-full` |
| `_date_range.html.erb` | `fieldset`, `label`, `join`, `input input-bordered` |
| `_textarea.html.erb` | `fieldset`, `label`, `textarea textarea-bordered w-full` |
| `_checkbox.html.erb` | `label cursor-pointer`, `checkbox` |
| `_radio.html.erb` | `label cursor-pointer`, `radio` |
| `_switch.html.erb` | `label cursor-pointer`, `toggle` |
| `_popup.html.erb` | `input input-bordered`, `btn btn-outline`, `join` |

### 6.3 예시 마크업

#### `_input.html.erb`

```erb
<fieldset class="fieldset w-full">
  <label class="label" for="<%= field_id %>">
    <span class="label-text"><%= resolve_label(field) %></span>
  </label>

  <input
    id="<%= field_id %>"
    name="<%= input_name %>"
    value="<%= field_value %>"
    type="text"
    class="input input-bordered w-full"
    placeholder="<%= resolve_placeholder(field) %>">

  <% if field[:help].present? %>
    <p class="label"><span class="label-text-alt"><%= field[:help] %></span></p>
  <% end %>
</fieldset>
```

#### `_select.html.erb`

```erb
<fieldset class="fieldset w-full">
  <label class="label" for="<%= field_id %>">
    <span class="label-text"><%= resolve_label(field) %></span>
  </label>

  <select id="<%= field_id %>" name="<%= input_name %>" class="select select-bordered w-full">
    <% normalized_options.each do |option| %>
      <option value="<%= option[:value] %>" <%= "selected" if option[:selected] %>><%= option[:label] %></option>
    <% end %>
  </select>
</fieldset>
```

#### `_date_picker.html.erb`

```erb
<fieldset class="fieldset w-full">
  <label class="label" for="<%= field_id %>">
    <span class="label-text"><%= resolve_label(field) %></span>
  </label>

  <input
    id="<%= field_id %>"
    name="<%= input_name %>"
    value="<%= field_value %>"
    type="<%= field[:date_type] == 'datetime' ? 'datetime-local' : 'date' %>"
    class="input input-bordered w-full">
</fieldset>
```

### 6.4 date picker 정책

DaisyUI v5는 전용 date picker widget을 제공하지 않으므로, `date_picker`는 native input 기반으로 구현한다.

- `date_picker`: `<input type="date">`
- `date_picker + date_type: "datetime"`: `<input type="datetime-local">`
- `date_range`: `from/to` 두 개 input + `join`

---

## 7. SearchForm Component 설계

### 7.1 책임

- 검색 form wrapper 렌더링
- GET 제출
- Turbo Frame target 지정
- 공용 field renderer 호출
- search/reset/collapse action 바인딩
- 검색 액션 버튼 렌더링

### 7.2 입력값

```ruby
SearchForm::Component.new(
  url: posts_path,
  fields: [...],
  turbo_frame: "main-content",
  cols: 3,
  enable_collapse: true,
  collapsed_rows: 1,
  show_reset: true,
  show_search: true
)
```

### 7.3 버튼 정책

- 검색: `btn btn-primary`
- 초기화: `btn btn-outline`
- 펼치기/접기: `btn btn-ghost btn-sm`

---

## 8. ResourceForm Component 설계

### 8.1 책임

- `form_with model:` wrapper 렌더링
- model.errors summary 출력
- 공용 field renderer 호출
- 저장/취소 버튼 렌더링
- 의존 필드, help, inline error 출력

### 8.2 입력값

```ruby
ResourceForm::Component.new(
  model: @post,
  fields: [...],
  url: post_path(@post),
  method: :patch,
  cols: 3,
  submit_label: "저장",
  cancel_url: posts_path
)
```

---

## 9. Stimulus 설계

### 9.1 `search_form_controller.js`

역할:

- `search()`
  - `checkValidity()`
  - 유효하면 submit
- `reset()`
  - `form.reset()`
  - `Turbo.visit(baseUrl, { frame: turboFrame })`
- `toggleCollapse()`
  - 접기/펼치기 토글
- `collapsedValueChanged()`
  - 실제 grid span 계산 후 visible field 결정

### 9.2 collapse 계산 방식

반응형 환경에서는 서버가 실제 span을 알 수 없으므로, Stimulus가 `getComputedStyle(el).gridColumnEnd`를 읽어 계산한다.

```javascript
#spanOf(el) {
  const value = getComputedStyle(el).gridColumnEnd
  const match = String(value).match(/span\s+(\d+)/)
  return match ? parseInt(match[1], 10) : 24
}
```

### 9.3 `form_dependencies_controller.js`

`search_form`, `resource_form` 공용.

- 부모 select 값 변경 감지
- 자식 select option 필터링
- `data-all-options` JSON 기반 동작

### 9.4 `popup_field_controller.js`

검색 전용.

- 팝업 open
- 선택 결과를 hidden code/display input에 반영
- 뒤로가기/새로고침 시 code 값 유지

---

## 10. Propshaft + Importmap 적용 정책

### 10.1 CSS 자산

현재 `application.html.erb`는 DaisyUI CDN을 직접 읽고 있다. 구현 시에는 이를 Propshaft 자산으로 전환한다.

```text
app/assets/stylesheets/vendor/daisyui.css
app/assets/stylesheets/forms.css
```

레이아웃 예시:

```erb
<%= stylesheet_link_tag "vendor/daisyui", "app", "data-turbo-track": "reload" %>
```

목표는 외부 CDN에 의존하지 않고, 배포 환경에서도 동일한 UI를 보장하는 것이다.

### 10.2 JS 자산

Importmap은 현 구조를 유지한다.

```ruby
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

추가 컨트롤러:

- `search_form_controller.js`
- `form_dependencies_controller.js`
- `popup_field_controller.js`

---

## 11. 반응형 및 접근성

### 11.1 grid 정책

- 기본: 24컬럼 grid
- `span` 문자열을 CSS class로 변환
- 예시
  - `24` → 모바일 full width
  - `24 s:12 m:8` → mobile 1열, sm 2열, md 3열

### 11.2 접근성 기준

- 모든 field는 `<label for>` 연결
- error 출력 시 `aria-invalid`, `aria-describedby` 적용
- collapse 버튼은 `aria-expanded` 유지
- 검색 버튼은 keyboard submit 지원
- checkbox/radio/switch는 클릭 영역이 충분한 label wrapper 사용

---

## 12. 구현 단계

### Phase 1. SearchForm 기반 구축

- `SearchForm::Component`
- `Ui::FormFields::RendererComponent`
- `_input`, `_select`, `_date_picker`, `_date_range`
- `search_form_controller.js`
- DaisyUI CSS Propshaft 전환

### Phase 2. ResourceForm 공용화

- `ResourceForm::Component`
- `_number`, `_textarea`, `_checkbox`, `_radio`, `_switch`
- inline error/help/required mark 공용 처리
- `form_dependencies_controller.js`

### Phase 3. Popup 및 고도화

- `_popup.html.erb`
- `popup_field_controller.js`
- AG Grid/Turbo modal 연계
- field preset 고도화

---

## 13. 완료 기준

- `search_form`과 `resource_form`이 같은 field schema를 사용한다.
- `_input.html.erb`, `_select.html.erb`, `_date_picker.html.erb`를 포함한 모든 field partial이 DaisyUI v5 class를 사용한다.
- 화면 shell은 ViewComponent로 분리되어 있다.
- DaisyUI CSS는 Propshaft 자산에서 로드된다.
- JS는 Importmap + Stimulus만 사용한다.
- reset, collapse, query 복원이 정상 동작한다.
- resource_form에서도 동일한 field renderer가 정상 동작한다.

---

## 14. 최종 결론

이번 설계의 핵심은 `SearchForm`을 새로 만드는 것이 아니라, `SearchForm`과 `ResourceForm`을 같은 폼 플랫폼 위에 올리는 것이다. 화면은 ViewComponent로 분리하고, field는 shared partial layer로 공용화하며, DaisyUI v5는 모든 field 마크업의 기본 UI 규칙으로 사용한다. 이 방향이 현재 저장소의 Rails 8 + ViewComponent + Stimulus + Importmap 구조와 가장 잘 맞고, 이후 CRUD 화면 확장에도 가장 유리하다.


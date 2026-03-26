# Main Screen Plan

## Source Analysis

- Reference source: `D:\myProject\smgWms`
- Main layout pattern found in the reference app:
  - left sidebar with company mark and hierarchical menu
  - header with current site, breadcrumb, sidebar toggle, search area
  - center tab strip for multi-workspace navigation
  - main content area that swaps by active tab
- Relevant files reviewed:
  - `app/views/layouts/application.html.erb`
  - `app/views/shared/_sidebar.html.erb`
  - `app/views/shared/_header.html.erb`
  - `app/views/shared/_tab_bar.html.erb`
  - `app/javascript/controllers/tabs_controller.js`
  - `app/javascript/controllers/sidebar_controller.js`
  - `config/routes.rb`

## Implementation Direction

- Current target app: `D:\simpleWms`
- Requested stack applied:
  - `ViewComponent` for the shell structure
  - `Stimulus` for sidebar toggle, menu search, tab open/close/activate
  - `DaisyUI v5` for baseline UI primitives
- Asset choice:
  - keep current `Propshaft + Importmap`
  - load DaisyUI through CDN for fast integration without rebuilding the CSS toolchain

## Components

- `Layout::AppShellComponent`
  - top-level shell composition
- `Layout::SidebarComponent`
  - company logo area
  - grouped side menus based on analyzed source structure
- `Layout::TopbarComponent`
  - site name
  - breadcrumb
  - sidebar toggle
  - search field
- `Layout::TabBarComponent`
  - pinned overview tab
  - dynamic workspace tabs
- `Workspace::PanelComponent`
  - active content panel per tab

## Stimulus Behaviors

- `shell_controller.js`
  - sidebar collapse and mobile hide/show
  - menu-to-tab opening
  - tab activation and closing
  - breadcrumb syncing
  - sidebar menu filtering from the search input
- `sidebar_controller.js`
  - section open/close tree behavior

## Menu Mapping from Reference Source

- 메인
  - 운영 대시보드
- 시스템 관리
  - 메뉴 관리
  - 사용자 관리
  - 권한 설정
- 기준 정보
  - 거래처 기준
  - 사업장 기준
  - 상품 기준
- 창고 운영
  - 작업장 운영
  - 로케이션 관리
  - 재고 이동
- 주문 운영
  - 대기 주문
  - 내부 주문
  - 주문 조회

## Follow-up Expansion Path

- replace static catalog data with DB-backed menu models
- load real workspace content per tab using Turbo Frames
- connect AG Grid only inside workspace panels that need dense tabular interaction
- persist open tabs per session when the app grows beyond the current main screen prototype

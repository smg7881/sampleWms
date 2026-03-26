class NavigationCatalog
  class << self
    def brand
      {
        mark: "W",
        name: "WMS Pro",
        subtitle: "warehouse operations",
        current_site: "메인"
      }
    end

    def default_tabs
      [
        {
          id: "overview",
          label: "대시보드",
          trail: "메인 / 대시보드",
          pinned: true
        }
      ]
    end

    def sections
      [
        {
          key: "main",
          label: "메인",
          icon: "layout-grid",
          open: true,
          items: [
            menu_item("overview", "대시보드", "chart-column", nil, "메인 / 대시보드", ""),
            menu_item("sample-search-form", "SearchForm 샘플", "flask-conical", nil, "메인 / SearchForm 샘플", "", href: "/samples/search-form"),
            menu_item("sample-resource-form", "ResourceForm 샘플", "file-pen", nil, "메인 / ResourceForm 샘플", "", href: "/samples/resource-form")
          ]
        },
        {
          key: "system",
          label: "시스템",
          icon: "settings",
          open: false,
          items: [
            menu_item("system-menus", "메뉴 관리", "layout-grid", nil, "시스템 / 메뉴 관리", ""),
            menu_item("system-users", "사용자 관리", "users", nil, "시스템 / 사용자 관리", ""),
            menu_item("system-roles", "권한 설정", "shield", nil, "시스템 / 권한 설정", "")
          ]
        },
        {
          key: "standard",
          label: "기준정보",
          icon: "database",
          open: false,
          items: [
            menu_item("std-clients", "거래처 기준", "building-2", nil, "기준정보 / 거래처 기준", ""),
            menu_item("std-workplaces", "사업장 기준", "map-pinned", nil, "기준정보 / 사업장 기준", ""),
            menu_item("std-goods", "상품 기준", "package", nil, "기준정보 / 상품 기준", "")
          ]
        },
        {
          key: "orders",
          label: "오더관리",
          icon: "clipboard-list",
          open: false,
          items: [
            menu_item("om-waiting-orders", "대기 주문", "clipboard-list", nil, "오더관리 / 대기 주문", ""),
            menu_item("om-internal-orders", "내부 주문", "sparkles", nil, "오더관리 / 내부 주문", ""),
            menu_item("om-order-inquiry", "주문 조회", "search", nil, "오더관리 / 주문 조회", "")
          ]
        },
        {
          key: "sales",
          label: "영업관리",
          icon: "briefcase-business",
          open: false,
          items: [
            menu_item("sales-clients", "고객사 기준", "building-2", nil, "영업관리 / 고객사 기준", ""),
            menu_item("sales-goods", "상품 기준", "package", nil, "영업관리 / 상품 기준", "")
          ]
        },
        {
          key: "storage",
          label: "보관(VM)",
          icon: "archive",
          open: false,
          items: [
            menu_item("wm-location", "로케이션 관리", "map", nil, "보관(VM) / 로케이션 관리", ""),
            menu_item("wm-stock-moves", "재고 이동", "shuffle", nil, "보관(VM) / 재고 이동", "")
          ]
        },
        {
          key: "wms",
          label: "WMS",
          icon: "house",
          open: false,
          items: [
            menu_item("wm-workplace", "작업장 운영", "warehouse", nil, "WMS / 작업장 운영", ""),
            menu_item("wms-workplaces", "사업장 기준", "map-pinned", nil, "WMS / 사업장 기준", "")
          ]
        }
      ]
    end

    def panels
      panel_items.index_by { |panel| panel[:id] }
    end

    private

    def menu_item(id, label, icon, badge, trail, summary, href: nil)
      {
        id: id,
        label: label,
        icon: icon,
        badge: badge,
        trail: trail,
        summary: summary,
        href: href
      }
    end

    def panel_items
      [
        overview_panel,
        workspace_panel(
          "system-menus",
          "layout-grid",
          "시스템 / 메뉴 관리",
          "메뉴 관리",
          [
            { label: "활성 메뉴", value: "124", delta: nil },
            { label: "신규 메뉴", value: "18", delta: nil },
            { label: "역할 매핑", value: "46", delta: nil },
            { label: "최근 변경", value: "3", delta: nil }
          ]
        ),
        workspace_panel(
          "system-users",
          "users",
          "시스템 / 사용자 관리",
          "사용자 관리",
          [
            { label: "활성 사용자", value: "62", delta: nil },
            { label: "잠금 계정", value: "02", delta: nil },
            { label: "승인 요청", value: "07", delta: nil },
            { label: "오늘 접속", value: "19", delta: nil }
          ]
        ),
        workspace_panel(
          "system-roles",
          "shield",
          "시스템 / 권한 설정",
          "권한 설정",
          [
            { label: "역할 수", value: "14", delta: nil },
            { label: "변경 예정", value: "03", delta: nil },
            { label: "감사 로그", value: "291", delta: nil },
            { label: "예외 권한", value: "01", delta: nil }
          ]
        ),
        workspace_panel(
          "std-clients",
          "building-2",
          "기준정보 / 거래처 기준",
          "거래처 기준",
          [
            { label: "활성 거래처", value: "318", delta: nil },
            { label: "계약 만료 임박", value: "11", delta: nil },
            { label: "당일 변경", value: "04", delta: nil },
            { label: "신규 요청", value: "02", delta: nil }
          ]
        ),
        workspace_panel(
          "std-workplaces",
          "map-pinned",
          "기준정보 / 사업장 기준",
          "사업장 기준",
          [
            { label: "센터 수", value: "12", delta: nil },
            { label: "구역 수", value: "76", delta: nil },
            { label: "미매핑", value: "05", delta: nil },
            { label: "재고 예정", value: "01", delta: nil }
          ]
        ),
        workspace_panel(
          "std-goods",
          "package",
          "기준정보 / 상품 기준",
          "상품 기준",
          [
            { label: "SKU", value: "4,281", delta: nil },
            { label: "미분류", value: "19", delta: nil },
            { label: "속성 충돌", value: "03", delta: nil },
            { label: "바코드 수정", value: "07", delta: nil }
          ]
        ),
        workspace_panel(
          "wm-workplace",
          "warehouse",
          "WMS / 작업장 운영",
          "작업장 운영",
          [
            { label: "가동 라인", value: "08", delta: nil },
            { label: "대기 작업", value: "27", delta: nil },
            { label: "응답 지연", value: "01", delta: nil },
            { label: "완료", value: "143", delta: nil }
          ]
        ),
        workspace_panel(
          "wm-location",
          "map",
          "보관(VM) / 로케이션 관리",
          "로케이션 관리",
          [
            { label: "가용 위치", value: "91%", delta: nil },
            { label: "빈 위치", value: "17", delta: nil },
            { label: "실사 예정", value: "06", delta: nil },
            { label: "과적 구역", value: "02", delta: nil }
          ]
        ),
        workspace_panel(
          "wm-stock-moves",
          "shuffle",
          "보관(VM) / 재고 이동",
          "재고 이동",
          [
            { label: "이동 요청", value: "34", delta: nil },
            { label: "확인 대기", value: "05", delta: nil },
            { label: "완료율", value: "82%", delta: nil },
            { label: "긴급 이동", value: "02", delta: nil }
          ]
        ),
        workspace_panel(
          "om-waiting-orders",
          "clipboard-list",
          "오더관리 / 대기 주문",
          "대기 주문",
          [
            { label: "대기 주문", value: "83", delta: nil },
            { label: "SLA 임박", value: "12", delta: nil },
            { label: "보류", value: "07", delta: nil },
            { label: "오류", value: "01", delta: nil }
          ]
        ),
        workspace_panel(
          "om-internal-orders",
          "sparkles",
          "오더관리 / 내부 주문",
          "내부 주문",
          [
            { label: "내부 주문", value: "26", delta: nil },
            { label: "수정 요청", value: "08", delta: nil },
            { label: "취소 대기", value: "02", delta: nil },
            { label: "처리 완료", value: "71", delta: nil }
          ]
        ),
        workspace_panel(
          "om-order-inquiry",
          "search",
          "오더관리 / 주문 조회",
          "주문 조회",
          [
            { label: "오늘 조회", value: "214", delta: nil },
            { label: "예외 검색", value: "14", delta: nil },
            { label: "공유 마크", value: "07", delta: nil },
            { label: "추적 중", value: "03", delta: nil }
          ]
        )
      ]
    end

    def overview_panel
      {
        id: "overview",
        label: "대시보드",
        icon: "chart-column",
        eyebrow: "OVERVIEW",
        title: "대시보드",
        description: "창고 운영 현황을 한 화면에서 확인합니다.",
        tone: "green",
        metrics: [
          { label: "전체 공지사항", value: "1", delta: nil },
          { label: "오늘 작성", value: "0", delta: nil },
          { label: "이번 주", value: "0", delta: nil },
          { label: "이번 달", value: "0", delta: nil }
        ],
        actions: [],
        highlights: [],
        table: {
          columns: ["#", "제목", "작성일"],
          rows: [
            ["1", "test", "2026-02-20 19:24"]
          ]
        }
      }
    end

    def workspace_panel(id, icon, trail, title, metrics)
      {
        id: id,
        label: title,
        icon: icon,
        eyebrow: trail,
        title: title,
        description: nil,
        tone: "blue",
        metrics: metrics,
        actions: [],
        highlights: [],
        table: {
          columns: ["#", "항목", "상태", "작성일"],
          rows: [
            ["1", "#{title} 기본 현황", "정상", "2026-03-24 09:10"],
            ["2", "#{title} 점검 항목", "대기", "2026-03-24 08:40"]
          ]
        }
      }
    end
  end
end

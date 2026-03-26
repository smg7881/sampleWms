module ApplicationHelper
  LUCIDE_ICON_ALIASES = {
    "spark" => "sparkles",
    "search-list" => "search",
    "chart" => "chart-column"
  }.freeze

  def ui_icon(name, css_class: nil)
    icon_name = LUCIDE_ICON_ALIASES.fetch(name.to_s, name.to_s)
    classes = ["ui-icon", css_class].compact.join(" ")

    tag.i(nil, class: classes, data: { lucide: icon_name }, aria: { hidden: true })
  end
end

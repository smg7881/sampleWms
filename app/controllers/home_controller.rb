class HomeController < ApplicationController
  def index
    @brand = NavigationCatalog.brand
    @sections = NavigationCatalog.sections
    @tabs = NavigationCatalog.default_tabs
    @active_tab_id = "overview"
    @panels = NavigationCatalog.panels
  end
end

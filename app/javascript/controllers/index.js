import { application } from "controllers/application"
import LucideController from "controllers/lucide_controller"
import ResourceFormController from "controllers/resource_form_controller"
import SearchFormController from "controllers/search_form_controller"
import SearchPopupController from "controllers/search_popup_controller"
import ShellController from "controllers/shell_controller"
import SidebarController from "controllers/sidebar_controller"

application.register("lucide", LucideController)
application.register("resource-form", ResourceFormController)
application.register("search-form", SearchFormController)
application.register("search-popup", SearchPopupController)
application.register("shell", ShellController)
application.register("sidebar", SidebarController)

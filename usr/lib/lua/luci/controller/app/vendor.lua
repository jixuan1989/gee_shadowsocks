--[[
]]--

module("luci.controller.app.vendor", package.seeall)

function index()
	local page   = node("app", "vendor")
	page.target  = firstchild()
	page.title   = _("")
	page.order   = 10
	page.sysauth = "admin"
	page.sysauth_authenticator = "jsonauth"
	page.index = true
	
	entry({"app"}, firstchild(), _(""), 700)
	entry({"app", "vendor"}, firstchild(), _(""), 700)
	entry({"app", "vendor", "ss"}, template("app/vendor/ss"), _("status"), 700, true)
	entry({"app", "vendor", "ss_ajax"}, template("app/vendor/ss_ajax"), _("status"), 700, true)
end

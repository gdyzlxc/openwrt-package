module("luci.controller.passwall_server",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/passwall_server")then
		return
	end
	entry({"admin", "vpn"}, firstchild(), "VPN", 45).dependent = false
	if nixio.fs.access("/usr/bin/ssr-server") then
		entry({"admin","vpn","passwall_server"},alias("admin","vpn","passwall_server","ssr"),_("Pass Wall Server"),3).dependent=true
		entry({"admin","vpn","passwall_server","ssr"},cbi("passwall_server/ssr"),_("SSR Libev Server"),1).dependent=true
	end
	if nixio.fs.access("/usr/bin/v2ray/v2ray") then
		if nixio.fs.access("/usr/bin/ssr-server")==false then entry({"admin","vpn","passwall_server"},alias("admin","vpn","passwall_server","v2ray"),_("Pass Wall Server"),3).dependent=true end
		entry({"admin","vpn","passwall_server","v2ray"},cbi("passwall_server/v2ray"),_("V2ray Server"),2).dependent=true
	end
	entry({"admin","vpn","passwall_server","ssr_config"},cbi("passwall_server/ssr_config")).leaf=true
	entry({"admin","vpn","passwall_server","v2ray_config"},cbi("passwall_server/v2ray_config")).leaf=true
	
	entry({"admin","vpn","passwall_server","ssr_status"},call("act_ssr_status")).leaf=true
	entry({"admin","vpn","passwall_server","v2ray_status"},call("act_v2ray_status")).leaf=true
end

function act_ssr_status()
	local e={}
	e.index=luci.http.formvalue("index")
	e.status=luci.sys.call("ps -w| grep -v grep | grep '/var/etc/passwall_server/ssr-server_" .. luci.http.formvalue("id") .. "' >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function act_v2ray_status()
	local e={}
	e.index=luci.http.formvalue("index")
	e.status=luci.sys.call("ps -w| grep -v grep | grep '/var/etc/passwall_server/v2ray-server_" .. luci.http.formvalue("id") .. "' >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
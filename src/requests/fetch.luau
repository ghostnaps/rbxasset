local net = require("@lune/net")

local logging = require("@root/logging")

type HttpMethod = "GET" | "POST" | "PATCH"

type FetchOptions = {
	method: HttpMethod?,
	headers: { [string]: string }?,
	body: string?,
}

local function fetch(url: string, options: FetchOptions)
	local method: HttpMethod = options.method or "GET"

	logging.debug(`{method} {url}`)

	return net.request({
		url = url,
		method = method,
		headers = options.headers,
		body = options.body,
	})
end

return fetch

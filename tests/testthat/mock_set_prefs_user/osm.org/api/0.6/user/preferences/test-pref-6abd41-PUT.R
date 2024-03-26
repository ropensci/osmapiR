structure(list(method = "PUT", url = "osm.org/api/0.6/user/preferences/test-pref", 
    status_code = 200L, headers = structure(list(`cache-control` = "no-cache", 
        vary = "Origin,Accept-Encoding", `referrer-policy` = "strict-origin-when-cross-origin", 
        `x-permitted-cross-domain-policies` = "none", `x-xss-protection` = "1; mode=block", 
        `x-request-id` = "01234567-89ab-cdef-0123-456789abcdef", 
        `x-download-options` = "noopen", `x-runtime` = "0.019066", 
        `x-frame-options` = "sameorigin", `x-content-type-options` = "nosniff", 
        `content-security-policy` = "default-src 'self'; child-src 'self'; connect-src 'self'; font-src 'none'; form-action 'self'; frame-ancestors 'self'; frame-src 'self'; img-src 'self' data: www.gravatar.com *.wp.com tile.openstreetmap.org *.tile.openstreetmap.org *.tile.thunderforest.com tile.tracestrack.com *.openstreetmap.fr; manifest-src 'self'; media-src 'none'; object-src 'self'; script-src 'self'; style-src 'self'; worker-src 'none'", 
        date = "DoW, 24 Jun 2024 00:00:00 GMT", `x-powered-by` = "Phusion Passenger(R) 6.0.20", 
        `strict-transport-security` = "max-age=31536000; includeSubDomains; preload", 
        status = "200 OK", `content-encoding` = "br", `x-robots-tag` = "noindex, nofollow", 
        `content-length` = "1", `content-type` = "text/plain; charset=utf-8", 
        server = "Apache/2.4.54 (Ubuntu)"), class = "httr2_headers"), 
    body = raw(0), request = structure(list(url = "https://master.apis.dev.openstreetmap.org/api/0.6/user/preferences/test-pref", 
        method = "PUT", headers = structure(list(Authorization = "Bearer *******************************************"), redact = "Authorization"), 
        body = list(data = "value", type = "raw", content_type = "", 
            params = list()), fields = list(), options = list(
            useragent = "osmapiR (https://github.com/jmaspons/osmapiR)"), 
        policies = list(retry_max_tries = 10L, error_body = function (resp) 
        {
            out <- switch(httr2::resp_content_type(resp), `text/plain` = httr2::resp_body_string(resp), 
                `text/html` = parse_html_error(resp), httr2::resp_headers(resp)$status)
            return(out)
        }, auth_oauth = list(cache = list(get = function () 
        env_get(the$token_cache, key, default = NULL), set = function (token) 
        env_poke(the$token_cache, key, token), clear = function () 
        env_unbind(the$token_cache, key)), flow = "oauth_flow_auth_code", 
            flow_params = list(client = structure(list(name = "osmapiR", 
                id = "*******************************************", 
                secret = structure("*******************************************************************************", class = "httr2_obfuscated"), 
                key = NULL, token_url = "https://master.apis.dev.openstreetmap.org/oauth2/token", 
                auth = "oauth_client_req_auth_header", auth_params = list()), class = "httr2_oauth_client"), 
                auth_url = "https://master.apis.dev.openstreetmap.org/oauth2/authorize", 
                scope = "read_prefs write_prefs write_api read_gpx write_gpx write_notes", 
                pkce = TRUE, auth_params = list(), token_params = list(), 
                redirect_uri = "http://127.0.0.1:26829")))), class = "httr2_request"), 
    cache = new.env(parent = emptyenv())), class = "httr2_response")

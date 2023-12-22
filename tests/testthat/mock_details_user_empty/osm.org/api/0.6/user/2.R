structure(list(method = "GET", url = "osm.org/api/0.6/user/2", 
    status_code = 404L, headers = structure(list(`cache-control` = "no-cache", 
        vary = "Origin", `referrer-policy` = "strict-origin-when-cross-origin", 
        `x-permitted-cross-domain-policies` = "none", `x-xss-protection` = "1; mode=block", 
        `x-request-id` = "ZYVkIrbfeKlgLEQBf3XWnQABwzE", `x-download-options` = "noopen", 
        `x-runtime` = "0.012696", `x-frame-options` = "sameorigin", 
        `x-content-type-options` = "nosniff", `content-security-policy` = "default-src 'self'; child-src 'self'; connect-src 'self' matomo.openstreetmap.org; font-src 'none'; form-action 'self'; frame-ancestors 'self'; frame-src 'self'; img-src 'self' data: www.gravatar.com *.wp.com tile.openstreetmap.org *.tile.openstreetmap.org *.tile.thunderforest.com tileserver.memomaps.de tile.tracestrack.com *.openstreetmap.fr matomo.openstreetmap.org https://openstreetmap-user-avatars.s3.dualstack.eu-west-1.amazonaws.com https://openstreetmap-gps-images.s3.dualstack.eu-west-1.amazonaws.com; manifest-src 'self'; media-src 'none'; object-src 'self'; script-src 'self' matomo.openstreetmap.org; style-src 'self'; worker-src 'none'", 
        date = "Fri, 22 Dec 2023 10:25:38 GMT", `x-powered-by` = "Phusion Passenger(R) 6.0.19", 
        `strict-transport-security` = "max-age=31536000; includeSubDomains; preload", 
        status = "404 Not Found", `content-type` = "text/html; charset=utf-8", 
        server = "Apache/2.4.54 (Ubuntu)"), class = "httr2_headers"), 
    body = raw(0), request = structure(list(url = "https://api.openstreetmap.org/api/0.6/user/2", 
        method = "GET", headers = list(), body = NULL, fields = list(), 
        options = list(useragent = "osmapiR (https://github.com/jmaspons/osmapiR)"), 
        policies = list(retry_max_tries = 10L, error_body = function (resp) 
        {
            out <- switch(httr2::resp_content_type(resp), `text/plain` = httr2::resp_body_string(resp), 
                `text/html` = parse_html_error(resp), httr2::resp_headers(resp)$status)
            return(out)
        })), class = "httr2_request"), cache = new.env(parent = emptyenv())), class = "httr2_response")

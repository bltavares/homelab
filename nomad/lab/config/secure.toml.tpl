[http.middlewares.auth.forwardAuth]
    address = "http://{{ env "NOMAD_ADDR_proxyAuth" }}"
    authResponseHeaders = ["X-Forwarded-User"]
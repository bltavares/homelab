consul.exe agent -dev -ui `
    -data-dir ../secrets/consul `
    -encrypt "$(Get-Content ../secrets/consul.key)" `
    -bind '{{ GetPrivateInterfaces | include \"network\" \"fc36:152b:7a00::/40\" | attr \"address\"}}' `
    -client '127.0.0.1 {{range $i, $e := GetPrivateInterfaces }}{{if eq $e.MTU 2800 }}{{if $i}} {{end}}{{attr  \"address\" $e}}{{end}}{{end}}' `
    -retry-join "vaporware.zerotier.bltavares.com" `
    -retry-join "tiny.zerotier.bltavares.com" `
    -retry-join "romulus.zerotier.bltavares.com" `
    -retry-join "ryzen.zerotier.bltavares.com" `
kickstart.context 'OpenWISP'

test -x /usr/local/bin/docker-compose || (
    kickstart.info "Installing docker-compose"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
)

kickstart.package.install git

test -d /opt/openwisp || git clone https://github.com/openwisp/docker-openwisp /opt/openwisp

cp files/secrets/openwisp.env /opt/openwisp/.env

(
    cd /opt/openwisp
    make
    docker-compose up -d
)
#!/usr/bin/env bash
set -eo pipefail


read_secret() {
    local secret_path="/run/secrets/$1"
    local default="${2:-}"
    local value

    if [[ -f "$secret_path" ]]; then
        value="$(< "$secret_path")"
    fi

    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}


config_file='/etc/icecast2/icecast.xml'
config_map=$(cat << EOF
icecast_source_password /icecast/authentication/source-password
icecast_relay_password /icecast/authentication/relay-password
icecast_admin_user /icecast/authentication/admin-user
icecast_admin_password /icecast/authentication/admin-password
EOF
)
args=$(
    while IFS=' ' read -r secret xpath; do
        if xmlstarlet sel -t -c "$xpath" $config_file > /dev/null; then
            config_value="$(xmlstarlet sel -t -v "$xpath" $config_file)"
            value="$(read_secret "$secret" "$config_value")"
            [[ "$value" == "$config_value" ]] || echo -n " -u $xpath -v $value"
        else
            default="$(pwgen -s1 16 1)"
            value="$(read_secret "$secret" "$default")"
            echo -n " -s ${xpath%/*} -t elem -n ${xpath##*/} -v $value"
        fi
    done <<< "$config_map" | sort -u
)


if [[ -n "$args" ]]; then
    config_backup="$config_file.back"
    cp "$config_file" "$config_file.back"
    xmlstarlet ed $args "$config_backup" > "$config_file"
fi

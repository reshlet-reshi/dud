# shellcheck shell=sh

read_source_fetch() {
    if [ "$#" -ne 1 ]; then
        printf '%s\n' 'read_source_fetch requires a source.fetch path' >&2
        return 2
    fi

    source_fetch_path=$1

    if [ ! -f "$source_fetch_path" ]; then
        printf '%s\n' "source.fetch is not a regular file: $source_fetch_path" >&2
        return 2
    fi

    if [ ! -r "$source_fetch_path" ]; then
        printf '%s\n' "source.fetch is not readable: $source_fetch_path" >&2
        return 2
    fi

    source_fetch_url=
    source_fetch_out=
    source_fetch_sha256=
    source_fetch_field_count=0
    source_fetch_has_extra=0

    while IFS=' 	' read -r \
        source_fetch_field_1 \
        source_fetch_field_2 \
        source_fetch_field_3 \
        source_fetch_field_extra \
        || [ -n "$source_fetch_field_1$source_fetch_field_2$source_fetch_field_3$source_fetch_field_extra" ]
    do
        for source_fetch_field in \
            "$source_fetch_field_1" \
            "$source_fetch_field_2" \
            "$source_fetch_field_3" \
            "$source_fetch_field_extra"
        do
            if [ -n "$source_fetch_field" ]; then
                source_fetch_field_count=$((source_fetch_field_count + 1))

                case $source_fetch_field_count in
                    1) source_fetch_url=$source_fetch_field ;;
                    2) source_fetch_out=$source_fetch_field ;;
                    3) source_fetch_sha256=$source_fetch_field ;;
                    *) source_fetch_has_extra=1 ;;
                esac
            fi
        done
    done <"$source_fetch_path"

    if [ "$source_fetch_field_count" -ne 3 ] \
        || [ "$source_fetch_has_extra" -ne 0 ]
    then
        printf '%s\n' "source.fetch must contain exactly three fields: $source_fetch_path" >&2
        return 2
    fi

    # These globals are the output contract for callers that source this file.
    : "$source_fetch_url" "$source_fetch_out" "$source_fetch_sha256"
}

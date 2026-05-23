if [ "${dud_tmp:-}" = "" ]; then
    printf '%s\n' 'dud_tmp is not set' >&2
    return 1
fi

if ./bin/test-mkdir --dir-path "$dud_tmp"; then
    status=0
else
    status=$?
fi

if [ "$status" -eq 2 ]; then
    return 1
fi

if [ "$status" -eq 0 ]; then
    mkdir -p "$dud_tmp"
    _dud_tmp_created_path=$dud_tmp
    _cleanup_dud_tmp() {
        rm -rf "$_dud_tmp_created_path"
    }
    trap _cleanup_dud_tmp EXIT HUP INT TERM
fi

#!/system/bin/sh
packages_grant_file="/sdcard/hansgisk/grant_permissions.txt"
packages_revoke_file="/sdcard/hansgisk/revoke_permissions.txt"
MODDIR=${0%/*}
while [ "$(getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done
while [ ! -d "/sdcard" ] || [ ! -e /system/bin/pm ]; do
    sleep 3
done
if [ ! -f "$packages_grant_file" ] && [ ! -f "$packages_revoke_file" ]; then
    exit 0
fi
for g_r in $(seq 1 2); do
    echo g_r: "$g_r"
    if [ "$g_r" -eq 1 ]; then
        myfile="$packages_grant_file"
    elif [ "$g_r" -eq 2 ]; then
        myfile="$packages_revoke_file"
    fi
    if [ ! -f "$myfile" ]; then
        continue
    fi
    allpackages="$(cat "$myfile")"
    for packagefilenumber in $(seq 1 $(printf "%s\n" "$allpackages" | wc -l)); do
        mypkg="$(printf "%s\n" "$allpackages" | sed -n "${packagefilenumber}p")"
        if [ "$g_r" -eq 1 ]; then
            allmypermissions="$(/system/bin/dumpsys package "$mypkg" | grep "android\.permission" | grep -v "granted=true" | awk '{$1=$1};1')"
            for propfilenumber in $(seq 1 $(printf "%s\n" "$allmypermissions" | wc -l)); do
                permission="$(printf "%s\n" "$allmypermissions" | sed -n "${propfilenumber}p")"
                permission="$(printf "%s" "$permission" | grep -Eo "android\.permission\.[A-Z0-9_]+")"
                echo grant "$mypkg" "$permission"
                /system/bin/pm grant "$mypkg" "$permission" 2>/dev/null
                if [ $? -ne 0 ]; then
                    newperm="$(printf "%s" "$permission" | sed s/android.permission.//)"
                    /system/bin/appops set "$mypkg" "$newperm" allow
                fi
            done
        elif [ "$g_r" -eq 2 ]; then
            allmypermissions="$(/system/bin/dumpsys package "$mypkg" | grep "android\.permission" | grep -v "granted=false" | awk '{$1=$1};1')"
            for propfilenumber in $(seq 1 $(printf "%s\n" "$allmypermissions" | wc -l)); do
                permission="$(printf "%s\n" "$allmypermissions" | sed -n "${propfilenumber}p")"
                permission="$(printf "%s" "$permission" | grep -Eo "android\.permission\.[A-Z0-9_]+")"
                echo revoke "$mypkg" "$permission"
                /system/bin/pm revoke "$mypkg" "$permission" 2>/dev/null
                if [ $? -ne 0 ]; then
                    newperm="$(printf "%s" "$permission" | sed s/android.permission.//)"
                    /system/bin/appops set "$mypkg" "$newperm" deny
                fi
            done
        fi
    done
done

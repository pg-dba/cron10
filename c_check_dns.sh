((count = 3))                           # Maximum number to try.
while [[ $count -ne 0 ]] ; do
    ping -c 1 ${RELAY}                    # Try once.
    RC=$?
    if [[ $RC -eq 0 ]] ; then
        ((count = 1))                    # If okay, flag loop exit.
    else
        sleep 1                          # Minimise network storm.
    fi
    ((count = count - 1))                # So we don't go forever.
done

if [[ $RC -eq 0 ]] ; then                # Make final determination.
    echo `[ping]  ${RELAY} Server is Ok.`
else
    echo `[ping]  ${RELAY} Server is Bad.`
fi

exit ${RC}

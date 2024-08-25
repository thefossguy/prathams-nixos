{ internetEndpoint ? "google.com", exitCode ? "1", pkgs }:

''
if ! ${pkgs.iputils}/bin/ping -c 2 '${internetEndpoint}'; then
    if ! ${pkgs.iputils}/bin/ping -c 10 '${internetEndpoint}'; then
        if ! ${pkgs.iputils}/bin/ping -c 20 '${internetEndpoint}'; then
            echo 'ERROR: Not connected to the internet.'
            exit ${exitCode}
        fi
    fi
fi
''

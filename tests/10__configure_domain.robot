*** Settings ***
Resource    keywords.resource
Variables   ./vars.py

*** Test Cases ***
Add the module to the cluster
    ${module_id} =    Create a module instance
    Set Global Variable    ${MID1}    ${module_id}

Configure the domain
    [Tags]    create    instance
    Set Global Variable    ${DOMAIN}    ${MID1}.test
    Set Global Variable    ${DOMSUFFIX}    dc=${MID1},dc=test
    ${out}    ${err}     ${rc} =    Execute Command
    ...    api-cli run module/${MID1}/configure-module --data '{"provision":"new-domain","domain":"${DOMAIN}","admuser":"${admuser}","admpass":"${admpass}"}'
    ...    return_rc=True  return_stdout=True  return_stderr=True
    Should Be Equal As Integers    ${rc}  0
    ${val} =     Get server url    ${MID1}
    Set Global Variable    ${SURL}    ${val}
    RootDSE is correct    ${SURL}

The server is reachable after restart
    Execute Command    systemctl stop user@$(id -u ${MID1}) ; systemctl start user@$(id -u ${MID1})
    Wait Until Keyword Succeeds    10s    1s    RootDSE is correct    ${SURL}

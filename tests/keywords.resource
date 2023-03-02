*** Settings ***
Library     SSHLibrary
Resource    api.resource
Variables   vars.py

*** Variables ***
${IMAGE_URL}    https://ghcr.io/nethserver/openldap:latest
${DOMSUFFIX}    dc\=x,dc\=y
${MID1}         unknown00
${DOMSUFFIX}    dc\=x,dc\=y
${DOMAIN}       dom.test
${SURL}         ldap://

*** Keywords ***
Create a module instance
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    [Return]  ${output.module_id}

Remove a module instance
    [Arguments]    ${module_id}
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=${TRUE}  return_stdout=${FALSE}
    Should Be Equal As Integers    ${rc}  0

Get server url
    [Arguments]    ${mid}
    ${out} =    Execute Command    runagent redis-exec HGETALL module/${mid}/srv/tcp/ldap
    &{srv} =    Evaluate    ${out}
    [Return]    ldap://${srv.host}:${srv.port}

Get ldapservice credentials
    [Arguments]    ${mid}
    ${out} =    Execute Command    runagent redis-exec HGETALL module/${mid}/srv/tcp/ldap
    &{srv} =    Evaluate    ${out}
    [Return]    ${srv.bind_dn}    ${srv.bind_password}

RootDSE is correct
    [Arguments]    ${SURL}
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapsearch -LLL -x -D '' -w '' -H ${SURL} -b '' -s base namingContexts
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Contain    ${out}    namingContexts: ${DOMSUFFIX}    ignore_case=${TRUE}

Start the client tool container
    Execute Command    podman run --rm --replace --detach --network host --name ldapclient alpine sh -c 'sleep 100000' ; podman exec -i ldapclient apk add openldap-clients

Stop the client tool container
    Execute Command    podman kill ldapclient


*** Settings ***
Library           SSHLibrary
Library           DateTime
Resource    keywords.resource
Suite Setup       Setup connection and test suite tools
Suite Teardown    Tear down connection and test suite tools

*** Variables ***
${SSH_KEYFILE}    %{HOME}/.ssh/id_ecdsa
${NODE_ADDR}      127.0.0.1

*** Keywords ***
Connect to the node
    Log    connecting to ${NODE_ADDR}
    Open Connection   ${NODE_ADDR}
    Login With Public Key    root    ${SSH_KEYFILE}
    ${output} =    Execute Command    systemctl is-system-running  --wait
    Should Be True    '${output}' == 'running' or '${output}' == 'degraded'

Setup connection and test suite tools
    Connect to the node
    Save the journal begin timestamp
    Start the client tool container

Tear down connection and test suite tools
    Stop the client tool container
    Collect the suite journal

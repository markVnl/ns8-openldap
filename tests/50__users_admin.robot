*** Settings ***
Library         SSHLibrary
Resource        keywords.resource

Suite Setup     Add test user
Suite Teardown  Remove test user

*** Variables ***
${TOKEN}    missing

*** Keywords ***
Add test user
    Run task    module/${MID1}/add-user    {"user":"u1","groups":[],"display_name":"User One","password":"Nethesis,1234"}

Remove test user
    Run task    module/${MID1}/remove-user    {"user":"u1"}

*** Test Cases ***
User portal requires HTTPS
    ${output}  ${error}  ${rc} =  Execute Command    curl -I http://127.0.0.1/users-admin/${DOMAIN}/    return_rc=1  return_stderr=True
    Should Contain    ${output}    Location: https://
    Should Be Equal As Integers    ${rc}    0

User portal has expected homepage
    ${output}  ${error}  ${rc} =  Execute Command    curl -k -L http://127.0.0.1/users-admin/${DOMAIN}/    return_rc=1  return_stderr=True
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    <div id=\"app\">

Denied access with bad token
    ${output}  ${error}  ${rc} =  Execute Command    curl -H "Authorization: Bearer ${TOKEN}" -H 'Content-type: application/json' --data '{}' -k https://127.0.0.1/users-admin/${DOMAIN}/api/logout    return_rc=1  return_stderr=True
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    "code":401

User can login and obtain a token
    ${token}  ${error}  ${rc} =  Execute Command    curl -H 'Content-type: application/json' --data '{"username":"u1","password":"Nethesis,1234"}' -k https://127.0.0.1/users-admin/${DOMAIN}/api/login | jq -r .token    return_rc=1  return_stderr=True
    Should Be Equal As Integers    ${rc}    0
    Should Not Be Empty    ${token}
    Set Suite Variable    ${TOKEN}    ${token}

Allowed access with valid token
    ${output}  ${error}  ${rc} =  Execute Command    curl -v -H "Authorization: Bearer ${TOKEN}" -H 'Content-type: application/json' --data '{}' -k https://127.0.0.1/users-admin/${DOMAIN}/api/logout    return_rc=1  return_stderr=True
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    "code":200

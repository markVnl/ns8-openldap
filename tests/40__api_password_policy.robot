*** Settings ***
Resource        keywords.resource

Suite Setup     Add test user
Suite Teardown  Remove test user

*** Keywords ***
Add test user
    Run task    module/${MID1}/add-user    {"user":"pu1","groups":[],"display_name":"User ppolicy One","password":"Nethesis,1234"}

Remove test user
    Run task    module/${MID1}/remove-user    {"user":"pu1"}

*** Test Cases ***
Reject simple password with default password policy
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"nethesis"}    rc_expected=1

Accept strong password with default password policy
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"Nethesis,4321"}    rc_expected=0

Switch to simple password policy
    Run task    module/${MID1}/set-password-policy
    ...    {"expiration":{"enforced":true,"min_age":0,"max_age":180},"strength": {"enforced":false,"history_length":5,"password_min_length":8,"complexity_check":true}}

Accept simple password with simple password policy
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"nethesis"}    rc_expected=0

Switch to strong password policy
    Run task    module/${MID1}/set-password-policy
    ...    {"expiration":{"enforced":true,"min_age":0,"max_age":180},"strength": {"enforced":true,"history_length":5,"password_min_length":8,"complexity_check":true}}

Accept the old strong password
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"Nethesis,4321"}    rc_expected=0

Accept another strong password
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"1234,Nethesis"}    rc_expected=0

Reject password in history with strong password policy
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"Nethesis,4321"}    rc_expected=1

Reject short password with strong password policy
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"Net1"}    rc_expected=1

Reject the same password with strong password policy
    Run task    module/${MID1}/alter-user    {"user":"pu1","password":"1234,Nethesis"}    rc_expected=1

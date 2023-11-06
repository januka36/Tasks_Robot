*** Settings ***

Library       RequestsLibrary
Library        JSONLibrary
Library         Collections
Library         OperatingSystem
Library    RPA.Tasks    

*** Variables ***

${API_ROOT}     https://uluru-01-pdhwkxq43q-ue.a.run.app/jsonrpc
${RequestData}   {"jsonrpc": "2.0+hl","id": 1,"method": "cdr:bme:add","version": 1,"params": {"activity_tags": ["food_bank"],"region_id": "645a83679d23265bd3e550a2","name": "Test Data 1234","address": "339 Barton St, Stoney Creek, ON L8E 2L2","geoloc": {"longitude": -79.721363,"latitude": 43.8561002}},"auth": {"type": "hl_session","token": "4689f08c3819861647fa8653f19c0a4ac4234b940f12d26e3836609af96a3f780b32e80f58bd853c3535c03c581ad76e2629a0a6ebf8673e73cf3757314f47d26ba5ff3d579d4612abe3a64e8429c338d11c92c6d32ad6f8403efe8f4fb9f6ea91ec96546e4269fe01d58d377873bde170abf89a9b6edc13287f16b96715f673"}}

*** Tasks ***
Add_BME
    [Documentation]    Send an API request to add a new region.
    [Tags]    API, Region
    Given the API endpoint for adding a region is available        
    ${response_data}=     When a POST request is sent to the API endpoint with BME data  
    And the response should contain the added BME details

*** Keywords ***

Given the API endpoint for adding a region is available
    ${API_Endpoint}=     Set Variable    ${API_ROOT}
    ${API_Endpoint}=     Set Suite Variable    ${API_Endpoint}
    # Define the API endpoint for adding a region, set authentication, etc.

When a POST request is sent to the API endpoint with BME data
    Create Session    API_Testing   ${API_ROOT}
    ${region_data}=     Set Variable       ${RequestData}
    ${Headers}=         Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session  API_Testing     ${API_Endpoint}      data=${region_data}     headers=${Headers}
    ${Get_Response_Content}=      Set Variable    ${response.content} 
    ${json_dict}=    Evaluate    json.loads('''${Get_Response_Content}''')    json
    Log To Console     ${json_dict}
    Set Suite Variable     ${response_data}    ${json_dict}
    [Return]    ${json_dict}   


And the response should contain the added BME details
    ${result}=    Get From Dictionary    ${response_data}    result
    Log To Console    ${result}
    Dictionary Should Contain Key    ${result}    _id
    Dictionary Should Contain Key    ${result}    name
    Dictionary Should Contain Key    ${result}    address
    Dictionary Should Contain Key    ${result}    activity_tags

    ${tags}=     Get From Dictionary     ${result}    activity_tags
    ${is_list}=    Evaluate    isinstance($tags, list)
    Should Be True    ${is_list}    msg=Variable is not a list

    ${geoloc}=    Get From Dictionary     ${result}    geoloc
    Dictionary Should Contain Key    ${geoloc}    longitude
    Dictionary Should Contain Key    ${geoloc}    latitude

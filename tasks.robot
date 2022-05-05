*** Settings ***
Documentation     Robot Spare Bin Excersice.
...               Reads csv file and orders robots according it in https://robotsparebinindustries.com/.

Library    RPA.Browser
Library    RPA.HTTP
Library    RPA.Tables

Suite Setup        Open Available Browser    https://robotsparebinindustries.com/
Suite Teardown     Close All Browsers

*** Variables ***  
${ORDERS_FILE_URL}            https://robotsparebinindustries.com/orders.csv
${ORDERS_FILE_LOCAL_PATH}     data_files/orders.csv


*** Tasks ***
Build and order robots
    [Documentation]     Builds and orders robots

    Get orders
    Order robots

*** Keywords ***
Get orders    
    Get file from server    ${ORDERS_FILE_URL}   ${ORDERS_FILE_LOCAL_PATH}

Order robots

    ${orders_table}=     Read orders file
    Order one robot      ${orders_table}      0

Order one robot
    [Arguments]    ${orders_table}     ${order_number}

    ${order_number}=      Get order number     ${orders_table}     ${order_number}
    ${head}=              Get head             ${orders_table}     ${order_number}
    ${body}=              Get body             ${orders_table}     ${order_number}
    ${legs}=              Get legs             ${orders_table}     ${order_number}
    ${address}=           Get address          ${orders_table}     ${order_number}

    Log To Console    Order robot for order number: ${order_number}

    Open order your robot tab

    Select Head     ${head}

Open order your robot tab
    Click Element When Visible    //*[@href='#/robot-order']   
    # Allert ok
    Click Button When Visible   //*[@type='button' and text()='OK']

Get file from server
    [Arguments]    ${server_address}=${ORDERS_FILE_URL}    ${destination_path}=${ORDERS_FILE_LOCAL_PATH}

    Download    ${server_address}    target_file=${destination_path}    overwrite=true    

Read orders file
    [Arguments]     ${destination_path}=${ORDERS_FILE_LOCAL_PATH}

    ${table}=    Read table from CSV     ${destination_path}
    Log To Console    ${table}

    [Return]  ${table}

Get order number 
    [Arguments]    ${table}   ${row}

    ${order_number}=    RPA.Tables.Get table cell     ${table}    ${row}     Order number
    Log To Console    Order number: ${order_number}

    [Return]     ${order_number}


Get head 
    [Arguments]    ${table}   ${row}

    ${head}=    RPA.Tables.Get table cell     ${table}    ${row}     Head
    Log To Console    Head: ${head}

    [Return]     ${head}    

Get body 
    [Arguments]    ${table}   ${row}

    ${body}=    RPA.Tables.Get table cell     ${table}    ${row}     Body
    Log To Console    Body: ${body}

    [Return]     ${body}   

Get legs 
    [Arguments]    ${table}   ${row}

    ${legs}=    RPA.Tables.Get table cell     ${table}    ${row}     Legs
    Log To Console    Legs: ${legs}

    [Return]     ${legs}   

 Get address 
    [Arguments]    ${table}   ${row}

    ${address}=    RPA.Tables.Get table cell     ${table}    ${row}     Address
    Log To Console    Address: ${address}

    [Return]     ${address}      

Select head
    [Arguments]     ${item_nbr}
    Log To Console    Order head: ${item_nbr}

    Select From List By Value      id:head   ${item_nbr}
    Screenshot
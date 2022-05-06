*** Settings ***
Documentation     Robot Spare Bin Excersice.
...               Reads csv file and orders robots according it in https://robotsparebinindustries.com/.

Library    RPA.Browser
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive

#Suite Setup        Open Available Browser    https://robotsparebinindustries.com/
Suite Teardown     Close All Browsers

*** Variables ***  
${ORDERS_FILE_URL}            https://robotsparebinindustries.com/orders.csv
${ORDERS_FILE_LOCAL_PATH}     data_files/orders.csv

${SCREENSHOTS_PATH}           ${OUTPUT_DIR}${/}screenshots
${RECEIPTS_PATH}              ${OUTPUT_DIR}${/}receipts

${RETRY_TIMES_SERVE_ERROR}        5 times
${RETRY_INTERVAL_SERVE_ERROR}     1 s


*** Tasks ***
#Build and order robots
#    [Documentation]     Builds and orders robots
#    Open the robot order website
#    Get orders
#    Order robots


Order robots from RobotSpareBin Industries Inc
    Set Screenshot Directory    ${SCREENSHOTS_PATH}

    Open the robot order website

    ${orders_table}=    Get orders
   
    FOR    ${row}    IN    @{orders_table}
        Close the annoying modal
        Fill the form    ${row} 
        Preview the robot
        Submit the order
        Check the order      ${row}
        ${pdf}=           Store the receipt as a PDF file   ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts    

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/
    Open order your robot tab
Get orders    
    Get file from server    ${ORDERS_FILE_URL}   ${ORDERS_FILE_LOCAL_PATH}
    ${orders_table}=     Read orders file

    [Return]     ${orders_table}

Close the annoying modal
    # Allert ok
    Click Button When Visible   //*[@type='button' and text()='OK']

Fill the form
    [Arguments]    ${orders_row}

    Log To Console    Fill the robot form for the order number: ${orders_row}[Order number]

    #select body parts
    Select head        ${orders_row}[Head]
    Select body        ${orders_row}[Body]
    Select legs        ${orders_row}[Legs]
    Select address     ${orders_row}[Address]    

Preview the robot
    Click Button When Visible    id:preview

Submit the order   
    Log To Console    Submit order 
    Wait Until Keyword Succeeds    ${RETRY_TIMES_SERVE_ERROR}    ${RETRY_INTERVAL_SERVE_ERROR}     Submit order and get receipt

Submit order and get receipt
    Click Button When Visible        id:order
    Wait Until Element Is Visible    id:receipt

Check the order
    [Arguments]    ${orders_row}

    Wait Until Element Is Visible    id:receipt

    Log To Console    Check the receipt for the order number: ${orders_row}[Order number]

    Element Should Contain     id:parts     Head: ${orders_row}[Head]
    Element Should Contain     id:parts     Body: ${orders_row}[Body]
    Element Should Contain     id:parts     Legs: ${orders_row}[Legs]

Store the receipt as a PDF file
    [Arguments]        ${order_nbr}
    
    ${robot_pdf_path}=     Set Variable    ${RECEIPTS_PATH}${/}receipt-${order_nbr}.pdf

    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${robot_pdf_path}

    [Return]    ${robot_pdf_path}
Take a screenshot of the robot
    [Arguments]        ${order_nbr}

    ${robot_image_path}=     Set Variable   ${SCREENSHOTS_PATH}${/}robot-${order_nbr}.jpg

    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot     id:robot-preview-image      ${robot_image_path}

    [Return]    ${robot_image_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${Screenshot_path}     ${PDF_path}

    Add Watermark Image To PDF
    ...             image_path=${Screenshot_path}
    ...             source_path=${PDF_path}
    ...             output_path=${PDF_path}

Create a ZIP file of the receipts

    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/robot-receipt-PDFs.zip
    Archive Folder With Zip
    ...    ${RECEIPTS_PATH}
    ...    ${zip_file_name}


Go to order another robot
    Click Button When Visible    id:order-another

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

    #select body parts
    Select head        ${head}
    Select body        ${body}
    Select legs        ${legs}
    Select address     ${address}

    Click Button When Visible    id:order

Open order your robot tab
    Click Element When Visible    //*[@href='#/robot-order']   

Get file from server
    [Arguments]    ${server_address}=${ORDERS_FILE_URL}    ${destination_path}=${ORDERS_FILE_LOCAL_PATH}

    Download    ${server_address}    target_file=${destination_path}    overwrite=true    

Read orders file
    [Arguments]     ${destination_path}=${ORDERS_FILE_LOCAL_PATH}

    ${table}=    Read table from CSV     ${destination_path}
    Log To Console    ${table}

    FOR    ${row}    IN    @{table}
        Log to console    order nbr: ${row}[Order number]
    END

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
    Log To Console    Selected head: ${item_nbr}

    Select From List By Value      id:head   ${item_nbr}

Select body
    [Arguments]     ${item_nbr}
    Log To Console    Selected body: ${item_nbr}

    Select Radio Button     body   ${item_nbr}

Select legs
    [Arguments]     ${item_nbr}
    Log To Console    Selected legs: ${item_nbr}

    Input Text     //*[@placeholder='Enter the part number for the legs']   ${item_nbr}      

Select address
    [Arguments]     ${item_nbr}
    Log To Console    Selected address: ${item_nbr}

    Input Text     id:address   ${item_nbr}
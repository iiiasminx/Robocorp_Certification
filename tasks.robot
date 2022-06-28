*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open Website Menu
    Download CSV file
    #[Teardown]    Close


*** Keywords ***
Open Website Menu
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    Fill Form Using CSV Data

Fill Form Using CSV Data
    ${table}=    Read table from CSV    orders.csv
    Log    Found columns: ${table.columns}

    FOR    ${element}    IN    @{table}
        Log    ${element}
        Accept World Domination Form
        Fill the Form    ${element}
        Submit the Order
        Store in PDF    ${element}
        Order another Robot
    END

Accept World Domination Form
    Wait Until Page Contains Element    css:div.modal-dialog
    Click Button    OK

Fill the Form
    [Arguments]    ${fila}

    # head
    Select From List By Value    head    ${fila}[Head]
    #body
    RPA.Browser.Selenium.Select Radio Button    body    ${fila}[Body]
    #legs
    Input Text    css:input.form-control    ${fila}[Legs]
    #adress
    Input Text    address    ${fila}[Address]
    #click finish
    Click Button    preview

Submit the Order
    Wait Until Keyword Succeeds    20x    0.5 sec    Submit

Submit
    Click Button    order
    Wait Until Element Is Visible    id:receipt

Store in PDF
    [Arguments]    ${fila}
    Wait Until Element Is Visible    id:receipt
    ${order_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_html}    ${OUTPUT_DIR}${/}Order${fila}[Order number].pdf

    ${screenshot}=    Capture Element Screenshot
    ...    id:robot-preview-image
    ...    ${OUTPUT_DIR}${/}Order${fila}[Order number].png

    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}Order${fila}[Order number].png

    Add Files To Pdf
    ...    ${files}
    ...    ${OUTPUT_DIR}${/}Order${fila}[Order number].pdf
    ...    True

Take Robot Photo

Embed Photo to PDF

Order another Robot
    Click Button    id:order-another

Close
    Close Browser

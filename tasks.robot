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
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.FileSystem
Library             RPA.Robocorp.Vault


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open Website Menu
    Input and CSV download
    Archive to ZIP
    [Teardown]    Close


*** Keywords ***
Open Website Menu
    ${secret}=    Get Secret    CertificationII
    Open Available Browser    ${secret}[RoboLink]
    # https://robotsparebinindustries.com/#/robot-order

Download CSV file
    [Arguments]    ${link}

    #https://robotsparebinindustries.com/orders.csv
    Download    ${link}    overwrite=True
    Fill Form Using CSV Data

Input and CSV download
    Add heading    Where should we download the csv from?
    Add text input
    ...    link
    ...    label=link
    ...    placeholder=Link para el csv
    ...    rows=1
    ${result}=    Run dialog
    Log    ${result}
    Download CSV file    ${result.link}

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
    Html To Pdf    ${order_html}    ${OUTPUT_DIR}${/}Order${/}Order${fila}[Order number].pdf

    ${screenshot}=    Capture Element Screenshot
    ...    id:robot-preview-image
    ...    ${OUTPUT_DIR}${/}Order${/}Order${fila}[Order number].png

    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}Order${/}Order${fila}[Order number].png

    Add Files To Pdf
    ...    ${files}
    ...    ${OUTPUT_DIR}${/}Order${/}Order${fila}[Order number].pdf
    ...    True

    Remove File    ${OUTPUT_DIR}${/}Order${/}Order${fila}[Order number].png

Order another Robot
    Click Button    id:order-another

Archive to ZIP
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Order    ${zip_file_name}

Close
    Close Browser

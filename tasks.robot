*** Settings ***
Documentation       Template robot main suite.

Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.Browser.Selenium
Library             RPA.PDF
Library             Dialogs
Library             Telnet
Library             RPA.Archive
Library             RPA.Robocorp.Process
Library             RPA.FileSystem


*** Tasks ***
Order all the robots
    ${csv}=    Get CSV
    Open Chrome Browser    http://www.google.com
    Create Directory    pdfs/
    Create Directory    pics/

    FOR    ${rob}    IN    @{csv}
        Log    ${rob}
        Wait Until Keyword Succeeds
        ...    5x
        ...    1s
        ...    Order robot    ${rob}
    END
    Archive Folder With Zip    pdfs/    output/receipts.zip

    [Teardown]    Close Browser


*** Keywords ***
Get CSV
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${csv}=    Read table from CSV    orders.csv
    RETURN    ${csv}

Order Robot
    [Arguments]    ${robot}
    Log    ${robot}
    Open new Tab
    Fill Info    ${robot}
    Get Robot Picture    ${robot}
    Create PDF    ${robot}
    [Teardown]    Close Tab

Fill Info
    [Arguments]    ${robot}
    Click Element    css:.btn-dark
    Wait Until Element Is Visible    id:head
    Select From List By Value    id:head    ${robot}[Head]
    Click Element    id:id-body-${robot}[Body]
    Input Text    //html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${robot}[Legs]
    Input Text    id:address    ${robot}[Address]

Get Robot Picture
    [Arguments]    ${robot}
    Click Element    id:preview
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]/img[1]
    Screenshot    xpath://*[@id="robot-preview-image"]    pics/${robot}[Order number].jpg

Create PDF
    [Arguments]    ${robot}
    Wait Until Element Is Visible    id:order
    Sleep    0.5
    Click Element    id:order
    ${html}=    Get Element Attribute    id:receipt    outerHTML
    ${html}=    Catenate    ${html}    <img src="pics/${robot}[Order number].jpg">
    Log    ${html}
    Html To Pdf    ${html}    pdfs/${robot}[Order number].pdf

Open new Tab
    Execute Javascript    window.open('')
    Get Window Titles
    Switch Window    title=undefined
    Go To    https://robotsparebinindustries.com/#/robot-order

Close Tab
    Execute Javascript    window.close()
    Switch Window    title=Google

# Valheim-Config-Editor
A UI for editing Valheim mod config files

Valheum Config Editor loads Valheim mod .cfg ini files into a UI allowing you to edi the file in a organized tree view with support for description text. The editor has a search bar with dynamic content and the ability to update a new config file with an old file's values. The editor automatically saves updates when the UI is closed. 

The source .ahk and a pre-compiled .exe are provided. If the device does not have AutoHotKey installed only the .exe will work. 

How To: 

 * Load A File
    To load a file into the UI press the "Select File" button then select the file. 

 * Search For A Setting
    Begin typing in the search bar and the tree view and result count will update as while typing. 
    
 * Update A Setting
    To edit a setting first expand one of the sections using the "+" symbolt to the left. Select the desired setting and then edit the value in the bottom edit       box. 
 
 * Merge Files
    Select the "Merge Files" button, select the file holding the current setting data then select the file which should receive this data. 
 
 More Info:
 
    The top text box show the current file loaded into the editor, this can be changed using the button to the right. The center scroll box contains the currently loaded file as a tree view. The top items in the hierarchy represent the different sections of a config file. Once expanded these items expose the configuration settings for their section. The search bar above the tree view allows the tree view to be narrowed down. The search text is matched with the individual setting text and not the section text. To the right of the tree view any description text accompanying the currently selected setting is displayed. The currently selected setting's name is displayed below the tree view along with an edit box for updating the setting's value. Any changes to the value in this box (even just clicking on the value) will cause this setting to be queued for saving. The last setting queued for saving along with the time it was queued (HH:MM (ss)) is shown in the lower status bar. When the UI is closed all of the queued changes are saved to the config file. Finally, old config file data can be updated to a new config file using the Merge Files button. The first file prompted for is the old file with the data while the second file is the new file receiving the data. Once the merge is completed the new file is loaded into the tree view. 

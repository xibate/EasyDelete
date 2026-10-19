local _, ns = ...

--The addon's texts. Buttons like Delete, Cancel, Yes and No use the game's own translations
ns.L = {
    title = "Delete this item?",
    hint = "Enter deletes, Esc keeps it",
    questWarning = "Deleting it also abandons the quest it belongs to.",
    previewItem = "Thunderfury, Blessed Blade of the Windseeker",
    combat = "Combat started, so the item went back. Delete it again after the fight.",
    usingDialog = "Easy Delete uses its own delete dialog.",
    usingClassic = "Easy Delete uses the game's delete popup, without having to type DELETE.",
    help = "/easydelete: options. /easydelete preview: show the dialog without deleting anything. /easydelete dialog or classic: pick the style.",

    welcome = "Welcome! How should deleting items look?",
    options = "How deleting items looks",
    chooseText = "Click a style to use it, and Preview to see it first. Nothing is deleted by a preview.",
    settingsHint = "Change it any time in Options > AddOns > Easy Delete, or with /easydelete.",
    done = "Done",
    preview = "Preview",
    styleSection = "Delete dialog",
    dialogTitle = "Easy Delete dialog",
    dialogText = "A clean dialog with the item's icon, quality and stack size. Delete or Enter deletes.",
    classicTitle = "Game's popup",
    classicText = "Blizzard's own popup, without having to type DELETE. Just click Yes.",
    commands = "Type /easydelete to open these options anywhere, or /easydelete preview to see the dialog.",
    otherAddon = "Another addon also fills in the delete popup. Easy Delete takes care of it, so you can turn that addon's delete option off."
}

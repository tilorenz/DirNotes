### DISCLAIMER: This is still in development. It somewhat works but is very much unpolished and probably buggy. Use at your own risk.

# DirNotes
A sticky notes widget for the [KDE Plasma desktop](https://kde.org/plasma-desktop/).

### Features:
- A directory tree view
- Notes are saved as plain text (vs HTML), so they can easily be used with other programs, eg. synced to your Nextcloud notes

### Installation:
- `git clone https://github.com/tilorenz/DirNotes.git`
- `cd DirNotes`
- `mkdir build && cd build`
- `cmake -S .. -B . && cmake --build . && sudo cmake --install .`
- `kpackagetool5 -i ../package/ -t Plasma/Applet`

### TODO (roughly ordered by priority):
- Fix the polish loop when toggling the dir tree in expanded state
- give items in dir tree context menu
	- replacing the "new note" and "open in file manager" buttons
- autosave to new file when user typed without selecting a file before
- Markdown Highlighting
- vim-style navigation (using Alt+hjklweb)
- pin button
- i18n

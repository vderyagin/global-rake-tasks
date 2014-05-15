# List of tasks: #

```
rake cleanup:cruft                   # Get rid of some trash in home directory
rake emacs:delete_persisted_session  # Delete all session persistance files
rake emacs:find_cruft                # locate stale and orphaned bytecode im  ~/.emacs.d directory
rake emacs:find_orphan_bytecode      # Find elisp bytecode files lacking source in ~/.emacs.d directory
rake emacs:find_stale_bytecode       # Find stale elisp bytecode in ~/.emacs.d directory
rake emacs:recompile_configs         # Recompile all emacs configuration files
rake emacs:regenerate_autoloads      # Regenerate all el-get autoloads
rake encfs:mount                     # Mount encrypted directory
rake encfs:status                    # Tell whether encrypted filesystem is mounted
rake encfs:umount                    # Unmount encrypted directory
rake gists                           # clone my public gists
rake lock_screen                     # Lock current display using alock(1)
rake privoxy:disable                 # Disable privoxy
rake privoxy:enable                  # Enable privoxy
rake share_screenshot                # Take screenshot, share it on dropbox.com and put url in clipboard
rake sqlite_vacuum                   # VACUUM all the sqlite database files used by firefox and thunderbird
rake wp:active                       # Set last used wallpaper on current display using feh(1)
rake wp:random                       # Set random wallpater on current display using feh(1)
rake wp:rename                       # Randomly rename all wallpapers
```

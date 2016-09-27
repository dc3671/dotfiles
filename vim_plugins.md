## NERDTree

NERDTree is a file explorer plugin that provides "project drawer" functionality to your vim editing. You can learn more about it with :help NERDTree.

*QuickStart* Launch using <Leader>e.

Customizations:

Use <C-E> to toggle NERDTree
Use <leader>e or <leader>nt to load NERDTreeFind which opens NERDTree where the current file is located.
Hide clutter ('.pyc', '.git', '.hg', '.svn', '.bzr')
Treat NERDTree more like a panel than a split.

## ctrlp

Ctrlp replaces the Command-T plugin with a 100% viml plugin. It provides an intuitive and fast mechanism to load files from the file system (with regex and fuzzy find), from open buffers, and from recently used files.

*QuickStart* Launch using <c-p>.

Once CtrlP is open:

Press <F5> to purge the cache for the current directory to get new files, remove deleted files and apply new ignore options.
Press <c-f> and <c-b> to cycle between modes.
Press <c-d> to switch to filename only search instead of full path.
Press <c-r> to switch to regexp mode.
Use <c-j>, <c-k> or the arrow keys to navigate the result list.
Use <c-t> or <c-v>, <c-x> to open the selected entry in a new tab or in a new split.
Use <c-n>, <c-p> to select the next/previous string in the prompt's history.
Use <c-y> to create a new file and its parent directories.
Use <c-z> to mark/unmark multiple files and <c-o> to open them.
Run :help ctrlp-mappings or submit ? in CtrlP for more mapping help.

## Surround

This plugin is a tool for dealing with pairs of "surroundings." Examples of surroundings include parentheses, quotes, and HTML tags. They are closely related to what Vim refers to as text-objects. Provided are mappings to allow for removing, changing, and adding surroundings.

Details follow on the exact semantics, but first, consider the following examples. An asterisk (\*) is used to denote the cursor position.

```
  Old text                  Command     New text ~
  "Hello *world!"           ds"         Hello world!
  [123+4*56]/2              cs])        (123+456)/2
  "Look ma, I'm *HTML!"     cs"<q>      <q>Look ma, I'm HTML!</q>
  my $str = *whee!;         vllllS'     my $str = 'whee!';
  if *x>3 {                 ysW(        if ( x>3 ) {  
  (use } instead of { for no space)
```

The letters w, W, and s correspond to a |word|, a |WORD|, and a |sentence|

For instance, if the cursor was inside "foo bar", you could type cs"' to convert the text to 'foo bar'.

There's a lot more, check it out at :help surround

## NERDCommenter

NERDCommenter allows you to wrangle your code comments, regardless of filetype. View help :NERDCommenter or checkout my post on NERDCommenter.

*QuickStart* Toggle comments using <Leader>c<space> in Visual or Normal mode.

Default <Leader> is ","

## Fugitive

Fugitive adds pervasive git support to git directories in vim. For more information, use :help fugitive

Use :Gstatus to view git status and type - on any file to stage or unstage it. Type p on a file to enter git add -p and stage specific hunks in the file.

Use :Gdiff on an open file to see what changes have been made to that file

*QuickStart* <leader>gs to bring up git status

Customizations:

<leader>gs :Gstatus
<leader>gd :Gdiff
<leader>gc :Gcommit
<leader>gb :Gblame
<leader>gl :Glog
<leader>gp :Git push
<leader>gw :Gwrite
:Git will pass anything along to git.

## Tagbar

spf13-vim includes the Tagbar plugin. This plugin requires exuberant-ctags and will automatically generate tags for your open files. It also provides a panel to navigate easily via tags

spf13-vim binds <Leader>tt to toggle the tagbar panel

Tip: Check out :help ctags for information about VIM's built-in ctag support. Tag navigation creates a stack which can traversed via *Ctrl-]* (to find the source of a token) and *Ctrl-T* (to jump back up one level).

## EasyMotion

EasyMotion provides an interactive way to use motions in Vim.

It quickly maps each possible jump destination to a key allowing very fast and straightforward movement.

*QuickStart* EasyMotion is triggered using the normal movements, but prefixing them with <leader><leader>. eg: `,,w/,,b`


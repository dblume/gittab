if exists("g:loaded_gittab") || &cp | finish | endif
let g:loaded_gittab = 1

"A helper function that tries to show a buffer if it already exists
function! s:ShowBufInNewTab(bufname)
   let l:bnr = bufnr(a:bufname)
   if l:bnr > 0
       tabnew
       exec 'buffer ' . l:bnr
       return 1
   endif
   return 0
endfunction

"A helper function that tries to show a buffer if it already exists
function! s:ShowBufInNewSplit(bufname)
   let l:bnr = bufnr(a:bufname)
   if l:bnr > 0
"       bo vne
       vne
       exec 'buffer ' . l:bnr
       return 1
   endif
   return 0
endfunction

function! s:GitBlame(...)
    let l:hash = expand('<cword>')
    let l:currentView = winsaveview()
    let l:args = a:1
    if strlen(l:args)
        " Add a space to the end
        let l:args = l:args . " "
    endif
    " If in a Blame window already, do blame for some prior commit
    if l:hash =~ '^[0-9a-f]\{7,40}$' && stridx(expand('%'), ' -- ') != -1
        let l:fname = split(expand('%'), ' -- ')[-1]
        let l:bufname = 'git blame ' . l:args . l:hash . '^ -- ' . l:fname
        if !s:ShowBufInNewTab(l:bufname)
            exec 'tabnew | r! git blame ' . l:args . l:hash . '^ -- ' . shellescape(l:fname)
            exec 'silent :file ' . fnameescape(l:bufname)
        endif
    else
        let l:fname = expand('%')
        let l:hash = ''
        " Show fnames will have ':' in them.
        if stridx(l:fname, ':') != -1
            let l:fname_parts = split(l:fname, ':')
            let l:fname = l:fname_parts[-1]
            let l:hash = split(l:fname_parts[0], ' ')[-1]
        endif
        if strlen(l:hash)
            let l:bufname = 'git blame ' . l:args . l:hash . ' -- ' . l:fname
            if !s:ShowBufInNewTab(l:bufname)
                exec 'tabnew | r! git blame ' . l:args . l:hash . ' -- ' . shellescape(l:fname)
                exec 'silent :file ' . fnameescape(l:bufname)
            endif
        else
            let l:bufname = 'git blame ' . l:args . '-- ' . l:fname
            if !s:ShowBufInNewTab(l:bufname)
                exec 'tabnew | r! git blame ' . l:args . '-- ' . shellescape(l:fname)
                exec 'silent :file ' . fnameescape(l:bufname)
            endif
        endif
    endif
    0d_
    call winrestview(l:currentView)
    setl buftype=nofile
endfunction
command -nargs=* Blame :call s:GitBlame(<q-args>)

function! s:GitShow(commit_or_file, ...)
    let l:fname = expand('%')
    let l:hash = expand('<cword>')
    if l:hash =~ '^[0-9a-f]\{7,40}$'
        if stridx(l:fname, ' -- ') != -1
            let l:fname = split(l:fname, ' -- ')[-1]
        endif
        let l:args = a:1
        if strlen(l:args)
            " Add a space to the end
            let l:args = l:args . " "
        endif
        if a:commit_or_file != "file"
            let l:bufname = 'git show ' . l:args . l:hash . ' -- ' . l:fname
            if !s:ShowBufInNewTab(l:bufname)
                " Have Show show all the affected files, so don't actually use  "--"
                " exec 'tabnew | r! git show ' . l:hash . ' -- ' . shellescape(l:fname)
                exec 'tabnew | r! git show ' . l:args . l:hash
                " We lie here (' -- ') to have a filename the other git commands can use.
                exec 'silent :file ' . fnameescape(l:bufname)
            endif
            0d_
        else
            let l:currentView = winsaveview()
            let l:bufname = 'git show ' . l:args . l:hash . ':' . l:fname
            if !s:ShowBufInNewTab(l:bufname)
                exec 'tabnew | r! git show ' . l:args. l:hash . ':' . shellescape(l:fname)
                exec 'silent :file ' . fnameescape(l:bufname)
            endif
            0d_
            call winrestview(l:currentView)
        endif
        setl buftype=nofile
    else
        echo l:hash . ' is not a git hash.'
    endif
endfunction
command -nargs=* Show :call s:GitShow("commit", <q-args>)
command -nargs=* ShowFile :call s:GitShow("file", <q-args>)

function! s:GitDiff()
    let l:fname = expand('%:.')
    let l:buf = winbufnr(0)
    let l:commit = 'HEAD'
    let l:hash = expand('<cword>')
    let l:currentView = winsaveview()

    " If the current word is a hash, then diff that vs. previous
    if l:hash =~ '^[0-9a-f]\{7,40}$' && stridx(expand('%'), ' -- ') != -1
        let l:fname = split(expand('%'), ' -- ')[-1]
        let l:bufname = 'git show ' . l:hash . '^:' . l:fname
        if !s:ShowBufInNewTab(l:bufname)
            exec ':tabnew | silent r! git show ' . l:hash . '^:$(git rev-parse --show-prefix)' . shellescape(l:fname)
            setl buftype=nofile
            0d_
            exec 'silent :file ' . fnameescape(l:bufname)
        endif

        let l:bufname = 'git show ' . l:hash . ':' . l:fname
        if !s:ShowBufInNewSplit(l:bufname)
            exec 'vne | silent r! git show ' . l:hash . ':$(git rev-parse --show-prefix)' . shellescape(l:fname)
            setl buftype=nofile
            exec 'silent :file ' . fnameescape(l:bufname)
            0d_
        endif
    elseif stridx(expand('%'), ':') != -1
        " If we're in a 'git show' buffer, then extract fname and hash from there
        let l:fname_parts = split(l:fname, ':')
        let l:fname = l:fname_parts[-1]
        let l:hash = split(l:fname_parts[0], ' ')[-1]
        " TODO: Below few lines are identical to above, so remove dupes.
        let l:bufname = 'git show ' . l:hash . '^:' . l:fname
        if !s:ShowBufInNewTab(l:bufname)
            exec ':tabnew | silent r! git show ' . l:hash . '^:$(git rev-parse --show-prefix)' . shellescape(l:fname)
            setl buftype=nofile
            0d_
            exec 'silent :file ' . fnameescape(l:bufname)
        endif

        let l:bufname = 'git show ' . l:hash . ':' . l:fname
        if !s:ShowBufInNewSplit(l:bufname)
            exec 'vne | silent r! git show ' . l:hash . ':$(git rev-parse --show-prefix)' . shellescape(l:fname)
            setl buftype=nofile
            exec 'silent :file ' . fnameescape(l:bufname)
            0d_
        endif
    else
        " If the buffer is not different then repo, then diff HEAD vs file's previous commit
        let l:o = system("git status --porcelain | grep " . l:fname)
        if v:shell_error != 0
            let l:commit = system('git log -2 --pretty=format:"%h" -- ' . l:fname . ' | tail -n 1')
        endif

        let l:bufname = 'git show ' . l:commit . ':' . l:fname
        " Bug if l:filename includes ".."
        if !s:ShowBufInNewTab(l:bufname)
            exec ':tabnew | r! git show ' . l:commit . ':$(git rev-parse --show-prefix)' . l:fname
            setl buftype=nofile
            0d_
            exec 'silent :file ' . fnameescape(l:bufname)
        endif
        exec 'vert sb '.l:buf
    endif
    call winrestview(l:currentView)
    windo diffthis
    setl buftype=nofile
    wincmd r
    wincmd l
endfunction
command Diff :call s:GitDiff()

function! s:GitLog(...)
    let l:fname = expand('%')
    if stridx(l:fname, ' -- ') != -1
        let l:fname = split(l:fname, ' -- ')[-1]
    elseif stridx(l:fname, ':') != -1
        let l:fname = split(l:fname, ':')[-1]
    endif
    let l:args = a:1
    if strlen(l:args)
        " Add a space to the end
        let l:args = l:args . " "
    endif
    let l:bufname = 'git log ' . l:args . '-- ' . l:fname
    if !s:ShowBufInNewTab(l:bufname)
        exec 'tabnew | r! git log --no-color --graph --date=short ' . l:args . '--pretty="format:\%h \%ad \%s \%an \%d" -- ' . shellescape(l:fname)
        setl buftype=nofile
        0d_
        exec 'silent :file ' . fnameescape(l:bufname)
    endif
endfunction

" Handy arguments are --all, --merges, --date-order, --first-parent, --ancestry-path
command -nargs=* Log :call s:GitLog(<q-args>)

" vim:set ft=vim sw=4 sts=4 et:

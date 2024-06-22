Magic = {}
Magic.__index = Magic

local n = 0

function Magic.do_the_magic()
    if vim.bo.filetype ~= "c" then
        print("this is not a c file bro")
        return
    end

    local label_s = "____magic_macro_start:"
    local label_e = "____magic_macro_end:"
    local buf_name = "magic_macro_" .. n
    n = n + 1
    local message = "// " .. buf_name

    local file_name = vim.api.nvim_buf_get_name(0)

    -- https://www.reddit.com/r/neovim/comments/uae5gj/how_to_get_the_the_number_of_lines_you_are/
    local curpos = vim.fn.getcurpos()
    local line_s = curpos[2]
    local line_e = vim.fn.line('v')

    if line_s > line_e then
        local tmp = line_e
        line_e = line_s
        line_s = tmp
    end


    local genbuf = [[vnew +setlocal\ buftype=nowrite\ bufhidden=delete\ noswapfile\ syntax=c\ ft=c ]] .. buf_name
    local command =
    [[sed -e '%d i %s' -e '%d a %s' %s |gcc -E -o- -xc - |sed '/^%s/,$\!d;/^%s$/,$d;' |sed -e '/^\\# [0-9]/d' -e '1 s|^.*$|%s|']]
    command = command:format(line_s, label_s, line_e, label_e, file_name,
        label_s, label_e, message)

    -- vim.api.nvim_err_writeln("s: " .. line_s .. "; end:" .. line_e .. "\ncmd: " .. command)
    vim.cmd(genbuf .. " | .! " .. command)
    vim.lsp.buf.format()
end

return Magic


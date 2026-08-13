---@module 'lazy'
---@type LazySpec
return {
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        opts = {}, -- Esto equivale a require('nvim-autopairs').setup {}
    },
}
-- vim: ts=2 sts=2 sw=2 et

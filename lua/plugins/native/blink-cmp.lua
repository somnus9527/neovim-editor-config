return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "enter",
      ["<A-y>"] = { "select_and_accept" },
      ["<TAB>"] = { "snippet_forward", "fallback" },
      ["<S-TAB>"] = { "snippet_backward", "fallback" },
      ["<A-m>"] = { "select_prev", "fallback" },
      ["<A-n>"] = { "select_next", "fallback" },
      ["<A->>"] = { "scroll_documentation_down", "fallback" },
      ["<A-<>"] = { "scroll_documentation_up", "fallback" },
      ["<A-d>"] = { "show", "show_documentation", "hide_documentation" },
      ["<A-e>"] = { "hide", "fallback" },
    },
    sources = {
      default = { "lsp", "snippets", "path", "buffer" },
      providers = {
        snippets = {
          min_keyword_length = function(ctx)
            return ctx.trigger.kind == "trigger_character" and 0 or 2
          end,
          override = {
            get_trigger_characters = function(_)
              return { "$", "#" }
            end,
          },
        },
      },
    },
  },
}

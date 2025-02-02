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
      ["<A-i>"] = { "show", "show_documentation", "hide_documentation" },
      ["<A-e>"] = { "hide", "fallback" },
    },
  },
}

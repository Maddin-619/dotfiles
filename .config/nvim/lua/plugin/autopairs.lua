local npairs = require('nvim-autopairs')
npairs.setup({
  enable_check_bracket_line = true
})

npairs.setup({
    fast_wrap = {},
})

-- change default fast_wrap
npairs.setup({
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      hightlight = 'Search'
    },
})

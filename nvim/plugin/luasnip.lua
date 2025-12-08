-- Set up luasnip
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- Helper: get current file name without extension
local function filename_without_ext()
	return vim.fn.expand("%:t:r")
end

-- Java snippets
ls.add_snippets("java", {
	-- System.out.printf snippet
	s("souf", {
		t('System.out.printf("'),
		i(1, "%s"),
		t('\\n", '),
		i(2, "arg"),
		t(");"),
		i(0),
	}),

	-- Package + class snippet
	s("pclass", {
		-- Package line
		t("package "),
		i(1, "com.example"),
		t({ ";", "" }),
		t({ "", "" }),
		-- Class declaration using file name
		t("public class "),
		f(filename_without_ext, {}),
		t({ " {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- Package + interface snippet
	s("pint", {
		-- Package line
		t("package "),
		i(1, "com.example"),
		t({ ";", "" }),
		t({ "", "" }),
		-- Class declaration using file name
		t("public interface "),
		f(filename_without_ext, {}),
		t({ " {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),
})

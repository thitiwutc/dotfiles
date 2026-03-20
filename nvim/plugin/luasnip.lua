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

local function cur_folder_name()
	return vim.fn.fnamemodify(vim.fn.expand("%:h"), ":t")
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

	-- Package + class snippet
	s("penum", {
		-- Package line
		t("package "),
		i(1, "com.example"),
		t({ ";", "" }),
		t({ "", "" }),
		-- Class declaration using file name
		t("public enum "),
		f(filename_without_ext, {}),
		t({ " {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- Package + record snippet
	s("prec", {
		-- Package line
		t("package "),
		i(1, "com.example"),
		t({ ";", "" }),
		t({ "", "" }),
		-- Class declaration using file name
		t("public record "),
		f(filename_without_ext, {}),
		t("("),
		i(0),
		t({ ") {}" }),
	}),
})

ls.add_snippets("go", {
	s("pkg", { t("package "), f(cur_folder_name, {}) }),

	s("pmain", {
		t({ "package main", "", "func main() {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),
})

-- TS/JS snippet
ls.add_snippets("javascript", {
	s("clg", {
		t("console.log("),
		i(1),
		t(");"),
	}),
})
ls.add_snippets("javascript", {
	s("cerr", {
		t("console.error("),
		i(1),
		t(");"),
	}),
})
ls.add_snippets("javascript", {
	s("cwarn", {
		t("console.warn("),
		i(1),
		t(");"),
	}),
})
ls.add_snippets("javascript", {
	s("ctable", {
		t("console.table("),
		i(1),
		t(");"),
	}),
})
ls.filetype_extend("typescript", { "javascript" })
ls.filetype_extend("javascriptreact", { "javascript" })
ls.filetype_extend("typescriptreact", { "javascript" })
ls.filetype_extend("svelte", { "javascript" })

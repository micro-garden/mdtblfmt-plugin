# Markdown Table Formatter Plugin

**Markdown Table Formatter** is a plugin that reformats all Markdown tables
in the current buffer.
It aligns columns, respects alignment markers, and ensures clean, readable
tables without modifying the meaning or style unnecessarily.

## Features

- Detects Markdown tables that start with a pipe (`|`) character
- Aligns columns based on cell contents
- Respects alignment markers (`:---`, `:---:`, `---:`)
- Preserves implicit left alignment (`---`)
- Keeps table formatting minimal and tidy
- Adjusts separator line (`---`) to the minimum necessary width

## Table Syntax Requirements

This plugin only formats tables that follow
**standard Markdown table syntax**:

- Each line in the table **must begin with a `|` character**
- Second line must be a valid **separator line**, like:

```
|:---|:---:|---:| <- left / center / right alignment
```

- Tables with leading spaces or without leading pipes are ignored

This behavior follows the conventions of **CommonMark** and
**GitHub Flavored Markdown (GFM)**.

## Usage

To format all Markdown tables in the current buffer, run:

```
mdtblfmt
```

This will detect and reformat every valid Markdown table in-place.

## Notes

- The plugin does not alter non-table content
- Minimal formatting changes are made to preserve the original structure
- Currently supports formatting the entire buffer; range selection is not yet
  supported

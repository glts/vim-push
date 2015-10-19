push.vim
========

'Push' pastes like 'put', pushing the register text past surrounding
whitespace to one side.

This is an editing operation that comes up surprisingly often,
especially when moving around bits of text. Let's see how.

Motivation
----------

Here's a section title that needs a slight word order tweak.

    Like a Duck Walk and Quack
    --------------------------

We delete the first three words and move to the end of the line.

Then, in standard Vim, `p` gives this -- two more edits will be
necessary to fix up the boundaries (notice the trailing whitespace):

    Walk and QuackLike a Duck 
    --------------------------

With push.vim, the put command to use is `]=p`, and the result is this:

    Walk and Quack Like a Duck
    --------------------------

This is the problem that push.vim solves.

Usage
-----

By default, push.vim installs Normal mode mappings that correspond to
`p` and `P`.

*   `[=p` and `[=P` shift the register contents to the left and upwards
    while putting
*   `]=p` and `]=P` shift the register contents to the right and
    downwards

`<Plug>` mappings are also provided.

Requirements
------------

A relatively recent Vim 7.4 (after patch 7.4.513).

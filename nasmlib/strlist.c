/* ----------------------------------------------------------------------- *
 *
 *   Copyright 1996-2016 The NASM Authors - All Rights Reserved
 *   See the file AUTHORS included with the NASM distribution for
 *   the specific copyright holders.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following
 *   conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above
 *     copyright notice, this list of conditions and the following
 *     disclaimer in the documentation and/or other materials provided
 *     with the distribution.
 *
 *     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 *     CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *     INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 *     MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 *     CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *     SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *     NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 *     OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *     EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ----------------------------------------------------------------------- */

/*
 * strlist.c - simple linked list of strings
 */

#include "compiler.h"

#include <string.h>

#include "strlist.h"

static inline StrList *nasm_str_to_strlist(const char *str)
{
    size_t l = strlen(str) + 1;
    StrList *sl = nasm_malloc(l + sizeof sl->next);

    memcpy(sl->str, str, l);
    sl->next = NULL;

    return sl;
}

/*
 * Append a string list entry to a string list if and only if it isn't
 * already there.  Return true if it was added.
 */
bool nasm_add_to_strlist(StrList **head, StrList *entry)
{
    StrList *list;

    if (!head)
        return false;

    list = *head;
    while (list) {
        if (!strcmp(list->str, entry->str))
            return false;
        head = &list->next;
        list = list->next;
    }

    *head = entry;
    entry->next = NULL;
    return true;
}

/*
 * Append a string to a string list if and only if it isn't
 * already there.  Return true if it was added.
 */
bool nasm_add_string_to_strlist(StrList **head, const char *str)
{
    StrList *list;

    if (!head)
        return false;

    list = *head;
    while (list) {
        if (!strcmp(list->str, str))
            return false;
        head = &list->next;
        list = list->next;
    }

    *head = nasm_str_to_strlist(str);
    return true;
}

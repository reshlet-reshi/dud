#!/usr/bin/env bash

################################################################################
############################## Things change. ##################################
################################################################################

# explain `Things`
# ... ⚠️DEFERRED
# ... 💡TRY: 'explain `noun`'

# explain `noun`
# ... ⚠️DEFERRED
# ... 💡TRY: 'TO-DO explain `mind`'

# explain `mind`
# ... ❓ 心 
# ... 💡TRY: 'define `mark:noun(3)`'
# ... 💡TRY: 'define `mark:verb(2)`'
# ... 💡TRY: 'define `repeat:verb(5)`'

# define `mark:noun(3)`
# ... λ `mark:noun(3)`
# ... ➜ `mark`.noun(3)
# ... ➜ 'a symbol used in writing or printing'
# ... 💡TRY: 'explain `Aa`'

# define `mark:verb(2)`
# ... λ `mark:verb(2)`
# ... ➜ `mark`.verb(2)
# ... ➜ 'to put a mark or marks on'
# ... 💡TRY: 'explain `put`'

# define `repeat:verb(5)`
# ... λ `repeat:verb(5)`
# ... ➜ `repeat`.verb(5)
# ... ➜ 'to do, make, or perform again'
# ... 💡TRY: 'explain `repeat mark`'

# explain `Aa`
# ... ✅
: <<EOF
------------
A lasting mark 
    lets one mind 
leave a difference 
    where another mind 
can find it.
------------
To carry speech,
    that difference must be 
        repeatable
and small.
------------
`a`
    another
`A`
    Adam
------------
EOF
# ... ⛳ TECHNICAL: 
# ... ... `Aa` shows the uppercase and lowercase forms 
# ... ... of the Latin letter `A`.

# explain `put`
# ... ✅
: <<EOF
------------
A mark is not present ...
    ... until something changes.
------------
There is: 
- a surface.
------------
There is a 
    - possible 
difference 
    - on that 
surface.
------------
Without force ...
    ... the surface remains as it was.
------------
For difference to exist :
    - force must arrive ...
... and leave the surface changed.
------------
`put`:
    put the cat out
------------
EOF
# ... ⛳ TECHNICAL:
# ... ... To `put` something is to move, place, set, or apply it
# ... ... so it is in a specified position, place, or state.

# explain `repeat mark`
# ... 🎉
# ... ❗TRY: '` `.join([repeat:verb(5), mark:verb(2)]).explain()'
# ... ❗TRY: 'λ `to put a mark, again`'

# ` `.join([repeat:verb(5), mark:verb(2)]).explain()
# ... λ ` `.join([repeat:verb(5), mark:verb(2)]).explain()
# ... ➜ 'to put a mark, again'
# ... ⛳ TECHNICAL:
# ... ... When a sentence starts with "To" followed by a verb 
# ... ... (an infinitive phrase), 
# ... ... it acts as an introductory clause stating the purpose 
# ... ... or goal of the main sentence. 
# ... ... Always use a comma after this introductory phrase 
# ... ... to separate it from the main subject of your sentence

# λ `to put a mark, again`
: <<EOF
#!/usr/bin/env python3
import sys
type Mark = None | list[Mark]
def put(mark: Mark) -> None:
    while mark is not None:
        sys.stdout.write("|")
        mark = mark[0]
    sys.stdout.write("\n")
    sys.stdout.flush()
def count() -> None:
    mark: Mark = None
    while True:
        put(mark)
        mark = [mark]
if __name__ == "__main__":
    count()
EOF

# explain 'to put a mark, again'
# ... ✅
: <<EOF
------------
to count,
------------

|
||
|||
||||
|||||
||||||
|||||||
||||||||
|||||||||
||||||||||
|||||||||||
||||||||||||
...
------------
EOF
# ... ⛳ TECHNICAL:
# ... ... The Python block defines a recursive `Mark` value:
# ... ... either `None` for no mark, or a one-item list containing
# ... ... the previous `Mark`.
# ... ... `put()` prints one `|` for each list layer.
# ... ... `count()` starts at `None`, prints the current mark,
# ... ... then replaces it with `[mark]` forever, producing unary
# ... ... counting by repeated marks.

# explain 'Things'
# ... ✅
: <<EOF

|
||
|||
||||
|||||
||||||
|||||||
||||||||
|||||||||
||||||||||
|||||||||||
||||||||||||
...
EOF
# ... ⛳ TECHNICAL:
: <<EOF
A class of `thing` I find easy to talk about,
are the `natural-numbers`.

https://en.wikipedia.org/wiki/Natural_number

what I have presented above, is an example of
a `unary-numeral-system`.

https://en.wikipedia.org/wiki/Unary_numeral_system

Or, to put it another way, they are `tally-marks`.

https://en.wikipedia.org/wiki/Tally_marks

A nice thing about `natural-numbers` is, 
you never run out of em.

Just keep adding `|`s, and you will get a new one...
    ...eventualy.
EOF

# TODO: foo

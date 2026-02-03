# args Test Results

## Smoke Tests

Scenario              | Function | Invocation                             | Arguments                    | Expected                                         | Status | ✓/✗
--------------------- | -------- | -------------------------------------- | ---------------------------- | ------------------------------------------------ | ------ | -----------------------------------
flag:long             | flag     | args:flag verbose v                    | --verbose                    | true                                             |      0 | ✅
flag:short            | flag     | args:flag verbose v                    | -v                           | true                                             |      0 | ✅
flag:absent           | flag     | args:flag verbose v                    | *(none)*                     | ""                                               |      0 | ✅
opt:long-space        | opt      | args:opt name n                        | --name foo                   | foo                                              |      0 | ✅
opt:short-space       | opt      | args:opt name n                        | -n foo                       | foo                                              |      0 | ✅
opt:absent            | opt      | args:opt name n                        | *(none)*                     | ""                                               |      0 | ✅
arg:positional        | arg      | args:arg file                          | foo                          | foo                                              |      0 | ✅
arg:missing           | arg      | args:arg file                          | *(none)*                     | -                                                |      1 | ✅
arg:optional-missing  | arg      | args:arg -o file                       | *(none)*                     | ""                                               |      0 | ✅
varg:variadic         | varg     | args:varg files                        | a b c                        | (a b c)                                          |      0 | ✅
varg:missing          | varg     | args:varg files                        | *(none)*                     | -                                                |      1 | ✅
varg:optional-missing | varg     | args:varg -o files                     | *(none)*                     | ()                                               |      0 | ✅
sub:match             | sub      | args:sub cmd sub_args '^([a-z]+)$'    | --verbose clone https://repo | clone, sub_args=(https://repo), ARGS=(--verbose) |      0 | ✅
sub:missing           | sub      | args:sub cmd sub_args '^([a-z]+)$'    | *(none)*                     | -                                                |      1 | ✅
sub:optional-missing  | sub      | args:sub -o cmd sub_args '^([a-z]+)$' | *(none)*                     | ""                                               |      0 | ✅

---

## Feature Tests

### --required / --optional
Scenario                      | Function | Invocation                             | Arguments                            | Expected                        | Status | ✓/✗
----------------------------- | -------- | -------------------------------------- | ------------------------------------ | ------------------------------- | ------ | ---------------------------------------------
flag:required-found           | flag     | args:flag -r verbose v                 | --verbose                            | true                            |      0 | ✅
flag:required-missing         | flag     | args:flag -r verbose v                 | *(none)*                             | -                               |      1 | ✅
flag:required-multiple        | flag     | args:flag -r verbose v                 | -v -v                                | true                            |      0 | ✅
flag:required-after-sep       | flag     | args:flag -r verbose v                 | -- -v                                | -                               |      1 | ✅
opt:required-found            | opt      | args:opt -r name n                     | --name foo                           | foo                             |      0 | ✅
opt:required-missing          | opt      | args:opt -r name n                     | *(none)*                             | -                               |      1 | ✅
opt:required-long-only-absent | opt      | args:opt -r name ""                    | *(none)*                             | -                               |      1 | ✅
arg:optional-present          | arg      | args:arg -o file                       | foo                                  | foo, ARGS=()                    |      0 | ✅
arg:optional-pattern-match    | arg      | args:arg -o num '^[0-9]+$'            | 123                                  | 123                             |      0 | ✅
arg:optional-pattern-mismatch | arg      | args:arg -o num '^[0-9]+$'            | abc                                  | "", ARGS=(abc)                  |      0 | ✅
varg:single-arg               | varg     | args:varg files                        | single                               | (single)                        |      0 | ✅
varg:optional-present         | varg     | args:varg -o files                     | a b c                                | (a b c)                         |      0 | ✅
varg:optional-single          | varg     | args:varg -o files                     | single                               | (single)                        |      0 | ✅
sub:optional-match            | sub      | args:sub -o cmd sub_args '^([a-z]+)$' | clone https://repo                   | clone                           |      0 | ✅
sub:required-mismatch         | sub      | args:sub cmd sub_args '^([a-z]+)$'    | --verbose --force                    | -                               |      1 | ✅
sub:optional-mismatch         | sub      | args:sub -o cmd sub_args '^([a-z]+)$' | --verbose --force                    | ""                              |      0 | ✅
sub:flags-before              | sub      | args:sub cmd sub_args '^([a-z]+)$'    | --verbose --force clone https://repo | clone, ARGS=(--verbose --force) |      0 | ✅

### long-only
Scenario                     | Function | Invocation           | Arguments  | Expected          | Status | ✓/✗
---------------------------- | -------- | -------------------- | ---------- | ----------------- | ------ | --------------------------------------------
flag:long-only               | flag     | args:flag verbose "" | --verbose  | true              |      0 | ✅
flag:long-only-ignores-short | flag     | args:flag verbose "" | -v         | "", ARGS=(-v)     |      0 | ✅
flag:long-only-absent        | flag     | args:flag verbose "" | *(none)*   | ""                |      0 | ✅
opt:long-only                | opt      | args:opt name ""     | --name foo | foo               |      0 | ✅
opt:long-only-ignores-short  | opt      | args:opt name ""     | -n foo     | "", ARGS=(-n foo) |      0 | ✅
opt:long-only-absent         | opt      | args:opt name ""     | *(none)*   | ""                |      0 | ✅

### --bundle
Scenario                | Function | Invocation                                                                                                        | Arguments          | Expected           | Status | ✓/✗
----------------------- | -------- | ----------------------------------------------------------------------------------------------------------------- | ------------------ | ------------------ | ------ | ---------------------------------------
flag:bundle-basic       | flag     | args:flag -b verbose v                                                                                            | -vfs               | true, ARGS=(-fs)   |      0 | ✅
flag:bundle-multiple    | flag     | args:flag -b verbose v; args:flag -b force f; args:flag -b silent s                                               | -vfs               | all true, ARGS=()  |      0 | ✅
flag:bundle-curl-style  | flag     | args:flag -b tls1 1; args:flag -b fail f; args:flag -b silent s; args:flag -b show_error S; args:flag -b follow L | -1fsSL https://... | all true           |      0 | ✅
flag:bundle-partial     | flag     | args:flag -b verbose v                                                                                            | -vfs               | true, ARGS=(-fs)   |      0 | ✅
flag:bundle-no-match    | flag     | args:flag -b other x                                                                                              | -vfs               | "", ARGS=(-vfs)    |      0 | ✅
flag:bundle-exact-short | flag     | args:flag -b verbose v                                                                                            | -v                 | true, ARGS=()      |      0 | ✅
flag:bundle-exact-long  | flag     | args:flag -b verbose v                                                                                            | --verbose          | true, ARGS=()      |      0 | ✅
flag:bundle-separator   | flag     | args:flag -b verbose v                                                                                            | -- -vfs            | "", ARGS=(-- -vfs) |      0 | ✅
flag:bundle-long-only   | flag     | args:flag -b verbose ""                                                                                           | --verbose          | true               |      0 | ✅

### --count
Scenario             | Function | Invocation                   | Arguments           | Expected   | Status | ✓/✗
-------------------- | -------- | ---------------------------- | ------------------- | ---------- | ------ | ------------------------------------
flag:count-single    | flag     | args:flag --count verbose v  | -v                  | 1, ARGS=() |      0 | ✅
flag:count-multiple  | flag     | args:flag --count verbose v  | -v -v --verbose     | 3, ARGS=() |      0 | ✅
flag:count-absent    | flag     | args:flag --count verbose v  | *(none)*            | 0          |      0 | ✅
flag:count-long-only | flag     | args:flag --count verbose "" | --verbose --verbose | 2          |      0 | ✅

### --accumulate
Scenario                 | Function | Invocation                     | Arguments                        | Expected      | Status | ✓/✗
------------------------ | -------- | ------------------------------ | -------------------------------- | ------------- | ------ | ----------------------------------------
opt:accum-multiple       | opt      | args:opt -a name n             | --name foo --name bar --name baz | (foo bar baz) |      0 | ✅
opt:accum-single         | opt      | args:opt -a name n             | --name foo                       | (foo)         |      0 | ✅
opt:accum-absent         | opt      | args:opt -a name n             | *(none)*                         | ()            |      0 | ✅
opt:accum-mixed-delivery | opt      | args:opt -a name n             | --name foo -nbar --name=baz      | (foo bar baz) |      0 | ✅
opt:accum-pattern        | opt      | args:opt -a port p '^[0-9]+$' | --port 8080 --port 9090          | (8080 9090)   |      0 | ✅

### pattern / capture-group
Scenario                      | Function | Invocation                          | Arguments           | Expected            | Status | ✓/✗
----------------------------- | -------- | ----------------------------------- | ------------------- | ------------------- | ------ | ---------------------------------------------
opt:pattern-match             | opt      | args:opt port p '^[0-9]+$'         | --port 8080         | 8080                |      0 | ✅
opt:pattern-mismatch          | opt      | args:opt port p '^[0-9]+$'         | --port abc          | -                   |      1 | ✅
opt:long-equals               | opt      | args:opt name n                     | --name=foo          | foo                 |      0 | ✅
opt:short-attached            | opt      | args:opt name n                     | -nfoo               | foo                 |      0 | ✅
opt:capture-group             | opt      | args:opt ord o '^:([0-9]{3})$'     | --ord :100          | 100                 |      0 | ✅
arg:pattern-match             | arg      | args:arg num '^[0-9]+$'            | 123                 | 123                 |      0 | ✅
arg:pattern-mismatch-required | arg      | args:arg num '^[0-9]+$'            | abc                 | -                   |      1 | ✅
arg:url-pattern-match         | arg      | args:arg url '^https?://'           | https://example.com | https://example.com |      0 | ✅
arg:url-pattern-mismatch      | arg      | args:arg url '^https?://'           | /local/path         | -                   |      1 | ✅
arg:capture-group             | arg      | args:arg ord '^:([0-9]{3})$'       | :100                | 100                 |      0 | ✅
sub:capture-group             | sub      | args:sub cmd sub_args '^([a-z]+)$' | clone https://repo  | clone               |      0 | ✅
sub:no-capture-group          | sub      | args:sub cmd sub_args '^[a-z]+$'   | clone https://repo  | clone               |      0 | ✅

### --err
Scenario                  | Function | Invocation                                      | Arguments | Expected  | Status | ✓/✗
------------------------- | -------- | ----------------------------------------------- | --------- | --------- | ------ | -----------------------------------------
flag:err-required-msg     | flag     | args:flag -r verbose v --err "..."              | *(none)*  | stderr    |      1 | ✅
flag:err-optional-absent  | flag     | args:flag verbose v --err "..."                 | *(none)*  | no stderr |      0 | ✅
flag:err-required-present | flag     | args:flag -r verbose v --err "..."              | --verbose | no stderr |      0 | ✅
opt:err-required-msg      | opt      | args:opt -r name n --err "..."                  | *(none)*  | stderr    |      1 | ✅
arg:err-required-msg      | arg      | args:arg file --err "..."                       | *(none)*  | stderr    |      1 | ✅
arg:err-optional-absent   | arg      | args:arg -o file --err "..."                    | *(none)*  | no stderr |      0 | ✅
varg:err-required-msg     | varg     | args:varg files --err "..."                     | *(none)*  | stderr    |      1 | ✅
varg:err-required-present | varg     | args:varg files --err "..."                     | a b c     | no stderr |      0 | ✅
varg:err-optional-absent  | varg     | args:varg -o files --err "..."                  | *(none)*  | no stderr |      0 | ✅
varg:err-optional-present | varg     | args:varg -o files --err "..."                  | a b c     | no stderr |      0 | ✅
sub:err-required-msg      | sub      | args:sub cmd sub_args '^([a-z]+)$' --err "..." | *(none)*  | stderr    |      1 | ✅

### -- separator
Scenario                  | Function | Invocation                             | Arguments                | Expected                      | Status | ✓/✗
------------------------- | -------- | -------------------------------------- | ------------------------ | ----------------------------- | ------ | -----------------------------------------
flag:sep-stops            | flag     | args:flag verbose v                    | --verbose -- --verbose   | true, ARGS=(-- --verbose)     |      0 | ✅
flag:sep-no-match         | flag     | args:flag verbose v                    | -- -v                    | "", ARGS=(-- -v)              |      0 | ✅
opt:sep-stops             | opt      | args:opt name n                        | --name foo -- --name bar | foo, ARGS=(-- --name bar)     |      0 | ✅
opt:sep-no-match          | opt      | args:opt name n                        | -- --name foo            | "", ARGS=(-- --name foo)      |      0 | ✅
opt:sep-required-after    | opt      | args:opt -r name n                     | -- --name foo            | -                             |      1 | ✅
arg:sep-consumes          | arg      | args:arg file                          | -- foo                   | foo                           |      0 | ✅
arg:sep-then-flag-like    | arg      | args:arg file                          | -- --weird-file          | --weird-file                  |      0 | ✅
arg:sep-only-required     | arg      | args:arg file                          | --                       | -                             |      1 | ✅
arg:sep-only-optional     | arg      | args:arg -o file                       | --                       | ""                            |      0 | ✅
arg:sep-optional-present  | arg      | args:arg -o file                       | -- foo                   | foo                           |      0 | ✅
arg:sep-pattern-match     | arg      | args:arg num '^[0-9]+$'               | -- 123                   | 123                           |      0 | ✅
arg:sep-pattern-mismatch  | arg      | args:arg num '^[0-9]+$'               | -- abc                   | -                             |      1 | ✅
varg:sep-consumes         | varg     | args:varg files                        | -- a b                   | (a b)                         |      0 | ✅
varg:sep-flag-like-after  | varg     | args:varg vals                         | -- --flag -x             | (--flag -x)                   |      0 | ✅
varg:sep-only-required    | varg     | args:varg files                        | --                       | -                             |      1 | ✅
varg:sep-only-optional    | varg     | args:varg -o files                     | --                       | ()                            |      0 | ✅
varg:sep-optional-present | varg     | args:varg -o files                     | -- a b                   | (a b)                         |      0 | ✅
sub:sep-stops             | sub      | args:sub -o cmd sub_args '^([a-z]+)$' | --verbose -- clone       | "", ARGS=(--verbose -- clone) |      0 | ✅
sub:sep-required-after    | sub      | args:sub cmd sub_args '^([a-z]+)$'    | -- clone                 | -                             |      1 | ✅
sub:sep-only-required     | sub      | args:sub cmd sub_args '^([a-z]+)$'    | --                       | -                             |      1 | ✅
sub:sep-only-optional     | sub      | args:sub -o cmd sub_args '^([a-z]+)$' | --                       | ""                            |      0 | ✅

---

## Acceptance Tests

Scenario                       | Function | Invocation                                                                             | Arguments          | Expected      | Status | ✓/✗
------------------------------ | -------- | -------------------------------------------------------------------------------------- | ------------------ | ------------- | ------ | ---------------------------------------------
flag:bundle-required           | flag     | args:flag -r -b force f                                                                | -vfs               | true          |      0 | ✅
flag:bundle-required-absent    | flag     | args:flag -r -b verbose v                                                              | -xfs               | -             |      1 | ✅
flag:bundle-with-opts          | flag     | args:opt output o; args:flag -b verbose v; args:flag -b force f; args:flag -b silent s | -o output.txt -vfs | all parsed    |      0 | ✅
flag:bundle-err                | flag     | args:flag -r -b verbose v --err "..."                                                  | -xfs               | stderr        |      1 | ✅
flag:count-required-present    | flag     | args:flag -r --count verbose v                                                         | -v                 | 1             |      0 | ✅
flag:count-required-absent     | flag     | args:flag -r --count verbose v                                                         | *(none)*           | -             |      1 | ✅
flag:count-bundle              | flag     | args:flag -b --count verbose v                                                         | -vfs               | 1, ARGS=(-fs) |      0 | ✅
flag:count-bundle-multiple     | flag     | args:flag -b --count verbose v                                                         | -vfs -xv           | 2             |      0 | ✅
flag:count-err-required-absent | flag     | args:flag -r --count verbose v --err "."                                               | *(none)*           | stderr        |      1 | ✅
flag:long-only-required        | flag     | args:flag -r verbose ""                                                                | --verbose          | true          |      0 | ✅
flag:long-only-required-absent | flag     | args:flag -r verbose ""                                                                | *(none)*           | -             |      1 | ✅
opt:accum-required-absent      | opt      | args:opt -r -a name n                                                                  | *(none)*           | -             |      1 | ✅
opt:accum-err-required-absent  | opt      | args:opt -r -a name n --err "..."                                                      | *(none)*           | stderr        |      1 | ✅
opt:capture-group-short        | opt      | args:opt ord o '^:([0-9]{3})$'                                                        | -o:100             | 100           |      0 | ✅
opt:capture-group-equals       | opt      | args:opt ord o '^:([0-9]{3})$'                                                        | --ord=:100         | 100           |      0 | ✅
opt:required-long-only         | opt      | args:opt -r name ""                                                                    | --name foo         | foo           |      0 | ✅
opt:required-pattern           | opt      | args:opt -r port p '^[0-9]+$'                                                         | --port 8080        | 8080          |      0 | ✅
opt:required-pattern-mismatch  | opt      | args:opt -r port p '^[0-9]+$'                                                         | --port abc         | -             |      1 | ✅
opt:long-only-equals           | opt      | args:opt name ""                                                                       | --name=foo         | foo           |      0 | ✅
opt:pattern-match-equals       | opt      | args:opt port p '^[0-9]+$'                                                            | --port=8080        | 8080          |      0 | ✅

---

## Regression Tests

Scenario                            | Function | Invocation                              | Arguments            | Expected                  | Status | ✓/✗
----------------------------------- | -------- | --------------------------------------- | -------------------- | ------------------------- | ------ | ---------------------------------------------------
flag:mixed-args                     | flag     | args:flag verbose v                     | -v --other           | true, ARGS=(--other)      |      0 | ✅
flag:flag-after-other               | flag     | args:flag verbose v                     | --other -v           | true, ARGS=(--other)      |      0 | ✅
flag:duplicate-flags                | flag     | args:flag verbose v                     | -v -v                | true, ARGS=()             |      0 | ✅
flag:equals-syntax                  | flag     | args:flag verbose v                     | --verbose=true       | "", ARGS=(--verbose=true) |      0 | ✅
flag:attached-value                 | flag     | args:flag verbose v                     | -vvalue              | "", ARGS=(-vvalue)        |      0 | ✅
opt:empty-value                     | opt      | args:opt name n                         | --name ""            | ""                        |      0 | ✅
opt:mixed-args                      | opt      | args:opt name n                         | --name foo --other   | foo, ARGS=(--other)       |      0 | ✅
opt:opt-after-other                 | opt      | args:opt name n                         | --other --name foo   | foo, ARGS=(--other)       |      0 | ✅
opt:missing-value-long              | opt      | args:opt name n '^.+$'                 | --name               | -                         |      1 | ✅
opt:missing-value-short             | opt      | args:opt name n '^.+$'                 | -n                   | -                         |      1 | ✅
opt:short-attached-pattern-match    | opt      | args:opt port p '^[0-9]+$'             | -p8080               | 8080                      |      0 | ✅
opt:short-attached-pattern-mismatch | opt      | args:opt port p '^[0-9]+$'             | -pabc                | -                         |      1 | ✅
opt:pattern-with-err-msg            | opt      | args:opt port p '^[0-9]+$' --err "..." | --port abc           | stderr                    |      1 | ✅
opt:pattern-absent-optional         | opt      | args:opt port p '^[0-9]+$'             | *(none)*             | ""                        |      0 | ✅
opt:special-chars                   | opt      | args:opt name n                         | --name 'foo;bar'     | foo;bar                   |      0 | ✅
opt:newline-in-value                | opt      | args:opt name n                         | --name $'foo\nbar' | foo\nbar                 |      0 | ✅
opt:unicode                         | opt      | args:opt name n                         | --name '日本語'      | 日本語                    |      0 | ✅
opt:equals-in-value                 | opt      | args:opt name n                         | --name=foo=bar       | foo=bar                   |      0 | ✅
opt:spaces-via-equals               | opt      | args:opt name n                         | --name='foo bar'     | foo bar                   |      0 | ✅
opt:hyphen-value                    | opt      | args:opt name n                         | --name -             | "-"                       |      0 | ✅
arg:first-of-many                   | arg      | args:arg first                          | foo bar baz          | foo, ARGS=(bar baz)       |      0 | ✅
arg:empty-string                    | arg      | args:arg val                            | ""                   | ""                        |      0 | ✅
arg:flag-like                       | arg      | args:arg val                            | --flag               | --flag                    |      0 | ✅
arg:optional-skip-non-match         | arg      | args:arg -o num '^[0-9]+$'             | abc 123              | "", ARGS=(abc 123)        |      0 | ✅
arg:stdin-marker                    | arg      | args:arg file                           | -                    | "-"                       |      0 | ✅
arg:pattern-with-err-msg            | arg      | args:arg num '^[0-9]+$' --err "..."    | abc                  | stderr                    |      1 | ✅
varg:empty-strings                  | varg     | args:varg vals                          | "" "" ""             | ("" "" "")                |      0 | ✅
varg:flag-like-values               | varg     | args:varg vals                          | --flag -x value      | (--flag -x value)         |      0 | ✅
varg:spaces                         | varg     | args:varg vals                          | a "b c" d            | (a "b c" d)               |      0 | ✅

---

## Integration Tests

Scenario                       | Invocation                                                              | Arguments                    | Expected        | Status | ✓/✗
------------------------------ | ----------------------------------------------------------------------- | ---------------------------- | --------------- | ------ | ------------------------------------------
flag-opt-arg                   | args:flag verbose v; args:opt name n; args:arg file                     | -v --name foo bar            | all parsed      |      0 | ✅
order-independence             | args:flag verbose v; args:opt name n; args:arg file                     | bar --name foo -v            | all parsed      |      0 | ✅
opt-arg-patterns               | args:opt url u '^https?://'; args:arg path                              | --url https://x.com /path    | both matched    |      0 | ✅
flag-varg                      | args:flag verbose v; args:varg files                                    | -v a b c                     | verbose + files |      0 | ✅
duplicate-opts-first-wins      | args:opt name n                                                         | --name foo --name bar        | foo (first)     |      0 | ✅
early-exit-required            | args:flag verbose v; args:opt -r name n                                 | *(none)*                     | early exit      |      1 | ✅
full-pipeline-with-separator   | args:flag verbose v; args:opt name n; args:arg file; args:varg -o extra | -v --name foo -- --weird -rf | all parsed      |      0 | ✅
multiple-args-across-separator | args:arg a1; args:arg a2; args:arg a3                                   | pos1 -- pos2 pos3            | all parsed      |      0 | ✅


## Summary

| ✅ Pass | ❌ Fail | ⚠️ Error |
|---------|---------|----------|
| 157 | 0 | 0 |


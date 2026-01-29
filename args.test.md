# args Test Results

## args:flag

### Smoke Tests
Scenario        | Invocation                   | Arguments    | Expected | Status | ✓/✗
----------------|------------------------------|--------------|----------|--------|----
basic-long      | args:flag verbose v          | --verbose    | true     |      0 | ✅
basic-short     | args:flag verbose v          | -v           | true     |      0 | ✅
optional-absent | args:flag verbose v          | *(none)*     | ""       |      0 | ✅

### Acceptance Tests
Scenario                | Invocation                         | Arguments    | Expected | Status | ✓/✗
------------------------|------------------------------------|--------------| ---------|--------|----
required-found          | args:flag -r verbose v             | --verbose    | true     |      0 | ✅
required-missing        | args:flag -r verbose v             | *(none)*     | -        |      1 | ✅
required-err-msg        | args:flag -r verbose v --err "..." | *(none)*     | stderr   |      1 | ✅
long-only               | args:flag verbose ""               | --verbose    | true     |      0 | ✅
long-only-ignores-short | args:flag verbose ""               | -v           | ""       |      0 | ✅

### Regression Tests
Scenario               | Invocation          | Arguments        | Expected                     | Status | ✓/✗
-----------------------|---------------------|------------------|------------------------------|--------|----
mixed-args             | args:flag verbose v | -v --other       | true, ARGS=(--other)         |      0 | ✅
flag-after-other       | args:flag verbose v | --other -v       | true, ARGS=(--other)         |      0 | ✅
duplicate-flags        | args:flag verbose v | -v -v            | true, ARGS=()                |      0 | ✅
equals-syntax-ignored  | args:flag verbose v | --verbose=true   | "", ARGS=(--verbose=true)    |      0 | ✅
attached-value-ignored | args:flag verbose v | -vvalue          | "", ARGS=(-vvalue)           |      0 | ✅

---

## args:opt

### Smoke Tests
Scenario          | Invocation        | Arguments    | Expected | Status | ✓/✗
------------------|-------------------|--------------|----------|--------|----
basic-long-space  | args:opt name n   | --name foo   | foo      |      0 | ✅
basic-short-space | args:opt name n   | -n foo       | foo      |      0 | ✅
optional-absent   | args:opt name n   | *(none)*     | ""       |      0 | ✅

### Acceptance Tests
Scenario                | Invocation                       | Arguments     | Expected             | Status | ✓/✗
------------------------|----------------------------------|---------------|----------------------|--------|----
long-equals             | args:opt name n                  | --name=foo    | foo                  |      0 | ✅
short-attached          | args:opt name n                  | -nfoo         | foo                  |      0 | ✅
required-found          | args:opt -r name n               | --name foo    | foo                  |      0 | ✅
required-missing        | args:opt -r name n               | *(none)*      | -                    |      1 | ✅
required-err-msg        | args:opt -r name n --err "..."   | *(none)*      | stderr               |      1 | ✅
pattern-match           | args:opt port p '^[0-9]+$'      | --port 8080   | 8080                 |      0 | ✅
pattern-mismatch        | args:opt port p '^[0-9]+$'      | --port abc    | -                    |      1 | ✅
long-only               | args:opt name ""                 | --name foo    | foo                  |      0 | ✅
long-only-ignores-short | args:opt name ""                 | -n foo        | "", ARGS=(-n foo)    |      0 | ✅
capture-group           | args:opt ord o '^:([0-9]{3})$'  | --ord :100    | 100                  |      0 | ✅

### Regression Tests
Scenario                        | Invocation                             | Arguments            | Expected              | Status | ✓/✗
--------------------------------|----------------------------------------|----------------------|-----------------------|--------|----
empty-via-equals                | args:opt name n                        | --name=              | ""                    |      0 | ✅
empty-via-space                 | args:opt name n                        | --name ""            | ""                    |      0 | ✅
mixed-args                      | args:opt name n                        | --name foo --other   | foo, ARGS=(--other)   |      0 | ✅
opt-after-other                 | args:opt name n                        | --other --name foo   | foo, ARGS=(--other)   |      0 | ✅
missing-value-eol               | args:opt name n '^.+$'                | --name               | -                     |      1 | ✅
short-attached-pattern-match    | args:opt port p '^[0-9]+$'            | -p8080               | 8080                  |      0 | ✅
short-attached-pattern-mismatch | args:opt port p '^[0-9]+$'            | -pabc                | -                     |      1 | ✅
pattern-with-err-msg            | args:opt port p '^[0-9]+$' --err "..."| --port abc           | stderr                |      1 | ✅

---

## args:arg

### Smoke Tests
Scenario         | Invocation         | Arguments | Expected | Status | ✓/✗
-----------------|--------------------|-----------|----------|--------|----
basic-positional | args:arg file      | foo       | foo      |      0 | ✅
required-missing | args:arg file      | *(none)*  | -        |      1 | ✅
optional-missing | args:arg -o file   | *(none)*  | ""       |      0 | ✅

### Acceptance Tests
Scenario                  | Invocation                       | Arguments             | Expected          | Status | ✓/✗
--------------------------|----------------------------------|-----------------------|-------------------|--------|----
pattern-match             | args:arg num '^[0-9]+$'         | 123                   | 123               |      0 | ✅
pattern-mismatch-required | args:arg num '^[0-9]+$'         | abc                   | -                 |      1 | ✅
pattern-mismatch-optional | args:arg -o num '^[0-9]+$'      | abc                   | "", ARGS=(abc)    |      0 | ✅
required-err-msg          | args:arg file --err "..."        | *(none)*              | stderr            |      1 | ✅
url-pattern-match         | args:arg url '^https?://'        | https://example.com   | https://...       |      0 | ✅
url-pattern-mismatch      | args:arg url '^https?://'        | /local/path           | -                 |      1 | ✅
capture-group             | args:arg ord '^:([0-9]{3})$'    | :100                  | 100               |      0 | ✅

### Regression Tests
Scenario                | Invocation                          | Arguments     | Expected               | Status | ✓/✗
------------------------|-------------------------------------|---------------|------------------------|--------|----
first-of-many           | args:arg first                      | foo bar baz   | foo, ARGS=(bar baz)    |      0 | ✅
empty-string            | args:arg val                        | ""            | ""                     |      0 | ✅
flag-like-value         | args:arg val                        | --flag        | --flag                 |      0 | ✅
optional-skip-non-match | args:arg -o num '^[0-9]+$'         | abc 123       | "", ARGS=(abc 123)     |      0 | ✅
stdin-marker            | args:arg file                       | -             | -                      |      0 | ✅
pattern-with-err-msg    | args:arg num '^[0-9]+$' --err "..."| abc           | stderr                 |      1 | ✅

---

## args:varg

### Smoke Tests
Scenario         | Invocation           | Arguments | Expected  | Status | ✓/✗
-----------------|----------------------|-----------|-----------|--------|----
basic-variadic   | args:varg files      | a b c     | (a b c)   |      0 | ✅
required-missing | args:varg files      | *(none)*  | -         |      1 | ✅
optional-missing | args:varg -o files   | *(none)*  | ()        |      0 | ✅

### Acceptance Tests
Scenario         | Invocation                    | Arguments | Expected   | Status | ✓/✗
-----------------|-------------------------------|-----------|------------|--------|----
single-arg       | args:varg files               | single    | (single)   |      0 | ✅
required-err-msg | args:varg files --err "..."   | *(none)*  | stderr     |      1 | ✅
optional-present | args:varg -o files            | a b c     | (a b c)    |      0 | ✅

### Regression Tests
Scenario         | Invocation        | Arguments         | Expected            | Status | ✓/✗
-----------------|-------------------|-------------------|---------------------|--------|----
empty-strings    | args:varg vals    | "" "" ""          | ("" "" "")          |      0 | ✅
flag-like-values | args:varg vals    | --flag -x value   | (--flag -x value)   |      0 | ✅
preserves-spaces | args:varg vals    | a "b c" d         | (a "b c" d)         |      0 | ✅

---

## Integration Tests

Scenario                 | Invocation                | Arguments                  | Expected        | Status | ✓/✗
-------------------------|---------------------------|----------------------------|-----------------|--------|----
flag-opt-arg             | flag v; opt n; arg file   | -v --name foo bar          | all parsed      |      0 | ✅
order-independence       | flag v; opt n; arg file   | bar --name foo -v          | all parsed      |      0 | ✅
opt-arg-patterns         | opt url; arg path         | --url https://x.com /path  | both matched    |      0 | ✅
flag-varg                | flag v; varg files        | -v a b c                   | verbose + files |      0 | ✅
duplicate-opts-last-wins | opt name n                | --name foo --name bar      | bar (last)      |      0 | ✅
early-exit-required      | flag v; opt -r name n     | *(none)*                   | early exit      |      1 | ✅

---

## Edge Cases

Scenario          | Invocation        | Arguments            | Expected    | Status | ✓/✗
------------------|-------------------|----------------------|-------------|--------|----
special-chars     | args:opt name n   | --name 'foo;bar'     | foo;bar     |      0 | ✅
newline-in-value  | args:opt name n   | --name $'foo\nbar' | foo\nbar   |      0 | ✅
unicode           | args:opt name n   | --name '日本語'      | 日本語      |      0 | ✅
equals-in-value   | args:opt name n   | --name=foo=bar       | foo=bar     |      0 | ✅
spaces-via-equals | args:opt name n   | --name='foo bar'     | foo bar     |      0 | ✅
hyphen-value      | args:opt name n   | --name -             | -           |      0 | ✅


## Summary

| ✅ Pass | ❌ Fail | ⚠️ Error |
|---------|---------|----------|
| 71 | 0 | 0 |


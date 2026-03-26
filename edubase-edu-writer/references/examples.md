# EDU File Examples — Complete Worked Questions

Each example shows a complete EDU file for a specific question type.
Only non-empty sections are shown with values; blank sections still appear as empty.

---

## CHOICE — Single correct answer

```
%------LANGUAGE------%
en
%------QUESTION!!------%
What is the capital of France?
%------ANSWER!!------%
Paris
%------TYPE!!------%
% [X] CHOICE
% [ ] MULTIPLE-CHOICE
% [ ] TRUE/FALSE
% [ ] NUMERICAL
% [ ] EXPRESSION
% [ ] ORDER
% [ ] GROUPING
% [ ] PAIRING
% [ ] MATRIX
% [ ] MATRIX:EXPRESSION
% [ ] SET
% [ ] SET:TEXT
% [ ] DATE/TIME
% [ ] TEXT
% [ ] FREE-TEXT
% [ ] FILE
% [ ] HOTSPOT
% [ ] READING
% [ ] GENERIC
%------SUBJECT!------%
Geography
%------CATEGORY!------%
European capitals
%------MAIN_CATEGORY------%
%------PARAMETERS------%
%------CONSTRAINTS------%
%------POINTS------%
1
%------SUBSCORING------%
% [X] PROPORTIONAL
% [ ] LINEAR_SUBSTRACTED:N
% [ ] CUSTOM
% [ ] NONE
%------SUBPOINTS------%
%------MANUAL_SCORING------%
% [X] NO
% [ ] NOT_CORRECT
% [ ] ALWAYS
%------PENALTY_POINTS------%
%------PENALTY_SCORING------%
% [X] DEFAULT
% [ ] PER_ANSWER
% [ ] PER_QUESTION
%------OPTIONS------%
London &&& Berlin &&& Madrid
%------NOTE------%
%------PRIVATE_NOTE------%
%------EXPLANATION------%
Paris has been the capital of France since the 10th century.
%------SOLUTION------%
%------SOLUTION_IMAGE------%
%------HINT------%
%------VIDEO------%
%------DIFFICULTY------%
1
%------ANSWER_REQUIRE------%
%------QUESTION_FORMAT------%
% [X] NORMAL
% [ ] LATEX
% [ ] LONG
%------ANSWER_FORMAT------%
%------SOURCE------%
%------TAG------%
%------DECIMALS------%
%------MAXIMUM_CHOICES------%
%------OPTIONS_FIX------%
%------ANSWER_ORDER------%
%------ANSWER_HIDE------%
%------ANSWER_LABEL------%
%------ANSWER_INDEFINITE------%
%------GROUP------%
%------EXPRESSION_CHECK------%
%------EXPRESSION_DECIMALS------%
%------EXPRESSION_RANDOM_TYPE------%
%------EXPRESSION_RANDOM_TRIES------%
%------EXPRESSION_RANDOM_RANGE------%
%------EXPRESSION_RANDOM_INSIDE------%
%------EXPRESSION_RANDOM_OUTSIDE------%
%------EXPRESSION_EXPLICIT_GOAL------%
%------EXPRESSION_EXTENDED------%
%------EXPRESSION_FUNCTIONS------%
%------EXPRESSION_VARIABLE------%
%------IMAGE------%
%------ATTACHMENT------%
%------MEDIA_VIDEO------%
%------MEDIA_AUDIO------%
%------OPTIONS_ORDER------%
%------NUMERICAL_RANGE------%
%------FREETEXT_CHARACTERS------%
%------FREETEXT_WORDS------%
%------FREETEXT_RULES------%
%------TRUEFALSE_THIRD_OPTIONS------%
%------TRUEFALSE_THIRD_OPTIONS_LABEL------%
%------DATETIME_PRECISION------%
%------DATETIME_RANGE------%
%------GROUPING------%
%------PARAMETERS_SYNC------%
%------TOLERANCE------%
% [ ] ABSOLUTE:N
% [ ] RELATIVE:N
% [ ] QUOTIENT
% [ ] QUOTIENT2
% [ ] QUOTIENT:SYNCED
% [ ] QUOTIENT2:SYNCED
%------GRAPH------%
%------SOLUTION_PENALTY------%
%------HINT_PENALTY------%
%------VIDEO_PENALTY------%
%------FILE_COUNT------%
%------FILE_TYPES------%
%------HOTSPOT_IMAGE------%
%------HOTSPOT_ZONES------%
%------TAGS------%
%------EXTERNAL_ID------%
```

---

## NUMERICAL — With parameterization and LaTeX

```
%------LANGUAGE------%
en
%------QUESTION!!------%
What is the area of a rectangle with width {w} and height {h}?
%------ANSWER!!------%
{w}*{h}
%------TYPE!!------%
% [ ] CHOICE
% [ ] MULTIPLE-CHOICE
% [ ] TRUE/FALSE
% [X] NUMERICAL
% [ ] EXPRESSION
% [ ] ORDER
% [ ] GROUPING
% [ ] PAIRING
% [ ] MATRIX
% [ ] MATRIX:EXPRESSION
% [ ] SET
% [ ] SET:TEXT
% [ ] DATE/TIME
% [ ] TEXT
% [ ] FREE-TEXT
% [ ] FILE
% [ ] HOTSPOT
% [ ] READING
% [ ] GENERIC
%------SUBJECT!------%
Mathematics
%------CATEGORY!------%
Geometry
%------MAIN_CATEGORY------%
%------PARAMETERS------%
{w; INTEGER; 2; 20} &&& {h; INTEGER; 2; 20}
%------CONSTRAINTS------%
%------POINTS------%
1
%------SUBSCORING------%
% [X] PROPORTIONAL
% [ ] LINEAR_SUBSTRACTED:N
% [ ] CUSTOM
% [ ] NONE
%------SUBPOINTS------%
%------MANUAL_SCORING------%
% [X] NO
% [ ] NOT_CORRECT
% [ ] ALWAYS
%------PENALTY_POINTS------%
%------PENALTY_SCORING------%
% [X] DEFAULT
% [ ] PER_ANSWER
% [ ] PER_QUESTION
%------OPTIONS------%
%------NOTE------%
Give your answer in square units.
%------PRIVATE_NOTE------%
%------EXPLANATION------%
Area = width × height = {w} × {h} = {w}*{h}
%------SOLUTION------%
%------SOLUTION_IMAGE------%
%------HINT------%
Recall: Area of rectangle = base × height
%------VIDEO------%
%------DIFFICULTY------%
2
%------ANSWER_REQUIRE------%
%------QUESTION_FORMAT------%
% [ ] NORMAL
% [X] LATEX
% [ ] LONG
%------ANSWER_FORMAT------%
%------SOURCE------%
%------TAG------%
%------DECIMALS------%
0
%------MAXIMUM_CHOICES------%
%------OPTIONS_FIX------%
%------ANSWER_ORDER------%
%------ANSWER_HIDE------%
%------ANSWER_LABEL------%
%------ANSWER_INDEFINITE------%
%------GROUP------%
%------EXPRESSION_CHECK------%
%------EXPRESSION_DECIMALS------%
%------EXPRESSION_RANDOM_TYPE------%
%------EXPRESSION_RANDOM_TRIES------%
%------EXPRESSION_RANDOM_RANGE------%
%------EXPRESSION_RANDOM_INSIDE------%
%------EXPRESSION_RANDOM_OUTSIDE------%
%------EXPRESSION_EXPLICIT_GOAL------%
%------EXPRESSION_EXTENDED------%
%------EXPRESSION_FUNCTIONS------%
%------EXPRESSION_VARIABLE------%
%------IMAGE------%
%------ATTACHMENT------%
%------MEDIA_VIDEO------%
%------MEDIA_AUDIO------%
%------OPTIONS_ORDER------%
%------NUMERICAL_RANGE------%
%------FREETEXT_CHARACTERS------%
%------FREETEXT_WORDS------%
%------FREETEXT_RULES------%
%------TRUEFALSE_THIRD_OPTIONS------%
%------TRUEFALSE_THIRD_OPTIONS_LABEL------%
%------DATETIME_PRECISION------%
%------DATETIME_RANGE------%
%------GROUPING------%
%------PARAMETERS_SYNC------%
%------TOLERANCE------%
% [ ] ABSOLUTE:N
% [ ] RELATIVE:N
% [ ] QUOTIENT
% [ ] QUOTIENT2
% [ ] QUOTIENT:SYNCED
% [ ] QUOTIENT2:SYNCED
%------GRAPH------%
%------SOLUTION_PENALTY------%
%------HINT_PENALTY------%
NONE
%------VIDEO_PENALTY------%
%------FILE_COUNT------%
%------FILE_TYPES------%
%------HOTSPOT_IMAGE------%
%------HOTSPOT_ZONES------%
%------TAGS------%
%------EXTERNAL_ID------%
```

---

## GROUPING — Assign items to groups

```
%------LANGUAGE------%
en
%------QUESTION!!------%
Classify these animals into the correct group.
%------ANSWER!!------%
Eagle >>> Bird &&& Sparrow >>> Bird &&& Salmon >>> Fish &&& Trout >>> Fish
%------TYPE!!------%
% [ ] CHOICE
% [ ] MULTIPLE-CHOICE
% [ ] TRUE/FALSE
% [ ] NUMERICAL
% [ ] EXPRESSION
% [ ] ORDER
% [X] GROUPING
% [ ] PAIRING
% [ ] MATRIX
% [ ] MATRIX:EXPRESSION
% [ ] SET
% [ ] SET:TEXT
% [ ] DATE/TIME
% [ ] TEXT
% [ ] FREE-TEXT
% [ ] FILE
% [ ] HOTSPOT
% [ ] READING
% [ ] GENERIC
%------SUBJECT!------%
Biology
%------CATEGORY!------%
Animal classification
%------MAIN_CATEGORY------%
%------PARAMETERS------%
%------CONSTRAINTS------%
%------POINTS------%
4
%------SUBSCORING------%
% [X] PROPORTIONAL
% [ ] LINEAR_SUBSTRACTED:N
% [ ] CUSTOM
% [ ] NONE
%------SUBPOINTS------%
%------MANUAL_SCORING------%
% [X] NO
% [ ] NOT_CORRECT
% [ ] ALWAYS
%------PENALTY_POINTS------%
%------PENALTY_SCORING------%
% [X] DEFAULT
% [ ] PER_ANSWER
% [ ] PER_QUESTION
%------OPTIONS------%
%------NOTE------%
%------PRIVATE_NOTE------%
%------EXPLANATION------%
%------SOLUTION------%
%------SOLUTION_IMAGE------%
%------HINT------%
%------VIDEO------%
%------DIFFICULTY------%
2
%------ANSWER_REQUIRE------%
%------QUESTION_FORMAT------%
% [X] NORMAL
% [ ] LATEX
% [ ] LONG
%------ANSWER_FORMAT------%
%------SOURCE------%
%------TAG------%
%------DECIMALS------%
%------MAXIMUM_CHOICES------%
%------OPTIONS_FIX------%
%------ANSWER_ORDER------%
%------ANSWER_HIDE------%
%------ANSWER_LABEL------%
%------ANSWER_INDEFINITE------%
%------GROUP------%
%------EXPRESSION_CHECK------%
%------EXPRESSION_DECIMALS------%
%------EXPRESSION_RANDOM_TYPE------%
%------EXPRESSION_RANDOM_TRIES------%
%------EXPRESSION_RANDOM_RANGE------%
%------EXPRESSION_RANDOM_INSIDE------%
%------EXPRESSION_RANDOM_OUTSIDE------%
%------EXPRESSION_EXPLICIT_GOAL------%
%------EXPRESSION_EXTENDED------%
%------EXPRESSION_FUNCTIONS------%
%------EXPRESSION_VARIABLE------%
%------IMAGE------%
%------ATTACHMENT------%
%------MEDIA_VIDEO------%
%------MEDIA_AUDIO------%
%------OPTIONS_ORDER------%
%------NUMERICAL_RANGE------%
%------FREETEXT_CHARACTERS------%
%------FREETEXT_WORDS------%
%------FREETEXT_RULES------%
%------TRUEFALSE_THIRD_OPTIONS------%
%------TRUEFALSE_THIRD_OPTIONS_LABEL------%
%------DATETIME_PRECISION------%
%------DATETIME_RANGE------%
%------GROUPING------%
%------PARAMETERS_SYNC------%
%------TOLERANCE------%
% [ ] ABSOLUTE:N
% [ ] RELATIVE:N
% [ ] QUOTIENT
% [ ] QUOTIENT2
% [ ] QUOTIENT:SYNCED
% [ ] QUOTIENT2:SYNCED
%------GRAPH------%
%------SOLUTION_PENALTY------%
%------HINT_PENALTY------%
%------VIDEO_PENALTY------%
%------FILE_COUNT------%
%------FILE_TYPES------%
%------HOTSPOT_IMAGE------%
%------HOTSPOT_ZONES------%
%------TAGS------%
%------EXTERNAL_ID------%
```

---

## HOTSPOT — Mark zones on image

```
%------LANGUAGE------%
en
%------QUESTION!!------%
Click on the heart in the diagram.
%------ANSWER!!------%
Heart
%------TYPE!!------%
% [ ] CHOICE
% [ ] MULTIPLE-CHOICE
% [ ] TRUE/FALSE
% [ ] NUMERICAL
% [ ] EXPRESSION
% [ ] ORDER
% [ ] GROUPING
% [ ] PAIRING
% [ ] MATRIX
% [ ] MATRIX:EXPRESSION
% [ ] SET
% [ ] SET:TEXT
% [ ] DATE/TIME
% [ ] TEXT
% [ ] FREE-TEXT
% [ ] FILE
% [X] HOTSPOT
% [ ] READING
% [ ] GENERIC
%------SUBJECT!------%
Biology
%------CATEGORY!------%
Human anatomy
%------MAIN_CATEGORY------%
%------PARAMETERS------%
%------CONSTRAINTS------%
%------POINTS------%
1
%------SUBSCORING------%
% [X] PROPORTIONAL
% [ ] LINEAR_SUBSTRACTED:N
% [ ] CUSTOM
% [ ] NONE
%------SUBPOINTS------%
%------MANUAL_SCORING------%
% [X] NO
% [ ] NOT_CORRECT
% [ ] ALWAYS
%------PENALTY_POINTS------%
%------PENALTY_SCORING------%
% [X] DEFAULT
% [ ] PER_ANSWER
% [ ] PER_QUESTION
%------OPTIONS------%
%------NOTE------%
%------PRIVATE_NOTE------%
%------EXPLANATION------%
%------SOLUTION------%
%------SOLUTION_IMAGE------%
%------HINT------%
%------VIDEO------%
%------DIFFICULTY------%
2
%------ANSWER_REQUIRE------%
%------QUESTION_FORMAT------%
% [X] NORMAL
% [ ] LATEX
% [ ] LONG
%------ANSWER_FORMAT------%
%------SOURCE------%
%------TAG------%
%------DECIMALS------%
%------MAXIMUM_CHOICES------%
%------OPTIONS_FIX------%
%------ANSWER_ORDER------%
%------ANSWER_HIDE------%
%------ANSWER_LABEL------%
%------ANSWER_INDEFINITE------%
%------GROUP------%
%------EXPRESSION_CHECK------%
%------EXPRESSION_DECIMALS------%
%------EXPRESSION_RANDOM_TYPE------%
%------EXPRESSION_RANDOM_TRIES------%
%------EXPRESSION_RANDOM_RANGE------%
%------EXPRESSION_RANDOM_INSIDE------%
%------EXPRESSION_RANDOM_OUTSIDE------%
%------EXPRESSION_EXPLICIT_GOAL------%
%------EXPRESSION_EXTENDED------%
%------EXPRESSION_FUNCTIONS------%
%------EXPRESSION_VARIABLE------%
%------IMAGE------%
%------ATTACHMENT------%
%------MEDIA_VIDEO------%
%------MEDIA_AUDIO------%
%------OPTIONS_ORDER------%
%------NUMERICAL_RANGE------%
%------FREETEXT_CHARACTERS------%
%------FREETEXT_WORDS------%
%------FREETEXT_RULES------%
%------TRUEFALSE_THIRD_OPTIONS------%
%------TRUEFALSE_THIRD_OPTIONS_LABEL------%
%------DATETIME_PRECISION------%
%------DATETIME_RANGE------%
%------GROUPING------%
%------PARAMETERS_SYNC------%
%------TOLERANCE------%
% [ ] ABSOLUTE:N
% [ ] RELATIVE:N
% [ ] QUOTIENT
% [ ] QUOTIENT2
% [ ] QUOTIENT:SYNCED
% [ ] QUOTIENT2:SYNCED
%------GRAPH------%
%------SOLUTION_PENALTY------%
%------HINT_PENALTY------%
%------VIDEO_PENALTY------%
%------FILE_COUNT------%
%------FILE_TYPES------%
%------HOTSPOT_IMAGE------%
anatomy-diagram.png
%------HOTSPOT_ZONES------%
{circle; 45; 38; 8}
%------TAGS------%
%------EXTERNAL_ID------%
```

---

## TRUE/FALSE — With third option

```
%------LANGUAGE------%
en
%------QUESTION!!------%
Classify the following statements about photosynthesis.
%------ANSWER!!------%
Plants absorb CO2 during photosynthesis. &&& Sunlight is required for photosynthesis.
%------TYPE!!------%
% [ ] CHOICE
% [ ] MULTIPLE-CHOICE
% [X] TRUE/FALSE
% [ ] NUMERICAL
...rest of type checkboxes as [ ]...
%------SUBJECT!------%
Biology
%------CATEGORY!------%
Photosynthesis
%------MAIN_CATEGORY------%
%------OPTIONS------%
Plants release CO2 during photosynthesis. &&& Photosynthesis occurs in animal cells.
...remaining sections blank...
%------TRUEFALSE_THIRD_OPTIONS------%
I don't know
%------TRUEFALSE_THIRD_OPTIONS_LABEL------%
Not sure
...remaining sections blank...
```

---

## Key Reminders

- TYPE in EDU uses `NUMERICAL` not `NUMERIC`
- `EXPRESSION_EXPLICIT_GOAL` in EDU = `EXPRESSION_RANDOM_GOAL` in XLSX
- Template defaults `QUESTION_FORMAT` to `LATEX` — change to `NORMAL` when no math
- `SUBSCORING` spells it `LINEAR_SUBSTRACTED` (with D, not C)  
- ALL 74 section headers must appear in every file, even if content is empty
- Section order must exactly match the template order

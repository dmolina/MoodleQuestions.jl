# CHANGELOG

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a Changelog](http://keepachangelog.com/).

## 0.2.9 - (2024-12-15)
---

### New

* Using SimpleTranslations 2.0 for avoiding deprecated Formatting package.

* Fix: error with 10 as right answers.

## 0.2.4 - (2021-01-26)
---

### New
* New Question short format (with right answer between []).

## 0.2.3 - (2020-06-20)
---

### New
* Automatic convert boolean with penalty to multichoice.

### Changes

### Fixes
* Management error with unexpected error.

### Breaks


## 0.2.2 - (2020-06-16)
---

### New
* Automatic convert boolean with penalty to multichoice.
* Add Question type Essay, surround the question with '[' and ']'.

### Changes

### Fixes
* Management error with unexpected error.
* Penalty Functions in multioptions.
* Error with boolean questions.

### Breaks



## 0.2.1 - (2020-06-02)
---

### New
* Supported questions with multiple options.
* Using SimpleTranslations to translate errors.


## 0.2.0 - (2020-05-11)

---

### New
* More tests.
* serve_quiz mode, answering by port and replying the quiz.
* Add questions True/False with a + or - at the end of sentence.

### Changes
* Refactor read_txt to make it cleaner.

### Fixes
* Error with spaces in read_txt.

### Breaks
* save_to_moodle by adding penaly parameters.

---

## 0.1.0 - (2020-04-15)
---

Initial version.

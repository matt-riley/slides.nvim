# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.5](https://github.com/matt-riley/slides.nvim/compare/v0.1.4...v0.1.5) (2026-07-11)


### Features

* add asynchronous process runner ([646b015](https://github.com/matt-riley/slides.nvim/commit/646b0153158e31f96370cec899dafb274ba5cf68))
* build safe language execution requests ([ba59934](https://github.com/matt-riley/slides.nvim/commit/ba599341a7faf3428cf7b8f9445ddbd645cca108))
* execute slide code asynchronously ([f90aee1](https://github.com/matt-riley/slides.nvim/commit/f90aee1f49b02a0489e6a7907224f1cf88ee51de))
* track slide execution jobs ([6da60b8](https://github.com/matt-riley/slides.nvim/commit/6da60b8bbc557cb890a9bcc96e8e72e61e8b3cc2))


### Bug Fixes

* cancel active execution before preparing code ([0aeea79](https://github.com/matt-riley/slides.nvim/commit/0aeea79d87c4f1d7d9798c78ae4a1a7dff7bced8))
* **ci:** report LuaLS diagnostics before failing ([1074a6d](https://github.com/matt-riley/slides.nvim/commit/1074a6d98ed24008070d6e55b21634ce595ca25a))
* keep execution generations monotonic ([bc84a66](https://github.com/matt-riley/slides.nvim/commit/bc84a66d31db08fdb7afd691390250cd5f923d08))

## [0.1.4](https://github.com/matt-riley/slides.nvim/compare/v0.1.3...v0.1.4) (2026-02-28)


### Bug Fixes

* resolve typecheck CI and duplicate PR runs ([b908372](https://github.com/matt-riley/slides.nvim/commit/b90837217332e9fde974cdaf5c1baabac626dfbb))

## [0.1.3](https://github.com/matt-riley/slides.nvim/compare/v0.1.2...v0.1.3) (2026-02-27)


### Features

* add LuaLS typing baseline and CI typecheck ([045c337](https://github.com/matt-riley/slides.nvim/commit/045c337ef89d3425324bf622dddb88a26e56cb43))

## [0.1.2](https://github.com/matt-riley/slides.nvim/compare/v0.1.1...v0.1.2) (2026-02-27)


### Bug Fixes

* resolve failing CI workflows ([e2bcb80](https://github.com/matt-riley/slides.nvim/commit/e2bcb80d733834fef09ce243ce5e362201617adb))

## [0.1.1](https://github.com/matt-riley/slides.nvim/compare/v0.1.0...v0.1.1) (2026-02-27)


### Features

* add fragments/reveals ([d0d9b1c](https://github.com/matt-riley/slides.nvim/commit/d0d9b1c0a70d30ea060b0dbaefe93d02d2a74db3))
* add go/ts code execution ([9e4d7c3](https://github.com/matt-riley/slides.nvim/commit/9e4d7c3e4b9d5093e0fa63375af1d55742f79df0))
* add interactive features (live reload, code exec, preprocessing) ([cb93329](https://github.com/matt-riley/slides.nvim/commit/cb93329c8fbbdfb322d2396cffb4940f2a154ac6))
* add release workflows and improve docs generation ([c99cfa2](https://github.com/matt-riley/slides.nvim/commit/c99cfa277043d3b1dd5aa49debb29bbc3b56be62))


### Bug Fixes

* avoid wrapping from window columns ([c99c7be](https://github.com/matt-riley/slides.nvim/commit/c99c7beee3107e2917a4ff9e020f4d1ee1570092))
* make fragment separators tolerant of whitespace ([232d1bc](https://github.com/matt-riley/slides.nvim/commit/232d1bcb7eb93cdd5c9d6aba7fbcb842fd05b3e3))
* preserve highlighting in fullscreen ([21996f3](https://github.com/matt-riley/slides.nvim/commit/21996f386f02968fb72bc5b28726a21c9884c888))
* recenter fullscreen slide content ([1c1403d](https://github.com/matt-riley/slides.nvim/commit/1c1403d44034e36ca974b5d1998a497333def563))
* render execution output in fullscreen footer ([dc7ba79](https://github.com/matt-riley/slides.nvim/commit/dc7ba793e8ab0f5b64bf1f75d1419b03dbc206be))

## [Unreleased]

---
name: tuning-panel
description: Create a bespoke parameter tuning panel for the current task
arguments:
  - name: target
    description: What to create tuning controls for (e.g., "animation", "layout", "the Card component")
    required: false
---

Create a tuning panel following the **tuning-panel skill**.

**Target:** $ARGUMENTS

If no target specified, analyze the current context to determine what the user is working on and create appropriate tuning controls.

**Key requirements:**
1. Surface ALL tunable parameters exhaustively
2. Use platform-appropriate library (leva for React, tweakpane for vanilla JS, native controls for Swift)
3. Wrap in debug mode so it's not visible in production
4. Include "Copy for LLM" export functionality

Follow the tuning-panel skill for complete implementation guidance.

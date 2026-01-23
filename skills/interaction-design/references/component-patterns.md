# Component Interaction Patterns

Detailed interaction patterns for common UI components, with attention to user goals, meaning, and error prevention.

## Table of Contents
- [Pattern Philosophy](#pattern-philosophy)
- [Forms & Inputs](#forms--inputs)
- [Modals & Dialogs](#modals--dialogs)
- [Dropdowns & Menus](#dropdowns--menus)
- [Drag & Drop](#drag--drop)
- [Lists & Tables](#lists--tables)
- [Navigation](#navigation)
- [Search](#search)
- [Notifications & Toasts](#notifications--toasts)
- [Tooltips & Popovers](#tooltips--popovers)
- [Sliders & Range Inputs](#sliders--range-inputs)
- [Date & Time Pickers](#date--time-pickers)

---

## Pattern Philosophy

Before implementing any pattern, ask:
1. **What is the user's goal?** Not "use this component" but "accomplish this task"
2. **Is this component necessary?** Could we eliminate it entirely?
3. **What errors might occur?** How do we prevent or recover from them?
4. **What should the user feel?** Confidence? Delight? Relief?

Components are means, not ends. The best component is often no component at all.

---

## Forms & Inputs

### User Goal Context

Users filling forms rarely want to "fill a form." They want to:
- Complete a purchase
- Submit an application
- Update their settings
- Send a message

Every field is friction. Eliminate fields that don't directly serve the goal.

### Text Inputs

**States & Meaning**
| State | Appearance | Emotional Tone |
|-------|------------|----------------|
| Empty | Placeholder, subtle border | Ready, inviting |
| Focused | Ring/outline, cursor | Engaged, active |
| Filled | Value visible | Progressing |
| Error | Red indicator, message below | Recoverable, guided |
| Disabled | Reduced opacity | Unavailable (explain why) |
| Valid | Green check (optional) | Confidence, progress |

**Error Prevention**
- Use input constraints (type="email", maxlength)
- Auto-format as user types (phone numbers, credit cards)
- Show format hints before errors occur
- Validate on blur, re-validate on change after error
- Never clear user input on error

**Label Patterns**
- Always use visible labels (not placeholder-only)
- Float label: compact, modern feel
- Static label: clearest, most accessible
- Associate labels with inputs (`for`/`id`) for screen readers

**Keyboard**
- Tab: next field
- Shift+Tab: previous field
- Enter: submit (single-line) or next field
- Escape: blur, optionally revert

### Textareas

- Auto-grow height as content grows (with max-height)
- Character count for limited fields (shows remaining, not error at limit)
- Resize handle if appropriate

### Checkboxes & Radio Buttons

**Goal context:** Selection is a micro-commitment. Make the commitment clear.

**Checkbox States**
- Unchecked → Checked → (Indeterminate for mixed children)
- Click anywhere on label to toggle
- Focus ring on control, not label

**Radio Groups**
- Arrow keys navigate between options
- Only one radio receives Tab focus
- Selection can follow focus (faster) or require explicit activation (safer for consequential choices)

### Form Layout

**Single Column** (default)
- Labels above inputs for easy scanning
- Group related fields with spacing or dividers
- Primary action left-aligned (right in RTL)

**Progressive Disclosure**
- Show only required fields initially
- Reveal optional/advanced fields on demand
- Don't overwhelm; respect the user's attention

**Error Summary**
- On submit failure, summarize errors at top
- Link each error to its field
- Focus the summary or first error

---

## Modals & Dialogs

### When to Use Modals

**Use modals when:**
- User must make a decision before continuing
- Action is destructive and needs confirmation
- Context isolation reduces errors (complex wizards)
- System requires exclusive attention (authentication)

**Avoid modals when:**
- User needs to reference content behind the modal
- Trial-and-error adjustment is needed (use inline/inspector)
- Action can easily be undone (use undo, not confirmation)
- You're using a modal because it's "easy" to implement

### Modal Types & User Goals

| Type | User Goal | Design Priorities |
|------|-----------|-------------------|
| Alert | Understand a situation | Clear message, single action |
| Confirm | Make a consequential decision | Clear stakes, distinct options |
| Prompt | Provide a single piece of info | Fast completion, clear purpose |
| Form | Complete a multi-step task | Progress visibility, save state |
| Drawer | Access details/settings | Easy dismiss, no obstruction |

### Opening

- Animate from trigger element (connection) or center (focus)
- Duration: 200-300ms ease-out
- Focus first interactive element or close button
- Prevent background scroll

### Focus Management (Critical)

```
1. Store previous focus location
2. Move focus into modal (first focusable element)
3. Trap focus within modal (Tab cycles through)
4. On close, restore focus to trigger element
```

### Closing

- Close button (X) always visible
- Escape key closes (unless destructive action in progress)
- Backdrop click closes (configurable—disable for critical confirmations)
- Warn on unsaved changes: "You have unsaved changes. Discard?"

### Error Handling in Modals

- If form submission fails, keep modal open
- Show errors inline within the modal
- Don't close on error—user loses context

### Stacking Modals

**Avoid when possible.** Stacking modals indicates a flow design problem.

If truly necessary:
- Each modal gets its own backdrop layer
- Escape closes topmost only
- Focus trapped in topmost
- Consider: should this be a multi-step wizard instead?

---

## Dropdowns & Menus

### User Goal Context

Dropdowns present choices. The goal is to make the right choice quickly and confidently.

### Activation

- Click to open (not hover—accessibility requirement)
- Enter/Space opens when trigger focused
- Arrow Down opens and selects first item

### Keyboard Navigation

| Key | Action |
|-----|--------|
| ↓ | Next item |
| ↑ | Previous item |
| Home | First item |
| End | Last item |
| Enter/Space | Select current item |
| Escape | Close, return focus to trigger |
| Type character | Jump to item starting with that character |

### Positioning

- Default: below trigger
- Flip if insufficient space
- Maintain 8px from viewport edges

### Menu Item Design

| State | Appearance | Notes |
|-------|------------|-------|
| Default | Normal text | — |
| Hover/Focus | Background highlight | — |
| Selected | Checkmark | For current value |
| Disabled | Reduced opacity | Skip in keyboard nav |
| Destructive | Red text | delete, remove |

### Error Prevention

- Disable unavailable options (don't hide them—explain why)
- For long lists, add search/filter
- Group related items with headers
- Show selected value in trigger (never unclear state)

### Nested Menus

- Open on hover with 200ms delay
- Arrow Right opens submenu
- Arrow Left closes submenu
- Safe triangle for diagonal mouse movement

---

## Drag & Drop

### User Goal Context

Drag and drop enables direct manipulation—physically moving objects. The goal is natural, intuitive rearrangement.

### Signifiers (Affordances Made Visible)

- Drag handle: grip icon (⋮⋮) or entire item
- Cursor: `grab` on hover, `grabbing` during drag
- Lift effect on drag start (shadow + slight scale)

### During Drag

**Visual Feedback**
- Ghost/preview following cursor (semi-transparent)
- Placeholder in original position
- Valid drop zones highlighted
- Invalid zones dimmed or unchanged
- Insertion indicator (line) shows where item will land

**Auto-Scroll**
- Scroll container when dragging near edges
- Accelerate near very edge

### Drop Feedback

- Animate item into new position (200-300ms)
- Remove ghost immediately
- Brief highlight on dropped item (confirmation)

### Keyboard Alternative (Required)

- Space: select item for move
- Arrow keys: navigate through positions
- Space/Enter: drop at current position
- Escape: cancel move, return to original

### Multi-Item Drag

- Badge showing count ("3 items")
- Visual stack of selected items
- All items move as unit

### Error Recovery

- Undo for accidental drops
- Escape cancels during drag
- Clear visual state if drop fails

---

## Lists & Tables

### User Goal Context

Lists and tables help users find, compare, and act on items. Goals include:
- Find a specific item
- Compare items to make a choice
- Perform actions on one or multiple items
- Understand patterns across data

### Selection

**Single Select**
- Click to select
- Arrow keys move selection
- Enter activates selected item

**Multi-Select**
- Click toggles individual selection
- Shift+Click for range
- Cmd/Ctrl+Click for non-contiguous
- Checkbox column for explicit multi-select

### Sorting

- Click column header to sort
- Click again to reverse
- Visual indicator (arrow) shows sort state
- Remember sort preference (if appropriate)

### Filtering

- Filter controls above list
- Instant filtering (debounce 150-300ms)
- Show count: "23 of 156 items"
- Clear all filters button when active
- Preserve filters across sessions (if appropriate)

### Empty States (Dramatic Moments)

| State | Narrative | Design |
|-------|-----------|--------|
| Initial empty | "Your story hasn't begun" | Invitation, clear CTA to add first item |
| No results (filter) | "Nothing matches" | Suggestion to adjust filters, link to clear |
| Error | "Something went wrong" | Empathy, retry button, explain if possible |
| Cleared/Complete | "All done!" | Celebration if appropriate, next steps |

### Row Actions

- Hover actions: appear on row hover
- Context menu: right-click or overflow (⋮)
- Swipe actions: mobile (always provide undo)
- Inline edit: click cell to edit

### Infinite Scroll / Virtualization

- Load more 2-3 screens before bottom
- Show loading indicator during fetch
- Maintain scroll position on data updates
- Virtualize for performance (render only visible)

---

## Navigation

### User Goal Context

Navigation helps users understand where they are and how to get where they want to go. The goal is orientation and confidence.

### Tab Navigation

- Tabs as `role="tablist"` with `role="tab"` children
- Arrow keys move between tabs
- Tab/Shift+Tab exits tablist
- Active tab: `aria-selected="true"`, clear visual indicator

### Breadcrumbs

**What they communicate:** "You are here, and here's how you got here."

- Current page: text only (not a link)
- Separator between items (/ or >)
- Truncate middle items with "..." for long paths
- Click any ancestor to navigate up

### Pagination

- Show current page and total
- Previous/Next buttons (disabled at bounds)
- Direct page input for large page counts
- Consider: is pagination better than infinite scroll for this use case?

### Sidebar Navigation

- Collapsible: icon-only or full labels
- Nested items: expand/collapse with disclosure
- Current item: strong visual indicator
- Keyboard: Arrow keys navigate, Enter activates

---

## Search

### User Goal Context

Search users have a target in mind. Help them find it quickly, or learn it doesn't exist.

### Search Input

- Magnifying glass icon (left, signifies purpose)
- Clear button (right, appears when filled)
- Escape clears and closes results
- Placeholder suggests what can be searched

### Instant Search

- Debounce input (150-300ms)
- Show loading state in results area
- Minimum characters (2-3) before searching
- Highlight matching text in results

### Search Results

- Show count: "12 results for 'widget'"
- Group by type if mixed content
- No results: helpful suggestions, check spelling
- Recent searches when input empty

### Command Palette

- Open: Cmd/Ctrl+K
- Fuzzy matching on command names
- Recent commands at top
- Category headers
- Keyboard-first: arrows + Enter

---

## Notifications & Toasts

### User Goal Context

Notifications inform users of events they didn't directly trigger. The goal is awareness without disruption.

### When to Notify

**Notify for:**
- Completion of background tasks
- Important state changes
- Errors requiring attention
- Time-sensitive information

**Don't notify for:**
- Every action the user just performed (use inline feedback)
- Low-importance information
- Marketing messages (unless explicitly opted in)

### Positioning

- Top-right or bottom-right (most common)
- Top-center for critical alerts
- Stack vertically with 8-12px gap
- New notifications push others

### Auto-Dismiss Timing

| Type | Duration | Auto-dismiss? | Rationale |
|------|----------|---------------|-----------|
| Success | 3-5s | Yes | Confirmation, low urgency |
| Info | 5-7s | Yes | Awareness, low urgency |
| Warning | 7-10s | Optional | May need action |
| Error | Persistent | No | Requires attention |

### Interaction

- Hover pauses auto-dismiss
- Close button always visible
- Action button: "Undo", "View", "Retry"
- Swipe to dismiss (mobile)

### Animation

- Enter: slide + fade (200-300ms)
- Exit: fade + slide (150-200ms)
- Stack reflow: animate position changes

---

## Tooltips & Popovers

### Tooltips

**Purpose:** Provide helpful context for ambiguous elements.

**When to use:**
- Icon-only buttons needing labels
- Truncated text needing full display
- Form fields needing clarification

**When NOT to use:**
- Critical information (use visible labels)
- Mobile-primary interfaces (hover-triggered)
- Lengthy content (use popovers)

**Behavior:**
- Show on hover after 300-500ms delay
- Hide immediately on mouse leave
- Show on focus for keyboard users
- Position: above by default, flip if clipped
- Content: text only, 1-2 lines max

### Popovers

**Purpose:** Provide interactive content in context.

- Trigger: click (not hover)
- Can contain interactive elements
- Dismiss: click outside, Escape, explicit close
- Arrow pointing to trigger
- Focus trap if contains form elements

---

## Sliders & Range Inputs

### User Goal Context

Sliders let users explore a value space. The goal is finding the right value through direct manipulation.

### When Sliders Excel

- Imprecise values where "about right" suffices
- Exploring a range to see effects
- Values that benefit from relative positioning

### When Text Input is Better

- Precise values needed (type "24px" vs. drag to 24)
- Very large ranges
- Values with specific meaningful numbers

### Single Value Slider

- Thumb: 20-24px minimum (44px for touch)
- Track: filled portion shows progress to value
- Value label: above thumb or in tooltip during drag
- Tick marks for discrete/meaningful values

### Range Slider

- Two thumbs, independently draggable
- Thumbs cannot cross
- Filled track between thumbs

### Keyboard (Required)

- ← / →: decrease/increase by step
- Page Up/Down: larger jumps
- Home/End: min/max values

### Accessibility

- `role="slider"` with `aria-valuemin`, `aria-valuemax`, `aria-valuenow`
- `aria-valuetext` for human-readable: "50%" or "$500"
- Announce value changes

---

## Date & Time Pickers

### User Goal Context

Users selecting dates are usually scheduling something or filtering by time. The goal is choosing the right date quickly and confidently.

### Date Picker

**Input States**
- Text input with format hint (MM/DD/YYYY or locale-appropriate)
- Calendar icon triggers picker
- Support manual typing for power users

**Calendar View**
- Month/year header with navigation
- Day grid with weekday headers
- Today: highlighted (subtle)
- Selected: filled/prominent
- Disabled: dimmed (past dates, unavailable slots)

**Keyboard**
- Arrow keys navigate days
- Page Up/Down: months
- Home/End: first/last of month
- Enter: select and close

### Date Range Picker

- Two inputs or single with separator
- Visual range highlight in calendar
- Click start, then end
- Presets: "Last 7 days", "This month"

### Time Picker

- Input with format hint
- Dropdown with intervals (15-30 min)
- Allow manual entry for precise times

### Error Prevention

- Disable unavailable dates (don't let users select then show error)
- Clear format hints
- Accept multiple input formats, normalize display
- Show timezone clearly when relevant

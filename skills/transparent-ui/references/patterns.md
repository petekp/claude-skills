# Visualization Patterns by Domain

Detailed patterns for making different system types transparent. Each section includes:
- What to capture
- Visualization layout
- Key interactive features
- Example code snippets

---

## State Machines

**What to capture**:
- All possible states (as nodes)
- All transitions (as directed edges)
- Current state
- Transition history with timestamps
- Event that triggered each transition
- Guard conditions that blocked transitions

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [State Graph]                    [History Panel]   │
│                                                     │
│    ┌───────┐    click    ┌─────────┐               │
│    │ idle  │ ──────────▶ │ loading │               │
│    └───────┘             └─────────┘               │
│        ▲                      │                     │
│        │ reset           success                    │
│        │                      ▼                     │
│    ┌───────┐             ┌─────────┐               │
│    │ error │ ◀── fail ── │  ready  │  ● current   │
│    └───────┘             └─────────┘               │
│                                                     │
│  [Event Trigger Buttons]     [State Inspector]     │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Click state to see its definition and possible exits
- Click edge to see transition conditions/actions
- Trigger buttons to fire events manually
- History shows transition log with replay capability

**Instrumentation**:
```typescript
type TransitionRecord = {
  from: string;
  to: string;
  event: string;
  timestamp: number;
  context?: unknown;
};

const history: TransitionRecord[] = [];

function instrumentStateMachine(machine) {
  return {
    ...machine,
    transition(state, event) {
      const next = machine.transition(state, event);
      history.push({ from: state, to: next, event, timestamp: Date.now() });
      window.dispatchEvent(new CustomEvent('sm:transition', { detail: history.at(-1) }));
      return next;
    }
  };
}
```

---

## React Rendering / Update Cycles

**What to capture**:
- Component tree structure
- Which components re-rendered
- Why they re-rendered (props changed, state changed, parent rendered)
- Render timing/duration
- Props diff between renders

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [Component Tree]                 [Render Log]      │
│                                                     │
│  App                              14:32:01.234      │
│  ├─ Header                        UserList rendered │
│  ├─ UserList ● (just rendered)    - props.filter   │
│  │  ├─ UserCard                     changed         │
│  │  ├─ UserCard ●                                   │
│  │  └─ UserCard                   14:32:01.189      │
│  └─ Footer                        UserCard rendered │
│                                   - parent rendered │
│                                                     │
│  [Prop Inspector]                [Render Flame]    │
│  UserList props:                  ████████ 12ms    │
│  - filter: "active" (changed!)    ███ 3ms          │
│  - users: [...] (same ref)                         │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Click component to inspect current props/state
- Highlight renders with color intensity based on frequency
- Show prop diffs on hover
- Filter to show only re-rendered components

**Instrumentation**:
```typescript
const RenderTracker = createContext<{
  log: (component: string, reason: string) => void;
}>({ log: () => {} });

function useTrackRender(name: string, props: Record<string, unknown>) {
  const prevProps = useRef(props);
  const { log } = useContext(RenderTracker);

  useEffect(() => {
    const changes = Object.keys(props).filter(
      k => !Object.is(props[k], prevProps.current[k])
    );
    log(name, changes.length ? `props changed: ${changes.join(', ')}` : 'parent rendered');
    prevProps.current = props;
  });
}
```

---

## Data Flow / Pipelines

**What to capture**:
- Data sources (API calls, user input, stores)
- Transformation steps
- Current data at each stage
- Data shape/type at each node
- Timing of data propagation

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [Pipeline Graph]                                   │
│                                                     │
│  ┌──────────┐     ┌───────────┐     ┌──────────┐  │
│  │ API Call │ ──▶ │ Transform │ ──▶ │  Filter  │  │
│  │ /users   │     │ normalize │     │ isActive │  │
│  │ 127 items│     │ 127 items │     │ 43 items │  │
│  └──────────┘     └───────────┘     └──────────┘  │
│       │                                    │        │
│       ▼                                    ▼        │
│  [Raw Data]                         [Final Data]   │
│  { data: [...] }                   [UserCard x43]  │
│                                                     │
│  [Inject Test Data]          [Step Through Mode]   │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Click node to see full data payload
- Inject data at any point to test downstream
- Step-through mode to watch data propagate
- Show data shape/schema at each stage

---

## Event Systems (Pub/Sub, Message Queues)

**What to capture**:
- Event types and their payloads
- Publishers (who emits)
- Subscribers (who listens)
- Event propagation path
- Timing between emit and handle

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [Event Timeline]                                   │
│  ──────────────────────────────────────────────▶ t  │
│  │    │         │              │                    │
│  click         hover         submit                 │
│  Button        Card          Form                   │
│    │             │              │                   │
│    ▼             ▼              ▼                   │
│  [Analytics] [Tooltip]    [Validator, API]         │
│                                                     │
│  [Event Inspector]              [Fire Custom Event] │
│  submit @ 14:32:01              Type: [________]   │
│  From: Form                     Payload: {...}     │
│  To: Validator (2ms), API (3ms) [Fire]             │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Hover event to see full payload
- Click to see all handlers and their execution time
- Fire custom events with arbitrary payloads
- Filter by event type or source

---

## Algorithms (Sorting, Pathfinding, Search)

**What to capture**:
- Data structure state at each step
- Currently active/comparing elements
- Decision points and choices made
- Iteration count, comparisons, swaps
- Final result path

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [Data Structure View]         [Stats]              │
│                                                     │
│  [3] [7] [1] [9] [2] [5]       Step: 4/12          │
│       ▲   ▲                    Comparisons: 7       │
│       │   └── comparing        Swaps: 3            │
│       └────── pivot                                 │
│                                                     │
│  [Step Controls]               [Speed]              │
│  ◀◀  ◀  ▶  ▶▶  [Reset]        ●───────○ slow→fast │
│                                                     │
│  [Step Log]                                        │
│  4. Compare 7 > 1: swap                            │
│  3. Compare 3 > 7: no swap                         │
│  2. Set pivot = 3                                  │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Step forward/backward through algorithm
- Adjustable speed for continuous play
- Highlight active elements
- Show decision rationale at each step

**Instrumentation pattern**:
```typescript
function* quickSort(arr: number[]): Generator<AlgorithmStep> {
  // Yield state at each step for visualization
  yield { type: 'start', data: [...arr] };

  function* partition(low: number, high: number) {
    const pivot = arr[high];
    yield { type: 'pivot', index: high, value: pivot };

    let i = low - 1;
    for (let j = low; j < high; j++) {
      yield { type: 'compare', indices: [j, high] };
      if (arr[j] < pivot) {
        i++;
        [arr[i], arr[j]] = [arr[j], arr[i]];
        yield { type: 'swap', indices: [i, j], data: [...arr] };
      }
    }
    // ...
  }
  // ...
}
```

---

## Animation Systems

**What to capture**:
- Animation timeline with keyframes
- Current progress (0-1)
- Easing curve visualization
- Active animations and their targets
- Animation state (playing, paused, finished)

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [Timeline Scrubber]                                │
│  0%━━━━━━━━━●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━100%  │
│            42%                                      │
│                                                     │
│  [Easing Curve]        [Active Animations]          │
│    ╭──────╮           opacity: 0.42 → 1.0          │
│   ╱        ╲          x: 120px → 0px               │
│  ╱          ──        scale: 0.8 → 1.0             │
│  ease-out-cubic                                     │
│                                                     │
│  [Keyframes]                                        │
│  0%    25%    50%    75%    100%                   │
│  ●─────●─────────────●──────●                      │
│                                                     │
│  [Controls]  ◀◀  ◀  ▶  ▶▶  [0.5x] [1x] [2x]       │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Drag scrubber to any point in animation
- Visualize easing curve
- Speed controls
- Trigger animation restart

---

## CSS / Layout Calculations

**What to capture**:
- Computed styles vs declared styles
- Box model values (margin, border, padding, content)
- Flexbox/Grid resolution (how space is distributed)
- Constraint sources (what rule set each value)
- Cascade order for conflicting rules

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [Element Selector]                                 │
│  <div class="card flex-1 p-4">                     │
│                                                     │
│  [Box Model]                   [Flex Distribution]  │
│  ┌─────────margin: 0───────┐   Container: 800px    │
│  │ ┌───border: 1px───────┐ │   ├─ item-1: 200px   │
│  │ │ ┌──padding: 16px──┐ │ │   ├─ item-2: 400px   │
│  │ │ │                 │ │ │   └─ item-3: 200px   │
│  │ │ │  content: 280px │ │ │                       │
│  │ │ │                 │ │ │   flex-1 = 200px      │
│  │ │ └─────────────────┘ │ │   (basis:0 + 1*200)   │
│  │ └─────────────────────┘ │                       │
│  └─────────────────────────┘                       │
│                                                     │
│  [Style Source]                                     │
│  width: 280px ← .card { width: 280px } (card.css:12)│
│  padding: 16px ← .p-4 (Tailwind)                   │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Click any element to inspect
- Hover style to see source rule
- Toggle styles on/off to see effect
- Visualize flex/grid space distribution

---

## Database Queries / ORM Operations

**What to capture**:
- Query being executed (SQL or ORM method)
- Parameters and their values
- Execution time
- Result count and sample data
- Query plan (if available)

**Visualization layout**:
```
┌─────────────────────────────────────────────────────┐
│  [Query Log]                                        │
│                                                     │
│  14:32:01 SELECT * FROM users WHERE active = $1    │
│           params: [true]                            │
│           → 43 rows, 12ms                          │
│                                                     │
│  14:32:00 SELECT * FROM posts WHERE user_id = $1   │
│           params: [123]                             │
│           → 5 rows, 3ms                            │
│                                                     │
│  [Query Inspector]             [N+1 Detector]       │
│  Expand query to see:          ⚠️ Similar query     │
│  - Full SQL                    executed 15 times    │
│  - Query plan                  in 200ms window      │
│  - Sample results                                   │
│                                                     │
│  [Run Custom Query]                                 │
│  SELECT _______________  [Execute]                  │
└─────────────────────────────────────────────────────┘
```

**Interactive features**:
- Expand query to see full SQL and results
- Detect N+1 query patterns
- Run custom queries for testing
- Show query plan visualization

---

## General Implementation Notes

**Connecting visualization to live system**:
```typescript
// In debug route
const [history, setHistory] = useState<Event[]>([]);

useEffect(() => {
  const handler = (e: CustomEvent) => {
    setHistory(prev => [...prev, e.detail]);
  };
  window.addEventListener('debug:event', handler);
  return () => window.removeEventListener('debug:event', handler);
}, []);
```

**Time-travel implementation**:
```typescript
function useTimeTravel<T>(history: T[]) {
  const [index, setIndex] = useState(history.length - 1);

  return {
    current: history[index],
    canGoBack: index > 0,
    canGoForward: index < history.length - 1,
    goBack: () => setIndex(i => Math.max(0, i - 1)),
    goForward: () => setIndex(i => Math.min(history.length - 1, i + 1)),
    goTo: (i: number) => setIndex(Math.max(0, Math.min(history.length - 1, i))),
    scrub: (progress: number) => setIndex(Math.floor(progress * (history.length - 1))),
  };
}
```

**Recommended React Flow setup for graphs**:
```tsx
import ReactFlow, { Background, Controls } from 'reactflow';
import 'reactflow/dist/style.css';

function StateGraph({ states, transitions, current }) {
  const nodes = states.map(s => ({
    id: s.id,
    data: { label: s.name },
    position: s.position, // or use auto-layout
    style: s.id === current ? { border: '2px solid blue' } : {},
  }));

  const edges = transitions.map(t => ({
    id: `${t.from}-${t.to}`,
    source: t.from,
    target: t.to,
    label: t.event,
    animated: t.from === current,
  }));

  return (
    <ReactFlow nodes={nodes} edges={edges} fitView>
      <Background />
      <Controls />
    </ReactFlow>
  );
}
```

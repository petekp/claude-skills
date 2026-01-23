Direct Manipulation: A Step Beyond Programming Languages

Ben Shneiderman, University of Maryland

Direct manipulation systems offer the satisfying experience of operating on visible objects. The computer becomes transparent, and users can concentrate on their tasks.

Leibniz sought to make the form of a symbol reflect its content. “In signs,” he wrote, “one sees an advantage for discovery that is greatest when they express the exact nature of a thing briefly and, as it were, picture it; then, indeed, the labor of thought is wonderfully diminished.”
— Frederick Kreiling, “Leibniz,” Scientific American, May 1968

Certain interactive systems generate glowing enthusiasm among users—in marked contrast with the more common reaction of grudging acceptance or outright hostility. The enthusiastic users’ reports are filled with positive feelings regarding:

- Mastery of the system: A sense of control and fluency in operation.

- Competence in the task: Effective performance on their goals.

- Ease of learning: Accessibility for initial use and for advanced features.

- Retention over time: Confidence in sustained mastery.

- Enjoyment in use: Pleasure derived from interaction.

- Social pride: Eagerness to demonstrate to novices.

- Exploratory desire: Motivation to discover more powerful aspects.

These feelings are not universal, but they convey the image of the truly pleased user. From interviews and system examinations, a model of the features producing such delight emerges: visibility of the object of interest; rapid, reversible, incremental actions; and replacement of complex command language syntax by direct manipulation of the object of interest—hence “direct manipulation.”

Examples of Direct Manipulation Systems

No single system has all the attributes or design features that merit admiration, but those below have enough to win enthusiastic support.

Display Editors

“Once you’ve used a display editor, you’ll never want to go back to a line editor. You’ll be spoiled.” Full-page display editors attract strong advocacy versus line-oriented editors; similar sentiments appear among users of stand-alone word processors (e.g., Wang) and display editors such as EMACS on the MIT/Honeywell Multics system or “vi” on Unix. A beaming advocate called EMACS “the one true editor.”

Roberts found overall performance time of display editors to be about half that of line-oriented editors; display editors also reduce training time. Office automation evaluations consistently favor full-page display editors for secretarial and executive use.

Advantages include:

- Full display context: 24 to 66 lines visible, enabling contextual reading and scanning. One-line-at-a-time is like viewing through a narrow cardboard tube.

- WYSIWYG form: Eliminates formatting command clutter; tables, lists, page breaks, headings, centered text, and figures appear as printed; formatting errors become immediately apparent.

- Visible cursor: A clear focus of attention via arrow/underscore/blinking box.

- Intuitive motion: Arrow keys or mouse/joystick/graphics tablet map natural physical actions; contrast with cryptic commands like UP 6.

- Labeled buttons: INSERT, DELETE, CENTER, UNDERLINE, SUPERSCRIPT, BOLD, LOCATE act as persistent menu reminders, obviate memorization; gateway buttons expose advanced features via on-screen menus.

- Immediate feedback: Operations (move, center, delete, insert) display instantly; line editors require extra display/print commands.

- Speed: High display rates (e.g., 120 cps/1200 baud, full page in a second at 9600 baud) and short response times yield a thrilling sense of power; reduces command burden and learning time. Line editors at ~30 cps with multi-second latency seem sluggish.

- Easy reversibility: Backspace/overstrike corrections; congruent inverse operations ease learning (Carroll). UNDO cancels prior command sequences, lowers anxiety about mistakes or file destruction.

Competition in display editors accelerates evolutionary refinements. The excerpt below illustrates contemporary IBM display editor capabilities.// EDIT --- SPFDEMO.MYLIB.PLI(COINS) - 01.04 ------------------- COLUMNS 001 072

// COMMAND INPUT => SCROLL ===> HALF

// \*X\***\* ********\*\*\***********~**\*\*** TOP OF DATA \*

// 000100 COINS:

// 000200 PROCEDURE OPTIONS (MAIN);

// 000300 DECLARE

// 000400 COUNT FIXED BINARY (31) AUTOMATIC INIT (1),

// 000500 HALVES FIXED BINARY (31),

// 000600 QUARTERS FIXED BINARY (31),

// 000700 DIMES FIXED BINARY (31),

// 000800 NICKELS FIXED BINARY (31),

// 000900 SYSPRINT FILE STREAM OUTPUT PRINT;

// 001000 DO HALVES = 100 TO 0 BY -50;

// 001100 DO QUARTERS = (100 - HALVES) TO 0 BY -25;

// 001200 DO DIMES = ((100 - HALVES - QUARTERS)/10)\*10 TO 0 BY -10;

// 001300 NICKELS = 100 - HALVES - QUARTERS - DIMES;

// 001400 PUT FILE(SYSPRINT) DATA(COUNT,HALVES,QUARTERS,DIMES,NICKELS);

// 001500 COUNT = COUNT + 1;

// 001600 END;

// 001700 END;

// 001800 END;

// 001900 END COINS;

// **\*\*** BOTTOM OF DATA **\*\*** **\*\*\*\*** \*

// EDIT --- SPFDEMO.MYLIB.PLI(COINS) - 01.04 ------------------- COLUMNS 001 072

// COMMAND INPUT = SCROLL = HALF

// **\*** ********\********* ****\*\***** TOP OF DATA **\*** ******\*\*******

// 000100 COINS:

// 000200 PROCEDURE OPTIONS (MAIN);

// 000300 DECLARE

// 000400 COUNT FIXED BINARY (31) AUTOMATIC INIT (1),

// 000500 HALVES FIXED BINARY (31),

// 000600 QUARTERS FIXED BINARY (31),

// 000700 DIMES FIXED BINARY (31),

// 000800 NICKELS FIXED BINARY (31),

// 000900 SYSPRINT FILE STREAM OUTPUT PRINT;

// 001000 DO HALVES = 100 TO 0 BY -50;

// 001100 DO QUARTERS = (100 - HALVES) TO 0 BY -25;

// 001200 DO DIMES = ((100 - HALVES - QUARTERS)/10)\*10 TO 0 BY -10;

// 001300 NICKELS = 100 - HALVES - QUARTERS - DIMES;

// 001500 COUNT = COUNT + 1;

// 001600 END;

// 001700 END;

// 001800 END;

// 001900 END COINS;

// **\*\*** ************\*\*\************* BOTTOM OF DATA **\* **\***** **\***

Visicalc

Visicorp’s innovative financial forecasting program, Visicalc, emerged from a Harvard MBA student’s frustration with course calculations. An “instantly calculating electronic worksheet” over 254 rows × 63 columns, it discards procedural control structures. Positional declarations can define that column 4 equals the sum of columns 1–3; changes propagate automatically.

Complex dependencies (manufacturing costs, distribution, revenue, commissions, profits) across districts and months become immediately visible. Novices comprehend it because it simulates an accountant’s worksheet; display of 20 rows and up to nine columns (with multiple windows) supports scanning and exploration. The command language for setup can be tricky for novices/infrequent users, but most users need only basic commands. Distributors note “It jumps”: the visible propagation of changes explains its appeal.

Visicalc screenshots (home budget example, cursor in C2, windowed row sums) present formulas and immediate dependencies.

Spatial Data Management

Prototype spatial data management systems, attributed to Nicholas Negroponte, present zoomable, navigable “information spaces.” A user zooms from a world map to Pacific convoys, to silhouettes, to structural details, to full-color captain pictures. Icons can represent corporate dimensions—personnel, organization, travel, production, schedules—where joystick zooms traverse floors, rooms, details. Errors carry minimal cost: back out and try another path.

Success depends on designer skill in choosing icons, graphical representations, and layouts that are natural and easily understood. Even anxious users enjoy zooming/gliding with a joystick and rapidly demand more power and data.

Video Games

Video games exemplify direct manipulation at scale. Early Pong required rotating a knob to move a white rectangle to hit a ricocheting white ball. Novices become competent after watching for 30 seconds; mastery requires hours. Later titles (Missile Command, Donkey Kong, Pac-Man, Tempest, Tron, Centipede, Space Invaders) layered sophisticated rules, color graphics, and sound.

Centipede uses a trackball and one button; Defender has five buttons plus joystick—novices often abandon due to complexity. Designers seek controls that are easy to use and hard to destroy.

Game fields of action are abstractions of reality; learning by analogy is straightforward. Auto-demo loops convey rules; watching a knowledgeable player accelerates understanding. There remains ample complexity to entice experts. Commands are physical (presses, motions, rotations); results appear immediately. There is no syntax—and no syntax errors. Inverse operations are natural (move left too far → move right). Continuous scoring supports progress tracking and competition; high scorers store initials for display—positive reinforcement encouraging mastery.

Malone’s studies with schoolchildren, and Shneiderman’s own, show continuous display of scores is valuable. Machine value judgments (“Very good”, “You’re doing great”) are inferior; users prefer self-judgment, and may perceive generic praise as annoying/deceptive.

Analogies between games and applications are productive (Carroll and Thomas), but differ: game users seek entertainment and mastery challenge; application users focus on tasks and may resent forced learning. Random events challenge gamers; predictable system behavior is preferable in non-game designs. Gamers compete with systems; application users prefer strong internal locus of control.

CAD/CAM and Process Control

Computer-aided design systems (automobile, electronics, architecture, aircraft, newspaper layout) apply direct manipulation. Operators see schematics, using lightpens/cursors to move components; systems compute currents, voltages, fabrication costs, and consistency warnings. Layout artists and designers iterate rapidly, recording promising alternatives.

Process control systems (e.g., Honeywell) provide colored plant schematics across multiple displays; red lines indicate out-of-range sensors. Single numbered buttons drill into components; further presses traverse to sensors or reset valves/circuits—no commands to memorize in rare emergencies. The schematic enables problem-solving by analogy; screen representations map closely to real-world pressures/temperatures.

Familiar Direct Manipulation

Driving is a canonical example: visible scene through the windshield, actions (steering/braking) are cultural skills; turning left by rotating the wheel left gives immediate feedback via changing scene. Contrast: issuing LEFT 30 DEGREES and then a position check—akin to many office automation tools.

Industrial robot programming by demonstration is direct manipulation: the operator guides the robot’s hand through tasks (spray painting, welding) while the computer records; then repeats automatically.

Query-by-Example (QBE) derives much success from direct representation of relations on screen; users move a cursor through relational columns and enter examples for desired results. Minimal keywords supplement the style, though complex Booleans/maths still require syntax knowledge. Novices learn basics quickly; ample power remains for experts. Direct cursor manipulation across relational skeletons is straightforward; linking variables via examples is intuitively clear to tabular-data literate users. Zloof extended QBE to Office-by-Example, integrating database search, word processing, electronic mail, business graphics, and menu creation.

Advanced office automation designs apply direct manipulation: Xerox Star (sophisticated text formatting, graphics, multiple fonts, high-resolution cursor-based UI), icon drag-and-drop (document icon into printer icon), Apple Lisa (many principles elegantly applied). IBM’s Pictureworld proposed future office systems with graphic icons for file cabinets, mailboxes, notebooks, phone messages; distribution/filing via icon menu selection. Yedwab et al. described a generalized “automated desk.”

Computer-assisted instruction (CDC Plato) employed direct manipulation: tracing inherited characteristics by breeding drosophila, performing medical procedures in emergencies, finger-drawn/moved shapes, chemistry lab projects, and games.

Explanations of Direct Manipulation

“What you see is what you get” (Don Hatfield, IBM) describes the general approach; Harold Thimbleby extends: “What you see is what you have got”—displays should reflect complete status, errors, and appropriate actions. Ted Nelson’s “virtuality” highlights manipulable representations of reality. Rutkowski’s “transparency” posits the tool disappears while intellect applies directly to the task. MacDonald’s “visual programming” proposes accelerating system construction and enabling end-user-generated or modified applications.

Problem-Solving and Learning Research

Psychology literature underscores the primacy of representation in solving and learning. Polya advocates pictures for mathematical problems; Montessori used physical objects (beads/wooden sticks) to convey arithmetic and comparisons; Bruner extended physical representations to polynomial factoring and other principles. Carroll, Thomas, and Malhotra found spatial representations yielded faster, more successful problem solving than isomorphic temporal ones.

Physical/spatial/visual representations are easier to retain and manipulate. Wertheimer showed that subjects given structural explanations (e.g., cutting and relocating a triangle for parallelogram area) retained and transferred knowledge better than those memorizing formulas (A = h × b). Spatial representations facilitate theorem discovery more than axiomatic formulations. Algebra students are often encouraged to draw representations for word problems.

Papert’s Logo creates a mathematical microworld rendering geometric principles visible: an electronic turtle draws lines per user programs. This environment provides rapid feedback, easy diagnosis and repair of errors, and creative satisfaction.

Problems with Direct Manipulation

Graphic representations can aid professional programming tasks (flowcharts, record structures, schema diagrams), but learning the rules of representation takes effort. Graphics help when multiple relationships exist among objects and when representations are more compact than detailed objects; selectively screening detail to present useful abstractions can facilitate performance.

However, spatial/graphic representations do not automatically improve performance. In experiments, subjects given detailed flowcharts did no better at comprehension, debugging, or modification than those given only code. In program comprehension, control-flow or data-structure graphics did not outperform textual descriptions; however, data-structure documentation consistently outperformed control-flow documentation—content selection is critical. Wrong or cluttered information increases confusion.

Second, users must learn icon semantics; designer-meaningful icons can require as much or more learning than words. Airports serving multilingual communities use icons extensively, but meanings can be opaque; international terminals with icons may be unclear.

Third, graphics can mislead; users rapidly grasp analogies but infer incorrect permissible operations. Designers must be cautious in representation and operation choices; ample user testing is required to refine representations and minimize side effects.

Fourth, graphics can consume excessive display space. Experienced users may prefer compact tabular textual displays (e.g., 50 filenames) over 10 abbreviated icon labels. Icons should be evaluated for static informational density and relational display power, then for dynamic utility in selection/movement/deletion.

Choosing suitable representations and operations is nontrivial. Simple metaphors/analogies/models with minimal concept sets are preferable. Mixing metaphors adds complexity and confusion; emotional tone should be inviting rather than distasteful/inappropriate (e.g., sewage disposal metaphors are inappropriate for electronic messaging). Since users may not share designer metaphors, ample testing is essential.

The Syntactic/Semantic Model

User attraction to direct manipulation correlates with a cognitive model distinguishing syntactic from semantic knowledge.

- Syntactic knowledge: Arbitrary details of command syntax (delimiters, precise sequences for insertions/deletions, keystrokes like delete/CONTROL‑H/ESCAPE). Acquired by rote, volatile unless rehearsed; system-dependent, with limited overlap.

- Semantic knowledge: Hierarchical concepts/functionality from low-level operations (cursor movement, insertion/deletion, changes, copy, centering, indentation) to mid-level procedures (correct a misspelling: display, position, change/overstrike) to high-level tasks (move a sentence across paragraphs via marking, copying to buffers, cleanup, paste, check, clear buffer). Expert users decompose problem-domain tasks top-down into lower-level program-domain operations. Semantic knowledge is system-independent; text-editing functions are widely available though syntax varies. Acquired through explanation/analogy/example; anchors to familiar concepts and is stable.

Command formulation proceeds from perceived high-level task, to decomposition into low-level semantic operations, to conversion into commands. At the syntax level, users must recall spacing rules, function key availability, abbreviations.

Frequent use of multiple editors makes clear the commonality of problem-solving thought and diversity of syntactic forms. Syntactic clashes are especially annoying (special character placement differences; multiple backspace approaches—key/cursor-control/mouse; differing meanings of “K” for keeping vs. killing a file).

Implications:

- Novices tightly bind syntax to semantics; command names cue semantic recall; novices evaluate commands for applicability to tasks; they struggle to move a sentence even if they understand commands. Editors with “CHANGE old/new” require instruction to repurpose for delete/insert operations.

- Manuals should be organized from problem-domain viewpoints, with section titles describing user operations; then present command details; finally syntax. Alphabetized command-centric manuals impede novice anchoring to familiar concepts.

- Direct manipulation displays the object of interest and acts in the problem domain, minimizing decomposition into multiple syntactic commands. Each command produces immediate, comprehensible problem-domain action; proximity to problem domain lowers problem-solving load and stress.

Actions and visual skills precede language in human development. Spatial relationships and actions are grasped more quickly via visual representations than linguistic ones. Suitable visual representations promote intuition and discovery in formal systems.

Piaget’s stages: sensorimotor (birth–~2), preoperational (2–7), concrete operational (7–11), formal operations (~11+). Physical actions on objects are comprehensible during concrete operations; children acquire conservation/invariance. Symbol manipulation for representing actions arises at formal operations. Mathematics and programming are abstract, difficult for children; effort is needed to link symbols to objects. Direct manipulation attempts to ground activity at the concrete or even preoperational stage, easing tasks for children and adults.

Direct manipulation suits cases with small object sets and simple commands; it can also scale, as display editors show. Limits will be determined by designer imagination and skill. With more examples and experience, researchers can test competing metaphors/analogies; familiar visual analogies may aid early learning, while abstract models may better support regular use.

The syntactic/semantic model is a simple cognitive model requiring refinement; empirical tests and careful measurements across systems will validate improvements. Cognitive models of user behavior and mental models/system images are expanding research areas in computer science and psychology.

Potential Applications of Direct Manipulation

The central design challenge is finding appropriate representations/models of reality. Visual language can first feel unnatural, then indispensable.

- Personal address list (Rolodex-like): Display cards; joystick forward rotates through cards faster as pushed farther; reverse to go backward; in-place edits via cursor and typing; delete by blanking fields; blank cards at top auto-place alphabetically when filled; find by typing into a field and entering “?”.

- Checkbook maintenance: Display a register with labeled columns; joystick scans earlier entries; in-place changes; new entries at first blank line; checkmark for reconciliation; searches by filling a payee field and “?”.

- Bibliographic search: Wall of labeled catalog index drawers; cursor shaped as hand selects “Author Index” → “F–L” drawer; open reveals finer tabs; select produces cards; copying a card moves to user’s on-screen notebook; edits produce printed bibliographies; combine entries for set operations; distribute via electronic mail; multiple alternate approaches require careful design/testing.

- Job control language: Continuous file directory display with computer component representations; create files by typing names into free directory spots; delete by blanking; copy by dragging names to tape/printer icons; hierarchical directories via ZOOM to reveal deeper tree levels; UNZOOM to back out. Dirtree on Perq builds directories left-to-right via puck selections; lower-level details appear; items are selected by moving a cursor; current item shown in inverse video.

- Airline reservations: Map to select departing/arriving cities; calendar for date; clock for time; plane seating plan with diagonal lines for reserved seats to select a seat.

- Warehouse inventory: Visual aisles with boxes on shelves; combine videodisc and computer graphics for medical supply inventory displays.

- Polynomial education: Bend curves; watch coefficient changes; see roots (x-axis intersections) and derivative reaction.

Direct manipulation attracts users because it is comprehensible, natural, rapid, and enjoyable. With simple actions, ensured reversibility, and easy retention, anxiety recedes and satisfaction flows.

Interest in interactive system design is growing across research communities and commercial products. Researchers apply controlled psychological experimentation to deepen understanding and generate practical guidelines; commercial designers increasingly use pilot studies and acceptance tests.

Interactive systems that display the object of interest and permit rapid, incremental, reversible operations via physical actions rather than syntax attract enthusiastic users. Immediate visibility of operation results and layered/spiral learning approaches contribute to attraction. Each feature requires research to refine contributions and limitations; meanwhile, astute designers can explore direct manipulation approaches.

The future is promising: tasks once accessible only via tedious command/programming languages may soon be handled through lively, enjoyable interactive systems that reduce learning time, speed performance, and increase satisfaction.

Acknowledgments

Partial support from Control Data Corporation (grant 80M15) and computer resources from the University of Maryland Computer Science Center are gratefully acknowledged. The author thanks Gordon Braudaway, Jim Foley, John Gannon, Roger Knights, John Lovgren, Harlan Mills, Phyllis Reisner, Sherry Weinberg, and Mark Weiser for constructive comments on drafts; Gio Wiederhold, Stephen Yau, and reviewers provided useful guidance shaping the final article.

References

1. Teresa L. Roberts, “Evaluation of Computer Text Editors,” PhD dissertation, Stanford University, 1980. University Microfilms, Ann Arbor, Michigan, order number AAD 80‑11699.

2. John M. Carroll, “Learning, Using and Designing Command Paradigms,” Human Learning, Vol. 1, No. 1, 1982, pp. 31–62.

3. Christopher F. Herot, “Spatial Management of Data,” ACM Trans. Database Systems, Vol. 5, No. 4, Dec. 1980, pp. 493–513.

4. Thomas W. Malone, “What Makes Computer Games Fun?” Byte, Vol. 6, No. 12, Dec. 1981, pp. 258–277.

5. John M. Carroll and John C. Thomas, “Metaphor and the Cognitive Representation of Computing Systems,” IEEE Trans. Systems, Man, and Cybernetics, Vol. SMC‑12, No. 2, Mar./Apr. 1982, pp. 107–116.

6. Moshe M. Zloof, “Query‑by‑Example,” AFIPS Conf. Proc., Vol. 44, 1975 NCC, AFIPS Press, Montvale, N.J., 1975.

7. Moshe M. Zloof, “Office‑by‑Example: A Business Language that Unifies Data and Word Processing and Electronic Mail,” IBM Sys. J., Vol. 21, No. 3, 1982, pp. 272–304.

8. Cranfield Smith et al., “Designing the Star User Interface,” Byte, Vol. 7, No. 4, Apr. 1982, pp. 242–282.

9. Laura Yedwab, Christopher F. Herot, and Ronni L. Rosenberg, “The Automated Desk,” Sigsmall Newsletter, Vol. 7, No. 2, Oct. 1981, pp. 102–108.

10. Ted Nelson, “Interactive Systems and the Design of Virtuality,” Creative Computing, Vol. 6, No. 11, Nov. 1980, pp. 56 ff.; and Vol. 6, No. 12, Dec. 1980, pp. 94 ff.

11. Chris Rutkowski, “An Introduction to the Human Applications Standard Computer Interface, Part 1: Theory and Principles,” Byte, Vol. 7, No. 11, Oct. 1982, pp. 291–310.

12. Alan MacDonald, “Visual Programming,” Datamation, Vol. 28, No. 11, Oct. 1982, pp. 132–140.

13. George Polya, How to Solve It, Doubleday, New York, 1957.

14. Maria Montessori, The Montessori Method, Schocken, New York, 1964.

15. James Bruner, Toward a Theory of Instruction, Harvard University Press, Cambridge, Mass., 1966.

16. John M. Carroll, J. C. Thomas, and A. Malhotra, “Presentation and Representation in Design Problem‑Solving,” British J. Psych., Vol. 71, 1980, pp. 143–153.

17. Rudolf Arnheim, Visual Thinking, University of California Press, Berkeley, Calif., 1972.

18. Robert H. McKim, Experiences in Visual Thinking, Brooks/Cole Publishing Co., Monterey, Calif., 1972.

19. Max Wertheimer, Productive Thinking, Harper and Row, New York, 1959.

20. Seymour Papert, Mindstorms: Children, Computers, and Powerful Ideas, Basic Books, Inc., New York, 1980.

21. Ben Shneiderman, R. Mayer, D. McKay, and P. Heller, “Experimental Investigations of the Utility of Detailed Flowcharts in Programming,” Comm. ACM, Vol. 20, No. 6, June 1977, pp. 373–381.

22. Ben Shneiderman, “Control Flow and Data Structure Documentation: Two Experiments,” Comm. ACM, Vol. 25, No. 1, Jan. 1982, pp. 55–63.

23. Michael L. Schneider, “Models for the Design of Static Software User Assistance,” in Directions in Human‑Computer Interaction, Albert Badre and Ben Shneiderman, eds., Ablex Publishing Co., Norwood, N.J., 1982.

24. Ben Shneiderman and Richard Mayer, “Syntactic/Semantic Interactions in Programmer Behavior: A Model and Experimental Results,” Int’l J. Computer and Information Sciences, Vol. 8, No. 3, 1979, pp. 219–239.

25. Ben Shneiderman, Software Psychology: Human Factors in Computer and Information Systems, Little, Brown and Co., Boston, Mass., 1980.

26. Ben Shneiderman, “A Note on Human Factors Issues of Natural Language Interaction with Database Systems,” Information Systems, Vol. 6, No. 2, Feb. 1981, pp. 125–129.

27. D. P. Ausubel, Educational Psychology: A Cognitive Approach, Holt, Rinehart and Winston, New York

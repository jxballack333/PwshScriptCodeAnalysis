## PowerShell Script Code Analysis Development Stages

### Stage 1: Analyzing a Single PowerShell File
#### Functionality
- Analyzes connections between functions in a single PowerShell script.
- Utilizes the Abstract Syntax Tree (AST) of the script to identify function definitions and calls.
#### Output
- Generates a map of how functions are interconnected within the file.
- Optional: Creates a DOT script for visualization using Graphviz.

---

### Stage 2: Focusing on a Specific Function
#### New Feature
- Ability to specify a target function name.
#### Functionality
- Identifies incoming calls (functions that call the target function) and outgoing calls (functions called by the target function) at the first level.
#### Output
- Produces a focused analysis showing direct relationships for a specific function.

---

### Stage 3: Multi-Level Analysis of Function Calls
#### New Parameter
- Introduces a depth parameter to define the extent of recursive analysis.
#### Functionality
- Expands the script to trace function calls (both incoming and outgoing) up to the specified depth, capturing complex relationships.
#### Output
- Provides a comprehensive view of a function's impact on the system by visualizing multi-layered connections.

---

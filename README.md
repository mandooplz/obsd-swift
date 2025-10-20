# OBSD in Swift — Interactive Examples

**Purpose**  
This repository contains **interactive sample codes** for the **Object-Based Software Development (OBSD)** methodology implemented in **Swift**.  
OBSD is related to but **distinct from classic OOP**; the examples highlight OBSD’s modeling style and coding patterns.

## Repository Layout
- **Swift Package**: one `Package.swift` at the root
- **Targets**:  
  - **Executable target** — a *sandbox* to type and run code quickly  
  - **Multiple library targets** — reusable OBSD components used by the executable

> You can write quick experiments in the executable target’s `main.swift` and reference the libraries directly.

---

## Prerequisites
- **Swift toolchain** 6.0 or later (`swift --version`)
- Git
- One of: **Xcode (macOS)**, **VS Code with Swift extension**, or **JetBrains Rider / AppCode**

---

## Quick Start (CLI)
```bash
# 1) Clone
git clone <YOUR-REPO-URL>
cd <repo-folder>

# 2) Resolve dependencies & build
swift build

# 3) Run the sandbox executable (adjust the path if different)
swift run Sandbox
````

### Try it: write code in `main.swift`

Open the sandbox executable target and edit `main.swift`:

```swift
// main.swift
print("OBSD sandbox ready.")

// Write temporary experiments here:
// let result = MyObsdService.doSomething()
// print(result)
```

Run again:

```bash
swift run Sandbox
```

---

## Using Xcode (macOS)

1. Open the repository folder in Xcode (`File > Open` → select the folder with `Package.swift`).
2. Select the executable target (`Sandbox`) as the **Run scheme**.
3. Edit `main.swift` to write your test code.
4. Press **Cmd+R** to run.

---

## Using VS Code

1. Open the repo folder in VS Code.
2. Install extensions: **Swift for VS Code**.
3. Run in terminal:

   ```bash
   swift build
   swift run Sandbox
   ```
4. Alternatively, configure launch settings and use **Run and Debug** (F5).

---

## Using JetBrains Rider / AppCode

1. **Open** the repository folder as a Swift Package project.
2. Set the executable target (`Sandbox`) as the **Run configuration**.
3. Edit `main.swift`.
4. Press **Shift+F10** (or the Run ▶ button).

---

## Common Tasks

* **Add a new library target**

  ```bash
  swift package add-target ObsdExtras --type library
  ```

  Then update `Package.swift` to include the new library, and link it in your executable target.

* **Add a SwiftPM dependency**

  ```bash
  swift package add-dependency https://github.com/apple/swift-collections.git
  ```

---

## Troubleshooting

* **Toolchain mismatch**: run `swift --version` and ensure it matches the supported version in the repo.
* **Dependency issues**: clear build artifacts and resolve again:

  ```bash
  swift package clean
  swift package reset
  swift build
  ```
* **Sandbox target not found**: check `Package.swift` and ensure the executable target name matches.

---

## License

Apache License 2.0 (see `LICENSE`).

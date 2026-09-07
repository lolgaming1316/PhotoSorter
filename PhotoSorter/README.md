# PhotoSorter

A private photo organizer for iPhone: sign up / log in, create named folders,
add photos into them from your library, and lock the whole thing behind
Face ID.

## Important: you need a Mac to build this

iOS apps can only be compiled and run through Xcode, which only runs on
macOS. This project is fully written and ready to go, but from a Windows
machine you can only edit the source — to actually build, simulate, or
install it on your iPhone you'll need one of:

- A Mac (any recent MacBook/iMac/Mac mini) with Xcode 15 or later installed
- A cloud Mac rental service (e.g. MacinCloud, MacStadium) if you don't own one
- A friend/colleague's Mac, temporarily

Once you're on a Mac, the steps below take about 10 minutes.

## What this app does (and a limitation to know about)

- **Login / Signup** — real accounts via Supabase Auth (email + password).
- **Folders** — create and name folders, see photo counts, delete folders.
- **Add photos** — tap **+** in a folder, pick any photos from your library,
  they're copied into the app's own private storage (not just referenced).
- **Face ID lock** — the app locks itself whenever it's backgrounded and
  requires Face ID (or your passcode as a fallback) to reopen. Toggle it off
  in Settings if you don't want it.

**About "hidden photos":** Apple deliberately does not let third-party apps
read the system Photos app's "Hidden" or "Recently Deleted" albums — this is
a privacy restriction, not a limitation of this app, and there's no
public API to bypass it. So the app can't *automatically* pull photos out of
your Hidden album. Instead, the flow is: you open a folder, tap **+**, and
pick whichever photos you want from your library (this can include photos
you currently keep hidden in the Photos app) — the app copies them into its
own separate, Face-ID-locked vault. Functionally this becomes your new
"hidden" storage, and once a photo is in a PhotoSorter folder you can delete
it from the system Photos app entirely if you want it to only live here.

## One-time setup

### 1. Install Xcode and XcodeGen

Install Xcode from the Mac App Store, then install
[XcodeGen](https://github.com/yonaskolb/XcodeGen) (used to turn
`project.yml` into a real `.xcodeproj`, so the project stays easy to read
and diff without a giant binary project file):

```bash
brew install xcodegen
```

### 2. Generate the Xcode project

From inside this folder:

```bash
xcodegen generate
open PhotoSorter.xcodeproj
```

### 3. Set your signing team

In Xcode, select the **PhotoSorter** target -> **Signing & Capabilities** ->
choose your Apple ID under **Team**. (A free Apple ID works for running on
your own device; you don't need a paid developer account.)

### 4. Supabase project (backend for login/signup)

Already done — [Sources/Services/SupabaseManager.swift](Sources/Services/SupabaseManager.swift)
is wired up to a live Supabase project
(dashboard: https://supabase.com/dashboard/project/psexvtistgrtktafvguj).

If you ever need to point this app at a different Supabase project, go to
**Settings -> API** in that project's dashboard and replace `projectURL` /
`anonKey` in that file.

By default Supabase requires email confirmation before a new account can log
in. If you'd rather test without clicking a confirmation email each time, go
to **Authentication -> Providers -> Email** in the dashboard above and turn
off "Confirm email".

### 5. Run it

Pick your iPhone (or a simulator) as the run destination in Xcode and hit
**Run**. Note that Face ID doesn't work on the simulator by default — enable
it via the simulator's menu: **Features -> Face ID -> Enrolled**, then
**Features -> Face ID -> Matching Face** when the app asks to authenticate.
On a real iPhone it just works with your actual face.

## Project structure

```
Sources/
  PhotoSorterApp.swift          App entry point, sets up SwiftData
  Models/
    LocalFolder.swift           A folder (name, owner, created date)
    LocalPhoto.swift            A photo file reference inside a folder
  Services/
    SupabaseManager.swift       Supabase client + your project credentials
    AuthViewModel.swift         Sign up / sign in / sign out / session state
    BiometricAuthManager.swift  Face ID lock logic
    PhotoFileManager.swift      Reads/writes photo files in app-private storage
  Views/
    RootView.swift              Chooses login vs. lock screen vs. main app
    Auth/LoginView.swift, SignUpView.swift
    Lock/LockScreenView.swift
    Folders/FolderListView.swift, FolderDetailView.swift,
            NewFolderSheet.swift, PhotoPicker.swift
    Settings/SettingsView.swift
```

Folders and photo metadata are stored on-device with SwiftData; the actual
photo files live in the app's private Application Support directory under
`PhotoVault/<folder-id>/`, protected by iOS's file data protection (tied to
your device passcode/Face ID). Supabase is only used for account
login/signup — nothing about your photos or folder names is uploaded to the
cloud. If you'd like folders to sync across multiple devices later, that
would mean adding a `folders` table in Supabase — it's a natural next step
but isn't built yet.

set windows-shell := ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

repo := justfile_directory()

# Create libs\ with directory symlinks (relative targets ..\..\Ace3, ..\..\LibDBIcon-1.0).
setup:
	& "{{ repo }}/scripts/hewwo-libs.ps1" -Root "{{ repo }}" -Mode Setup

# Pull latest commit, then refresh lib symlinks.
update:
	git -C "{{ repo }}" pull --ff-only; if ($LASTEXITCODE) { exit $LASTEXITCODE }; just setup

# Verify required library files resolve under libs\.
check:
	& "{{ repo }}/scripts/hewwo-libs.ps1" -Root "{{ repo }}" -Mode Check

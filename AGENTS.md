# ROS Development Environment

## Development Environment

This is a ROS (Robot Operating System) Jazzy workspace with Docker-based development.

**Start the container:**
```bash
./run.sh
# or
docker compose up -d && docker exec -it ros_jazzy bash
```

Inside the container, the workspace is mounted at `/workspace`.

## Working with Submodules

All projects in `program/` are git submodules. Initialize them with:
```bash
git submodule update --init --recursive
```

## ROS Workspace

The `workspace/` directory follows standard catkin layout:
- `workspace/src/` — source packages (currently empty)
- `workspace/build/` — build artifacts
- `workspace/install/` — installed packages
- `workspace/log/` — build logs

**Build commands (inside container):**
```bash
cd /workspace
source /opt/ros/jazzy/setup.bash
colcon build
```

## Repository Structure

- `program/` — research project submodules (10 projects)
- `session/` — research artifacts and logs
- `workspace/` — ROS catkin workspace
- `docs/superpowers/` — plans and specs for superpowers

## Git Tracking

The repo uses custom git tracking scripts in `scripts/`:
- `track-git-status.sh` - tracks status across monorepo and submodules
- `install-git-tracking-shim.sh` - installs the tracking shim

The `.tracking/` and `.worktrees/` directories are used by external tracking tools.

## Session Directory

The `session/` directory contains research artifacts and logs from active research sessions.

## Testing

ROS packages in `workspace/src/` can be tested using:
```bash
cd /workspace
source /opt/ros/jazzy/setup.bash
colcon test
```

## Development Notes

- The container uses ROS Jazzy (`ros:jazzy-ros-base` image)
- `workspace/src/` is currently empty - source packages go here
- The `program/` directory contains 10 git submodules (research projects)
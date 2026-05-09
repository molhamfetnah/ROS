# Specification: Distributed MPC for Multi-UAV Formation Control

## Project: uav-mpc-geometric-control (FI-10)

**Type:** Research Implementation  
**Application:** Multi-UAV Formation Control  
**Approach:** Distributed Model Predictive Control with Consensus + Geometric Control (SO3)

---

## 1. Problem Statement

### 1.1 Background
Multi-UAV formation control enables coordinated tasks like surveillance, search, and delivery. Centralized approaches suffer from single-point-of-failure and scalability issues. Distributed MPC provides resilience and scalability but requires careful consensus mechanisms.

### 1.2 Research Gap
- Existing distributed MPC for UAVs often assume perfect communication
- Collision avoidance is typically handled post-hoc, not integrated in optimization
- Geometric control (SO3) provides attitude stability but is rarely combined with distributed MPC in simulation

### 1.3 Our Solution
**Distributed Formation MPC** - Each UAV runs local MPC while maintaining formation consensus through neighbor communication.

---

## 2. Technical Architecture

### 2.1 System Diagram
```
┌──────────────────────────────────────────────────────────────┐
│                    Multi-UAV Formation System                │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐              │
│   │  UAV 1  │◄───►│  UAV 2  │◄───►│  UAV 3  │    ...       │
│   └────┬────┘     └────┬────┘     └────┬────┘              │
│        │               │               │                    │
│        ▼               ▼               ▼                    │
│   ┌─────────────────────────────────────────┐              │
│   │         Consensus Module                │              │
│   │    (Formation shape + Target sync)      │              │
│   └─────────────────────────────────────────┘              │
│                         │                                    │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              Each UAV Controller                    │   │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│   │  │ Local MPC│─►│ Geometric│─►│  Motor   │          │   │
│   │  │ Solver   │  │ Controller│  │ Commands │          │   │
│   │  └──────────┘  └──────────┘  └──────────┘          │   │
│   └─────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 Core Components

#### 2.2.1 Quadrotor Dynamics Model
- **State**: `[x, y, z, vx, vy, vz, qw, qx, qy, qz, wx, wy, wz]`
- **Inputs**: `[thrust, tau_x, tau_y, tau_z]`
- **Dynamics**: 6-DOF with simplified motor response

#### 2.2.2 Local MPC Controller
- **Prediction horizon**: 15 timesteps (dt = 0.05s → 0.75s horizon)
- **Cost function**:
  ```
  J = Σ(||p_t - p_ref||² + λ₁||v_t||² + λ₂||u_t||² + λ₃*collision_penalty)
  ```
- **Constraints**: Input bounds, state bounds, collision avoidance

#### 2.2.3 Geometric Controller (SO3)
- Input: desired thrust vector + desired angular velocity
- Output: motor PWM commands
- Uses quaternion for attitude representation

#### 2.2.4 Consensus Protocol
- **Topology**: Ring or mesh (configurable)
- **Update**: Each UAV broadcasts state to neighbors
- **Convergence**: Iterative consensus on formation center and relative positions

#### 2.2.5 Collision Avoidance
- Soft constraint via repulsive potential in MPC cost
- Safety distance: 0.5m between UAVs

### 2.3 Data Flow

```
1. Formation planner generates target trajectory
2. Each UAV:
   a. Receive neighbor states (communication)
   b. Update consensus on formation shape
   c. Solve local MPC optimization
   d. Apply geometric controller
   e. Execute motor commands
3. Loop until mission complete
```

---

## 3. Implementation Details

### 3.1 Quadrotor Model (Python/NumPy)

```python
@dataclass
class QuadrotorState:
    position: np.ndarray      # [x, y, z]
    velocity: np.ndarray      # [vx, vy, vz]
    attitude: np.ndarray      # quaternion [w, x, y, z]
    angular_velocity: np.ndarray  # [wx, wy, wz]

@dataclass
class QuadrotorParams:
    mass: float = 1.0
    inertia: np.ndarray = diag([0.01, 0.01, 0.02])
    thrust_coefficient: float = 1.0
    drag_coefficient: float = 0.1
```

### 3.2 MPC Formulation

```python
def mpc_cost(states, inputs, reference, formation, obstacles):
    tracking_cost = sum(|pos - ref_pos|²)
    formation_cost = sum|relative_pos - desired_formation|²
    control_cost = sum|input|²
    collision_cost = sum repulsion(obstacles)
    return tracking + 0.5*formation + 0.1*control + collision
```

### 3.3 Geometric Controller

```python
def geometric_control(desired_thrust, desired_omega):
    # Compute rotation matrix from quaternion
    # Calculate error between desired and actual attitude
    # Compute control torques using PD + feedforward
    return motor_commands
```

---

## 4. Benchmark Scenarios

| ID | Scenario | Description | Metrics |
|----|----------|-------------|---------|
| S1 | Formation Hold | 4 UAVs hold static formation | Position error < 0.1m |
| S2 | Translation | Formation moves to new position | All track offset |
| S3 | Rotation | Formation rotates in place | Shape preserved |
| S4 | Target Tracking | Follow moving target | Track error < 0.3m |
| S5 | Obstacle Avoidance | Navigate around 2 obstacles | Success rate |
| S6 | Communication Loss | 50% packet loss | Graceful degradation |
| S7 | Variable Swarm | 3-8 UAVs | Scale appropriately |

---

## 5. Evaluation Metrics

| Metric | Target |
|--------|--------|
| Success Rate | >90% |
| Position RMSE | < 0.15m |
| Formation Error | < 0.2m |
| MPC Solve Time | < 50ms |
| Collision Rate | 0% |

---

## 6. Repository Structure

```
uav-mpc-geometric-control/
├── src/
│   ├── models/
│   │   └── quadrotor.py        # Dynamics model
│   ├── controllers/
│   │   ├── mpc.py             # MPC solver
│   │   └── geometric.py       # SO3 controller
│   ├── consensus/
│   │   └── protocol.py        # Consensus logic
│   ├── formation/
│   │   └── planner.py         # Formation planning
│   └── simulation/
│       └── environment.py     # Simulation loop
├── tests/
│   ├── unit/
│   ├── integration/
│   └── stress/
├── benchmarks/
│   └── scenarios/
├── paper/
│   ├── outline.md
│   └── journal/
└── docs/
    └── evaluation/
```

---

## 7. Dependencies

```
numpy>=1.24.0
scipy>=1.10.0
matplotlib>=3.7.0
cvxpy>=1.4.0  # For MPC optimization
pytest>=7.4.0
```

---

## 8. Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Quadrotor Model | 1 week | Working dynamics simulation |
| MPC Solver | 2 weeks | Local MPC implementation |
| Geometric Controller | 1 week | SO3 attitude controller |
| Consensus Protocol | 1 week | Communication/consensus |
| Integration | 1 week | Full system integration |
| Benchmarking | 2 weeks | Evaluation results |
| Paper | 2 weeks | Manuscript |

---

## 9. Journal Target

**Primary:** IEEE Transactions on Robotics (T-RO)
- Impact Factor: ~5.7
- Accepts simulation-only
- Timeline: 4-8 months

**Alternative:** IEEE RA-L
- Faster review (3-6 months)
- Impact Factor: ~5.2

---

## 10. Connection to Prior Work

Building on:
- IK work (FI-09): Geometric control fundamentals
- Swarm work (FI-08): Multi-agent coordination concepts

---

*Specification Version: 1.0*  
*Created: May 9, 2026*
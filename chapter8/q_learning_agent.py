import numpy as np 

import random 

 

# Enviroment parameters 

GRID_SIZE = 5 

NUM_MINES = 3 

EPISODES = 500 

ALPHA = 0.1 

GAMMA = 0.9 

EPSILON = 0.2 

 

# Possible actions 

ACTIONS = ['U', 'D', 'L', 'R'] 

ACTION_SYMBOLS = {'U': '↑', 'D': '↓', 'L': '←', 'R': '→'} 

 

# Create basic environment 

def create_environment(): 

    env = np.zeros((GRID_SIZE, GRID_SIZE)) 

    for _ in range(NUM_MINES): 

        x, y = random.randint(0, GRID_SIZE-1), random.randint(0, GRID_SIZE-1) 

        env[x, y] = -1  # mine 

    return env 

 

# Robot movement 

def move(state, action): 

    x, y = state 

    if action == 'U' and x > 0: 

        x -= 1 

    elif action == 'D' and x < GRID_SIZE - 1: 

        x += 1 

    elif action == 'L' and y > 0: 

        y -= 1 

    elif action == 'R' and y < GRID_SIZE - 1: 

        y += 1 

    return (x, y) 

 

# Reward 

def get_reward(env, state): 

    if env[state] == -1: 

        return -10 

    else: 

        return 1 

 

# Initialize Q-table 

Q = {} 

for x in range(GRID_SIZE): 

    for y in range(GRID_SIZE): 

        Q[(x, y)] = {a: 0.0 for a in ACTIONS} 

 

# Training 

for ep in range(EPISODES): 

    env = create_environment() 

    state = (0, 0) 

    done = False 

    while not done: 

        if random.random() < EPSILON: 

            action = random.choice(ACTIONS) 

        else: 

            action = max(Q[state], key=Q[state].get) 

        next_state = move(state, action) 

        reward = get_reward(env, next_state) 

        max_future_q = max(Q[next_state].values()) 

        Q[state][action] += ALPHA * (reward + GAMMA * max_future_q - Q[state][action]) 

        if reward == -10: 

            done = True 

        state = next_state 

 

print("\n Training completed.\n") 

print("Learned policy (best action per cell):\n") 

 

# Show policy 

policy_grid = [['' for _ in range(GRID_SIZE)] for _ in range(GRID_SIZE)] 

for x in range(GRID_SIZE): 

    for y in range(GRID_SIZE): 

        best_action = max(Q[(x, y)], key=Q[(x, y)].get) 

        policy_grid[x][y] = ACTION_SYMBOLS[best_action] 

 

for row in policy_grid: 

    print(' '.join(row)) 
import numpy as np 

import random 

import time 

 

GRID_SIZE = 5 

NUM_MINES = 3 

ALPHA = 0.1 

GAMMA = 0.9 

 

# Action and symbols 

ACTIONS = ['U', 'D', 'L', 'R'] 

ACTION_SYMBOLS = {'U': '↑', 'D': '↓', 'L': '←', 'R': '→'} 

 

# Adaptive parameters 

params = { 

    'EPSILON': 0.2, 

    'EPISODES': 200 

} 

 

# Create environment 

def create_environment(): 

    env = np.zeros((GRID_SIZE, GRID_SIZE)) 

    for _ in range(NUM_MINES): 

        x, y = random.randint(0, GRID_SIZE - 1), random.randint(0, GRID_SIZE - 1) 

        env[x, y] = -1  # mine 

    return env 

 

def move(state, action): 

    x, y = state 

    if action == 'U' and x > 0: x -= 1 

    elif action == 'D' and x < GRID_SIZE - 1: x += 1 

    elif action == 'L' and y > 0: y -= 1 

    elif action == 'R' and y < GRID_SIZE - 1: y += 1 

    return (x, y) 

 

def get_reward(env, state): 

    if env[state] == -1: 

        return -10 

    return 1 

 

# Basic simulated diagnosis 

def diagnose(stats): 

    issues = [] 

    if stats['avg_reward'] < 0: 

        issues.append('bad_reward_function') 

    if stats['exploration_repeats'] > 5: 

        issues.append('low_epsilon') 

    if stats['ignored_mines'] > 2: 

        issues.append('risk_aversion') 

    return issues 

 

# Automatic parameter correction 

def auto_fix(diagnosis): 

    if 'low_epsilon' in diagnosis: 

        params['EPSILON'] = min(params['EPSILON'] + 0.1, 1.0) 

    if 'bad_reward_function' in diagnosis: 

        params['EPISODES'] += 100 

    if 'risk_aversion' in diagnosis: 

        params['EPSILON'] = min(params['EPSILON'] + 0.1, 1.0) 

 

# Permanent training, diagnosis and adjustment cycle 

def train_and_adapt(): 

    Q = {(x, y): {a: 0.0 for a in ACTIONS} for x in range(GRID_SIZE) for y in range(GRID_SIZE)} 

     

    cycle = 0 

    while True: 

        cycle += 1 

        rewards = [] 

        exploration_repeats = 0 

        ignored_mines = 0 

 

        for ep in range(params['EPISODES']): 

            env = create_environment() 

            state = (0, 0) 

            visited = set() 

            total_reward = 0 

            done = False 

            while not done: 

                if random.random() < params['EPSILON']: 

                    action = random.choice(ACTIONS) 

                else: 

                    action = max(Q[state], key=Q[state].get) 

                next_state = move(state, action) 

                reward = get_reward(env, next_state) 

 

                if next_state in visited: 

                    exploration_repeats += 1 

                visited.add(next_state) 

                if env[next_state] == -1 and random.random() > 0.5: 

                    ignored_mines += 1  # mal comportamiento ante posible mina 

 

                total_reward += reward 

                max_future_q = max(Q[next_state].values()) 

                Q[state][action] += ALPHA * (reward + GAMMA * max_future_q - Q[state][action]) 

                if reward == -10: 

                    done = True 

                state = next_state 

 

            rewards.append(total_reward) 

 

        # Basic simulated diagnosis 

        stats = { 

            'avg_reward': np.mean(rewards), 

            'exploration_repeats': exploration_repeats, 

            'ignored_mines': ignored_mines 

        } 

 

        print(f"\n🔄 Cycle {cycle} completed.") 

        print(f"📊 Average reward: {stats['avg_reward']:.2f}") 

        print(f"↩️ Repeated explorations: {exploration_repeats}") 

        print(f"🚫 Ignored mines: {ignored_mines}") 

        print(f"⚙️ Current parameters: {params}") 

 

        diagnosis = diagnose(stats) 

        if diagnosis: 

            print("🩺 Diagnosis:", diagnosis) 

            auto_fix(diagnosis) 

            print("✅ Adjustments applied:", params) 

        else: 

            print("👌 No issues detected.") 

 

        # Stop before the next cycle 

        time.sleep(2) 

 

# Start the autonomous process 

train_and_adapt() 
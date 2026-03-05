
import json

def load_profiles():
    with open('mock_data.json', 'r') as file:
        return json.load(file)

def calculate_match_score(target_user, candidate):
    """
    Calculates a Vibe Score from 0 to 100.
    """
    score = 0
    
    # 1. Hard Filter: Gender Preference 
    # (Assuming target_user has a 'looking_for' field)
    if candidate['gender'] != target_user['looking_for']:
        return 0 # Instant disqualification

    # 2. Soft Logic: Age Gap Penalty (Ideal is within 2 years)
    age_diff = abs(target_user['age'] - candidate['age'])
    if age_diff <= 2:
        score += 40
    elif age_diff <= 5:
        score += 20

    # 3. Soft Logic: Interest Overlap Bonus
    target_interests = set(target_user['interests'])
    candidate_interests = set(candidate['interests'])
    
    common_interests = target_interests.intersection(candidate_interests)
    score += len(common_interests) * 15 # 15 points per shared hobby
    
    # Cap at 100
    return min(score, 100)

def get_ranked_matches(target_user):
    profiles = load_profiles()
    scored_matches = []
    
    for profile in profiles:
        if profile['id'] == target_user['id']:
            continue # Don't match with yourself
            
        score = calculate_match_score(target_user, profile)
        if score > 0:
            scored_matches.append({
                "candidate": profile,
                "vibe_score": score
            })
            
    # Sort by highest score first
    return sorted(scored_matches, key=lambda x: x['vibe_score'], reverse=True)
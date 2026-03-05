from matcher import get_ranked_matches

def test_algorithm_prioritizes_shared_interests():
    # Simulate the logged-in user
    target_user = {
        "id": "my_test_uid",
        "name": "Test User",
        "age": 22,
        "gender": "Male",
        "looking_for": "Female",
        "interests": ["coding", "night rides", "machine learning"]
    }
    
    results = get_ranked_matches(target_user)
    
    # 1. Should only return females (Jake should be filtered out)
    assert len(results) == 2
    
    # 2. Samantha should be ranked higher than Ella due to shared interests
    top_match = results[0]['candidate']['name']
    assert top_match == "Samantha", f"Expected Samantha, but got {top_match}"
    
    print("\n✅ Test Passed: Hard filters work and interests are scored correctly!")
    for rank, result in enumerate(results, 1):
        print(f"Rank {rank}: {result['candidate']['name']} - Vibe Score: {result['vibe_score']}")
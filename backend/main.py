from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from supabase import create_client, Client

# -----------------------------------------------------------------------------
# 1. DATABASE SETUP
# -----------------------------------------------------------------------------
SUPABASE_URL = "https://diynsibfbcemkzmzjhqr.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpeW5zaWJmYmNlbWt6bXpqaHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyMDI5OTgsImV4cCI6MjA4Nzc3ODk5OH0.fCdNpiF_DopYJ4SImkEzY8O3j10P2erO_boaLkeGYY4"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

app = FastAPI()

# -----------------------------------------------------------------------------
# 2. DATA MODELS (Pydantic)
# -----------------------------------------------------------------------------
class UserProfile(BaseModel):
    id: str
    name: str
    age: int
    gender: str
    looking_for: str
    interests: list[str]

class SwipeData(BaseModel):
    swiper_id: str
    target_id: str
    action: str  

class MessageData(BaseModel):
    sender_id: str
    receiver_id: str
    content: str

# -----------------------------------------------------------------------------
# 3. MATCHMAKING API ENDPOINT (Ghosting Protocol)
# -----------------------------------------------------------------------------
@app.post("/api/matches")
async def get_matches(target_user: UserProfile):
    try:
        swipes_response = supabase.table("swipes").select("target_id").eq("swiper_id", target_user.id).execute()
        swiped_ids = [swipe["target_id"] for swipe in swipes_response.data]

        response = supabase.table("users").select("*").eq("gender", target_user.looking_for).execute()
        all_candidates = response.data

        matches = []
        
        for candidate in all_candidates:
            if candidate["id"] in swiped_ids or candidate["id"] == target_user.id:
                continue 

            base_score = 75  
            
            target_interests_raw = target_user.interests if target_user.interests else []
            candidate_interests_raw = candidate.get("interests") if candidate.get("interests") else []
            
            target_interests = set([i.lower() for i in target_interests_raw])
            candidate_interests = set([i.lower() for i in candidate_interests_raw])
            
            shared_interests = target_interests.intersection(candidate_interests)
            
            vibe_score = base_score + (len(shared_interests) * 10)
            vibe_score = min(vibe_score, 99)

            matches.append({
                "candidate": {
                    "id": candidate["id"],
                    "name": candidate["name"],
                    "age": candidate["age"],
                    "bio": candidate.get("bio") or "",
                    "interests": candidate_interests_raw,
                    "profile_image_url": candidate.get("profile_image_url") or "",
                    "is_premium": candidate.get("is_premium") or False # ✨ Fetch their VIP status
                },
                "vibe_score": vibe_score
            })

        matches.sort(key=lambda x: x["vibe_score"], reverse=True)

        return {"matches": matches}

    except Exception as e:
        print(f"\n❌ FATAL MATRIX ERROR: {str(e)}\n")
        raise HTTPException(status_code=500, detail=str(e))

# -----------------------------------------------------------------------------
# 4. SWIPE TRACKING API ENDPOINT 
# -----------------------------------------------------------------------------
@app.post("/api/swipe")
async def record_swipe(swipe: SwipeData):
    try:
        supabase.table("swipes").insert({
            "swiper_id": swipe.swiper_id,
            "target_id": swipe.target_id,
            "action": swipe.action
        }).execute()

        is_match = False

        if swipe.action == 'like':
            mutual_like = supabase.table("swipes").select("*") \
                .eq("swiper_id", swipe.target_id) \
                .eq("target_id", swipe.swiper_id) \
                .eq("action", "like").execute()
            
            if len(mutual_like.data) > 0:
                is_match = True
                supabase.table("matches").insert({
                    "user1_id": swipe.swiper_id,
                    "user2_id": swipe.target_id
                }).execute()

        return {"success": True, "is_match": is_match}

    except Exception as e:
        print(f"\n❌ SWIPE ERROR: {str(e)}\n")
        raise HTTPException(status_code=500, detail="Could not record swipe")

# -----------------------------------------------------------------------------
# 5. MATCHES INBOX API ENDPOINT
# -----------------------------------------------------------------------------
@app.get("/api/inbox/{user_id}")
async def get_inbox(user_id: str):
    try:
        matches_response = supabase.table("matches").select("*") \
            .or_(f"user1_id.eq.{user_id},user2_id.eq.{user_id}").execute()

        matched_user_ids = []
        for match in matches_response.data:
            if match["user1_id"] == user_id:
                matched_user_ids.append(match["user2_id"])
            else:
                matched_user_ids.append(match["user1_id"])

        if not matched_user_ids:
            return {"inbox": []}

        profiles_response = supabase.table("users") \
            .select("id, name, age, profile_image_url, bio, is_premium") \
            .in_("id", matched_user_ids).execute()

        return {"inbox": profiles_response.data}

    except Exception as e:
        print(f"\n❌ INBOX ERROR: {str(e)}\n")
        raise HTTPException(status_code=500, detail="Could not fetch inbox")

# -----------------------------------------------------------------------------
# 6. CHAT APIs 
# -----------------------------------------------------------------------------
@app.post("/api/messages")
async def send_message(msg: MessageData):
    try:
        response = supabase.table("messages").insert({
            "sender_id": msg.sender_id,
            "receiver_id": msg.receiver_id,
            "content": msg.content
        }).execute()
        return {"success": True, "message": "Message sent into the Matrix!"}
    except Exception as e:
        print(f"\n❌ SEND MESSAGE ERROR: {str(e)}\n")
        raise HTTPException(status_code=500, detail="Could not send message")

@app.get("/api/messages/{user1_id}/{user2_id}")
async def get_messages(user1_id: str, user2_id: str):
    try:
        response = supabase.table("messages").select("*") \
            .in_("sender_id", [user1_id, user2_id]) \
            .in_("receiver_id", [user1_id, user2_id]) \
            .order("created_at") \
            .execute()
        return {"messages": response.data}
    except Exception as e:
        print(f"\n❌ GET MESSAGES ERROR: {str(e)}\n")
        raise HTTPException(status_code=500, detail="Could not fetch chat history")

# -----------------------------------------------------------------------------
# 7. ✨ NEW: SECRET ADMIRER API (Premium Tier Feature) ✨
# -----------------------------------------------------------------------------
@app.get("/api/who_liked_me/{user_id}")
async def get_who_liked_me(user_id: str):
    """
    Endpoint: http://127.0.0.1:8000/api/who_liked_me/{user_id}
    Job: Finds users who liked you, filters out people you already swiped on, 
         and checks if you have the Premium Crown to view them!
    """
    try:
        # Step A: Check if our user is a Premium VIP 👑
        user_res = supabase.table("users").select("is_premium").eq("id", user_id).execute()
        is_premium = False
        if user_res.data:
            is_premium = user_res.data[0].get("is_premium", False)

        # Step B: Find everyone who has ever swiped right on our user
        liked_me_res = supabase.table("swipes").select("swiper_id").eq("target_id", user_id).eq("action", "like").execute()
        admirer_ids = [swipe["swiper_id"] for swipe in liked_me_res.data]
        
        if not admirer_ids:
            return {"is_premium": is_premium, "admirers": []}

        # Step C: Find everyone our user has ALREADY swiped on (likes or passes)
        my_swipes_res = supabase.table("swipes").select("target_id").eq("swiper_id", user_id).execute()
        judged_ids = [swipe["target_id"] for swipe in my_swipes_res.data]

        # Step D: Filter out the judged people to find the true "Secret Admirers"
        secret_admirer_ids = [aid for aid in admirer_ids if aid not in judged_ids]

        if not secret_admirer_ids:
            return {"is_premium": is_premium, "admirers": []}

        # Step E: Fetch the profile data for these secret admirers
        profiles_response = supabase.table("users") \
            .select("id, name, age, profile_image_url, bio, is_premium") \
            .in_("id", secret_admirer_ids).execute()

        return {
            "is_premium": is_premium, 
            "admirers": profiles_response.data
        }

    except Exception as e:
        print(f"\n❌ SECRET ADMIRER ERROR: {str(e)}\n")
        raise HTTPException(status_code=500, detail="Could not fetch secret admirers")
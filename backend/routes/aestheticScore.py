from fastapi import APIRouter


router = APIRouter()

@router.post("/aestheticScoreFunction")
def aestheticScoreFunction():
    return 6.8
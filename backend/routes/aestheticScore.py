from fastapi import APIRouter, UploadFile, File, Form
from fastapi.responses import PlainTextResponse
from services.aesthetic_service import calculate_aesthetic_score
from typing import List

router = APIRouter()

@router.post("/aestheticScoreFunction")
async def aesthetic_score_function_route(
    image: UploadFile = File(...),
    line_index: int = Form(...)
):
    image_bytes = await image.read()
    mean = calculate_aesthetic_score(image_bytes)
    return PlainTextResponse(f"{mean:.1f}")


@router.post("/filterAlbum")
async def filter_album(image: List[UploadFile] = File(...)):
    scores = []
    mean=0
    for img in image:
        image_bytes = await img.read()
        tmp = calculate_aesthetic_score(image_bytes)
        scores.append(tmp)
        mean+=tmp
    mean = mean / len(image) if image else 0
    print("mean score:", mean)
    print(scores)
    result = [bool(score >= mean) for score in scores]
    print(result)
    return result
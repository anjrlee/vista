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
async def filter_album(image: List[UploadFile] = File(...),percentage: float = Form(...)):
    scores = []
    for img in image:
        image_bytes = await img.read()
        tmp = calculate_aesthetic_score(image_bytes)
        scores.append(tmp)
    baseline=sorted(scores)[int(len(scores)*percentage/100)]
    print("baseline",baseline)
    print("percentage",percentage)
    result = [bool(score >= baseline) for score in scores]
    print(result)
    return result
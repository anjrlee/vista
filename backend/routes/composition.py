from fastapi import APIRouter

router = APIRouter()

@router.post("/compositionDetection")
def compositionDetection():
    return {"composition": "rule_of_thirds"}


@router.get("/testComposition")
def testComposition():
    return {"composition": "rule_of_thirds"}

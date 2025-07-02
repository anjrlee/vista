from fastapi import APIRouter


router = APIRouter()



@router.post("/compositionDetection")
def compositionDetection():
    return {"composition": "rule_of_thirds"}


@router.get("/filterAlbum")
def testComposition():
    return {"composition": function1()}

@router.post("/testComposition")
def testComposition():
    return {"composition": function1()}

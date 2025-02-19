# from app.database.mongo import db

from bson import ObjectId
from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordBearer

from app.conversations import conversation_agents
from app.conversations.conversation_models import TranslationRequest

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

router = APIRouter()

from datetime import datetime
from json import JSONEncoder


class MongoJSONEncoder(JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        if isinstance(obj, ObjectId):
            return str(obj)
        return super().default(obj)


@router.post("/api/conversation_card/translate", tags=["Conversatioin AI"])
async def translate_conversation(request: TranslationRequest, token: str = Depends(oauth2_scheme)):
    # fb_admin.verify_token(token)

    conversation_card = db.get_collection("conversations").find_one({"_id": ObjectId(request.idCard)})
    caracterData = conversation_card["characterCard"]["data"]

    response = await conversation_agents.translate_conversation(caracterData, request.currentLang, request.targetLang)
    print(response.data)
    return response.data
